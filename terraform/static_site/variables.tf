variable "region" {
  default = "us-west-2"
}
variable "profile" {}
variable "credentials_location" {}
variable "env" {}
variable "project" {}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {
    "billing" = "NASA ACE"
    "fund_org" = "397427-66762"
  }
}

variable "website_url" {
  default = "ace.uaf.edu"
}
variable "redirect_url" {
  default = "www.ace.uaf.edu"
}
