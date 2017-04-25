output "solr_private_ip" {
	value = "${aws_instance.solr.private_ip}"
}
output "solr_public_ip" {
	value = "${aws_instance.solr.public_ip}"
}
