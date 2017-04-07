output "public_ips" {
  value = ["${aws_instance.ckan.*.public_ip}"]
}

output "instance_ids" {
  value = ["${aws_instance.ckan.*.id}"]
}
