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

data "terraform_remote_state" "nace_ckan" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "terraform/nace-ckan.json"
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

resource "aws_security_group" "elb" {
  name = "nace-ckan-${var.env}"
  description = "CKAN ELB"
  vpc_id = "${data.terraform_remote_state.nace_vpc.vpc_id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "ckan-elb" {
  name = "nace-ckan-${var.env}"

  subnets = ["${data.aws_subnet.selected.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances = ["${data.terraform_remote_state.nace_ckan.instance_ids}"]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  tags = "${merge(var.tags, map("Name", "NASA ACE ${var.env}"))}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/"
    interval = 30
  }
}
