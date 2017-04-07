output "public_ips" {
  value = ["${aws_instance.chat.*.public_ip}"]
}

output "instance_ids" {
  value = ["${aws_instance.chat.*.id}"]
}
