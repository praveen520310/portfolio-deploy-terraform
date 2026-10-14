# S3 bucket for portfolio website
resource "aws_s3_bucket" "portfolio" {
  bucket = "praveen-devsecops-portfolio-2026-s3"

  tags = {
    Name        = "DevSecOps Portfolio Website"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 website hosting configuration (CloudFront uses the REST endpoint)
resource "aws_s3_bucket_website_configuration" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Allow CloudFront OAC to read S3 objects
resource "aws_s3_bucket_policy" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  policy = data.aws_iam_policy_document.portfolio_cloudfront_access.json

  depends_on = [
    aws_s3_bucket_public_access_block.portfolio
  ]
}

# Upload portfolio HTML
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "index.html"
  source       = "${path.module}/website/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/website/index.html")
}

# Upload CSS
resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "style.css"
  source       = "${path.module}/website/style.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/website/style.css")
}

# Upload JavaScript
resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "script.js"
  source       = "${path.module}/website/script.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/website/script.js")
}

# Upload profile image
resource "aws_s3_object" "image" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "profile.jpg"
  source       = "${path.module}/website/profile.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/website/profile.jpg")
}

# Output the CloudFront website URL
output "portfolio_website_url" {
  description = "HTTPS URL for the portfolio website"
  value       = "https://${aws_cloudfront_distribution.portfolio.domain_name}"
}