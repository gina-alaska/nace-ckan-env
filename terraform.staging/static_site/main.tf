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

data "terraform_remote_state" "ace_domain" {
  backend = "s3"
  config {
    bucket = "gina-terraform-state",
    key = "terraform/gina-global-ace.uaf.edu.json",
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "ace_website" {
  bucket = "${var.website_url}"
  acl = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = "${merge(var.tags, map("Name", "NASA ACE static site"))}"
}

resource "aws_s3_bucket" "ace_website_redirect" {
  bucket = "${var.redirect_url}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "${var.website_url}"
  }

  tags = "${merge(var.tags, map("Name", "NASA ACE static site redirect"))}"
}

resource "aws_route53_record" "root" {
  zone_id = "${data.terraform_remote_state.ace_domain.zone_id}"
  name = "ace.uaf.edu"
  type = "A"
  alias {
    name = "${aws_s3_bucket.ace_website.website_domain}"
    zone_id = "${aws_s3_bucket.ace_website.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${data.terraform_remote_state.ace_domain.zone_id}"
  name = "www.ace.uaf.edu"
  type = "A"
  alias {
    name = "${aws_s3_bucket.ace_website_redirect.website_domain}"
    zone_id = "${aws_s3_bucket.ace_website_redirect.hosted_zone_id}"
    evaluate_target_health = true
  }
}
