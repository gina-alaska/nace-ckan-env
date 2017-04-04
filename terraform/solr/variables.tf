variable "region" {
  default = "us-west-2"
}
variable "profile" {}
variable "credentials_location" {}
variable "env" {}
variable "project" {}
variable "remote_state_bucket" {}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {
    "billing" = "NASA ACE"
    "fund_org" = "397427-66762"
  }
}

variable "aws_amis" {
  default = {
    us-west-2 = "ami-adcb36cd"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

#credentials

variable "key_name" {}
variable "private_key_path" {}
variable "public_key_path" {}

# chef stuff

variable "chef_server_url" {}
variable "chef_user_name" {}
variable "chef_user_key_path" {}
variable "chef_environment" {
  default = "nace-staging"
}
