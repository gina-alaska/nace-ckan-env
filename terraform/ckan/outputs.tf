output "server_address" {
  value = "${join(",", aws_instance.ckan.*.public_ip)}"
}
