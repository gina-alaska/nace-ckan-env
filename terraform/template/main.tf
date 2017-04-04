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
