output "leader_public_ip" {
  value = ["${aws_instance.ckan_leader.public_ip}"]
}

output "leader_instance_id" {
  value = ["${aws_instance.ckan_leader.id}"]
}

output "public_ips" {
  value = ["${aws_instance.ckan.*.public_ip}"]
}

output "instance_ids" {
  value = ["${aws_instance.ckan.*.id}"]
}
