output "website_domain" {
  value = "${aws_s3_bucket.ace_website.website_domain}"
}
output "website_endpoint" {
  value = "${aws_s3_bucket.ace_website.website_endpoint}"
}
output "hosted_zone_id" {
  value = "${aws_s3_bucket.ace_website.hosted_zone_id}"
}
