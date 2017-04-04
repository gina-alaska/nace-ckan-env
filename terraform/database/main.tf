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

module "rds" {
  name = "NASA ACE database"
  source = "../modules/rds"
  env = "${var.env}"
  db_instance_type = "db.t2.micro"
  vpc_id = "${data.terraform_remote_state.nace_vpc.vpc_id}"
  /*vpc_cidr_block = "${module.vpc.cidr_block}"*/
  ingress_subnets = "10.40.101.0/24"
  db_password = "${var.db_password}"
  aws_db_subnet_group_id = "${data.terraform_remote_state.nace_vpc.database_subnet_group}"

  tags = "${merge(var.tags, map("Environment", format("%s", var.env)))}"
}
