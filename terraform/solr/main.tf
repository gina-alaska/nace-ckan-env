terraform {
  backend "s3" {
    /* these get set by rake command */
    /*bucket = "bucket-would-go-here"*/
    /*key    = "terraform/nace-ENV.tfstate"*/
    region = "us-west-2"
  }
}

data "terraform_remote_state" "nace_vpc" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "terraform/nace-vpc.json"
    region = "us-west-2"
  }
}

data "aws_subnet" "selected" {
  vpc_id = "${data.terraform_remote_state.nace_vpc.vpc_id}"
  cidr_block = "${element(data.terraform_remote_state.nace_vpc.public_subnets, 0)}"
}

provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
  shared_credentials_file = "${var.credentials_location}"
}

resource "aws_security_group" "solr" {
  name = "nace-ckan-solr-${var.env}"
  description = "CKAN Solr"
  vpc_id = "${data.terraform_remote_state.nace_vpc.vpc_id}"

  ingress {
    from_port = 8983
    to_port = 8983
    protocol = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.nace_vpc.public_subnets}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "solr" {
  connection {
    user = "ubuntu"
  }

  instance_type = "${var.instance_type}"

  ami = "${lookup(var.aws_amis, var.region)}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${data.terraform_remote_state.nace_vpc.default_security_group_id}","${aws_security_group.solr.id}"]

  subnet_id = "${data.aws_subnet.selected.id}"

  tags = "${merge(var.tags, map("Name", "NASA ACE Solr"))}"
}

resource "null_resource" "provision_ckan_solr" {
  triggers {
    instance_ids = "${aws_instance.solr.id}"
  }
  provisioner "chef" {
    connection {
      host = "${aws_instance.solr.public_ip}"
      user = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
    run_list = ["recipe[gina-server::aws]", "recipe[nace-ckan::solr]"]
    environment = "${var.chef_environment}"
    node_name = "aws-nace-${var.env}-${aws_instance.solr.id}"
    server_url = "${var.chef_server_url}"
    user_name = "${var.chef_user_name}"
    user_key = "${file(var.chef_user_key_path)}"
    version = "12.16.42"
    recreate_client = true
  }
}
