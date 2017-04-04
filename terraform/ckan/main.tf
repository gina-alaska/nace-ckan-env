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

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ckan" {
  connection {
    user = "ubuntu"
  }

  count = "${var.ckan_instance_count}"
  instance_type = "t2.micro"

  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${data.terraform_remote_state.nace_vpc.default_security_group_id}"]

  subnet_id = "${data.aws_subnet.selected.id}"

  tags = "${merge(var.tags, map("Name", "NASA ACE CKAN"))}"
}

resource "null_resource" "provision_ckan" {
  count = "${var.ckan_instance_count}"
  provisioner "chef" {
    connection {
      host = "${element(aws_instance.ckan.*.public_ip, count.index)}"
      user = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
    run_list = ["recipe[gina-server::aws]", "recipe[nace-ckan::default]"]
    node_name = "aws-nace-${var.env}-${element(aws_instance.ckan.*.id, count.index)}"
    server_url = "${var.chef_server_url}"
    user_name = "${var.chef_user_name}"
    user_key = "${file(var.chef_user_key_path)}"
    version = "12.16.42"
    recreate_client = true
  }
}
