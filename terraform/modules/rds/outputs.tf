output "db_address" {
	value = "${aws_db_instance.db.address}"
}

output "db_name" {
	value = "${var.db_name}"
}

output "db_username" {
	value = "${var.db_username}"
}
