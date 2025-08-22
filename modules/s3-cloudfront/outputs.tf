output "s3_bucket_id" {
  value = aws_s3_bucket.uploads.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.uploads.arn
}

output "s3_bucket_domain_name" {
  value = aws_s3_bucket.uploads.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  value = aws_s3_bucket.uploads.bucket_regional_domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.uploads.id
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.uploads.domain_name
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.uploads.arn
}