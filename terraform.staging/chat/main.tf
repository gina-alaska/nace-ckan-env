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

data "aws_subnet" "selected" {
  vpc_id = "${data.terraform_remote_state.nace_vpc.vpc_id}"
  cidr_block = "${element(data.terraform_remote_state.nace_vpc.public_subnets, 0)}"
}

resource "aws_instance" "chat" {
  connection {
    user = "ubuntu"
  }

  count = "${var.chat_instance_count}"
  instance_type = "t2.micro"

  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.nace_vpc.default_security_group_id}",
    "${data.terraform_remote_state.nace_vpc.public_web_security_group_id}"
  ]

  subnet_id = "${data.aws_subnet.selected.id}"

  tags = "${merge(var.tags, map("Name", "NASA ACE ${var.env}"))}"
}

resource "null_resource" "provision_chat" {
  count = "${var.chat_instance_count}"
  provisioner "chef" {
    connection {
      host = "${element(aws_instance.chat.*.public_ip, count.index)}"
      user = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
    environment = "${var.chef_environment}"
    run_list = ["recipe[gina-server::aws]", "recipe[nace_cometchat::default]"]
    node_name = "aws-nace-${var.env}-${element(aws_instance.chat.*.id, count.index)}"
    vault_json =  "{\"apps\":\"nace_ckan\"}"
    server_url = "${var.chef_server_url}"
    user_name = "${var.chef_user_name}"
    user_key = "${file(var.chef_user_key_path)}"
    version = "12.19.36"
    recreate_client = true
  }
}
