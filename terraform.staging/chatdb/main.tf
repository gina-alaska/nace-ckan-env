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

module "rds" {
  name = "${var.env}"
  source = "../modules/rds"
  instance_type = "db.t2.micro"
  vpc_id = "${data.terraform_remote_state.nace_vpc.vpc_id}"
  /*vpc_cidr_block = "${module.vpc.cidr_block}"*/
  ingress_subnets = "${data.aws_subnet.selected.cidr_block}"

  db_name     = "${var.chatdb_name}"
  db_username = "${var.chatdb_username}"
  db_password = "${var.chatdb_password}"
  db_port = 3306

  aws_db_subnet_group_id = "${data.terraform_remote_state.nace_vpc.database_subnet_group}"
  multi_az_db = "${var.multi_az_db}"
  tags = "${merge(var.tags, map("Environment", format("%s", var.env)))}"
  engine = "mysql"
  engine_version = "5.6.27"
}
