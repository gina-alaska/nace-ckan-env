variable "region" {
  default = "us-west-2"
}
variable "profile" {}
variable "credentials_location" {}
variable "env" {}
variable "project" {}

variable "database_subnets" {
  default = ["10.40.201.0/24", "10.40.202.0/24"]
}

variable "public_subnets" {
  default = ["10.40.101.0/24"]
}
