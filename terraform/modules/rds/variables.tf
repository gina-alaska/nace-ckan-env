variable "name" {}
variable "vpc_id" {}
/*variable "vpc_cidr_block" {}*/
variable "ingress_subnets" {}
variable "db_instance_type" {}

variable "db_name" {
  default = "ckan"
}

variable "db_username" {
  default = "ckan_default"
}

variable "db_storage" {
  default = "10"
  description = "Storage size in GBs"
}

variable "db_password" {}
variable "env" {}
variable "aws_db_subnet_group_id" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
