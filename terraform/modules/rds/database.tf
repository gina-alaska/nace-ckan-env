resource "aws_security_group" "db" {
	vpc_id = "${var.vpc_id}"

	ingress {
		from_port = 5432
		to_port = 5432
		protocol = "tcp"
		cidr_blocks = ["${var.ingress_subnets}"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = -1
		cidr_blocks = ["0.0.0.0/0"]
	}
  tags                 = "${merge(var.tags, map("Name", format("%s SG", var.name)))}"
}

resource "aws_db_instance" "default" {
  identifier           = "nasa-ace-db-${var.env}"
  allocated_storage    = "${var.db_storage}"
  engine               = "postgres"
  engine_version       = "9.5.2"
  instance_class       = "${var.db_instance_type}"
  name                 = "${var.db_name}"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  storage_type         = "gp2"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  db_subnet_group_name = "${var.aws_db_subnet_group_id}"
  multi_az             = true

  tags                 = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}