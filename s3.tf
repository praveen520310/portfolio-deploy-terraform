# S3 bucket for portfolio static website
resource "aws_s3_bucket" "portfolio" {
  bucket = "praveen-devsecops-portfolio-2026-s3"

  tags = {
    Name        = "DevSecOps Portfolio Website"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Configure public access settings
resource "aws_s3_bucket_public_access_block" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Allow public access to website files
resource "aws_s3_bucket_policy" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  depends_on = [
    aws_s3_bucket_public_access_block.portfolio
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadWebsiteFiles"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.portfolio.arn}/*"
      }
    ]
  })
}

# Upload portfolio HTML
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "index.html"
  source       = "D:/Cloud_DevOps-Portfolio/index.html"
  content_type = "text/html"
  etag         = filemd5("D:/Cloud_DevOps-Portfolio/index.html")
}

# Upload CSS
resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "style.css"
  source       = "D:/Cloud_DevOps-Portfolio/style.css"
  content_type = "text/css"
  etag         = filemd5("D:/Cloud_DevOps-Portfolio/style.css")
}

# Upload JavaScript
resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "script.js"
  source       = "D:/Cloud_DevOps-Portfolio/script.js"
  content_type = "application/javascript"
  etag         = filemd5("D:/Cloud_DevOps-Portfolio/script.js")
}

# Upload profile image
resource "aws_s3_object" "image" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "profile.jpg"
  source       = "D:/Cloud_DevOps-Portfolio/profile.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("D:/Cloud_DevOps-Portfolio/profile.jpg")
}

# Output the static website URL
output "portfolio_website_url" {
  value = "http://${aws_s3_bucket_website_configuration.portfolio.website_endpoint}"
}