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

resource "aws_s3_bucket" "ckan_storage" {
  bucket = "${var.ckan_storage_bucket}"
  acl = "public-read"

  tags = "${merge(var.tags, map("Name", "NASA ACE CKAN S3 Storage"))}"
}

resource "aws_iam_user" "user" {
  name = "nasa_ace_ckan"
}

resource "aws_iam_policy" "ckan_storage_policy" {
  name        = "ckan_storage_policy"
  path        = "/"
  description = "Ckan Storage Policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.ckan_storage_bucket}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject*",
                "s3:GetObject*",
                "s3:DeleteObject*",
                "s3:ListObjects"
            ],
            "Resource": [
                "arn:aws:s3:::${var.ckan_storage_bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "ckan_policy_attach" {
  name       = "ckan-storage-policy-attach"
  users      = ["${aws_iam_user.user.name}"]
  policy_arn = "${aws_iam_policy.ckan_storage_policy.arn}"
}
