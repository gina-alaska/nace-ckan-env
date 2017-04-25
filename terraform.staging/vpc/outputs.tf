output "database_subnets" {
  value = ["${var.database_subnets}"]
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "database_subnet_group" {
  value = "${module.vpc.database_subnet_group}"
}

output "default_security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "public_web_security_group_id" {
  value = "${aws_security_group.public_web.id}"
}

output "private_web_security_group_id" {
  value = "${aws_security_group.private_web.id}"
}

output "public_subnets" {
  value = "${var.public_subnets}"
}
