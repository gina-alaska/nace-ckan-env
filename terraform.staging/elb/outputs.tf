output "elb_public_dns" {
	value = "${aws_elb.ckan-elb.dns_name}"
}

output "elb_zone_id" {
	value = "${aws_elb.ckan-elb.zone_id}"
}
