terraform {
  backend "s3" {
    /*bucket = "nace-terraform-state-test"*/
    /*key    = "terraform/nace-vpc.tfstate"*/
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
  shared_credentials_file = "${var.credentials_location}"
}

module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "nace-vpc"

  cidr = "10.40.0.0/16"

  # 10.40.1.0/24 - unused
  private_subnets = ["10.40.1.0/24"]

  # 10.40.101.0/24 - ckan and stuff
  public_subnets  = "${var.public_subnets}"

  # need two subnets at least for RDS
  database_subnets  = "${var.database_subnets}"

  enable_nat_gateway = "false"
  enable_dns_support = "true"

  azs      = ["us-west-2a", "us-west-2b", "us-west-2c"]

  tags {
    "Terraform" = "true"
    "Environment" = "${var.env}"
    "billing" = "NASA ACE"
    "fund_org" = "397427-66762"
  }
}

resource "aws_security_group" "gina_ssh" {
	vpc_id = "${module.vpc.vpc_id}"
  description = "Manage security group for ssh access"
}

resource "aws_security_group_rule" "allow_uaf" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["137.229.0.0/16"]
    security_group_id = "${aws_security_group.gina_ssh.id}"
}

resource "aws_security_group_rule" "allow_ckan_access" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnets}", "10.40.1.0/24"]
    security_group_id = "${aws_security_group.gina_ssh.id}"
}


resource "aws_security_group_rule" "allow_all_out" {
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 65535
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.gina_ssh.id}"
}
