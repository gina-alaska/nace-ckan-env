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

variable "chatdb_name" {
  default = "cometchat"
}
variable "chatdb_username" {
  default = "cometchat"
}
variable "chatdb_password" {}

variable "multi_az_db" {
  default = false
}
