variable "name" {}
variable "vpc_id" {}
/*variable "vpc_cidr_block" {}*/
variable "ingress_subnets" {}
variable "instance_type" {}

variable "db_name" { }
variable "db_username" { }
variable "db_password" {}
variable "db_port" {}

variable "storage" {
  default = "10"
  description = "Storage size in GBs"
}

variable "aws_db_subnet_group_id" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "engine" { }
variable "engine_version" { }
variable "multi_az_db" {
  default = false
}
