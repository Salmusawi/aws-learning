# Values printed after `terraform apply` (and any time with `terraform output`).

output "website_url" {
  description = "Open this in your browser"
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}

output "bucket_name" {
  description = "Name of the S3 bucket holding the site"
  value       = aws_s3_bucket.site.bucket
}
