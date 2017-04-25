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
variable "ckan_instance_count" {
  description = "Number of instances to create after the leader"
  default = 1
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
