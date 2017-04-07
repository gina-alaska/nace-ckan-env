terraform {
  backend "s3" {
    /* these get set by rake command */
    /*bucket = "bucket-would-go-here"*/
    /*key    = "terraform/nace-ENV.tfstate"*/
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
  shared_credentials_file = "${var.credentials_location}"
}

resource "aws_s3_bucket" "ace_website" {
  bucket = "${var.website_url}"
  acl = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = "${merge(var.tags, map("Name", "NASA ACE Static Site"))}"
}

resource "aws_s3_bucket" "ace_website_redirect" {
  bucket = "${var.redirect_url}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "${var.website_url}"
  }

  tags = "${merge(var.tags, map("Name", "NASA ACE Static Redirect"))}"
}
