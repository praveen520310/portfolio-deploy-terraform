# 1. Create S3 bucket
resource "aws_s3_bucket" "portfolio" {
  bucket = "praveen-devsecops-portfolio-2026-s3"

  tags = {
    Name        = "DevSecOps Portfolio Website"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# 2. Allow public access for static website hosting
resource "aws_s3_bucket_public_access_block" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 3. Enable static website hosting
resource "aws_s3_bucket_website_configuration" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# 4. Allow public read access to website files
resource "aws_s3_bucket_policy" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.portfolio.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.portfolio
  ]
}

# 5. Upload HTML
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "index.html"
  source       = "${path.module}/website/index.html"
  source_hash  = filemd5("${path.module}/website/index.html")
  content_type = "text/html"
}

# 6. Upload CSS
resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "style.css"
  source       = "${path.module}/website/style.css"
  source_hash  = filemd5("${path.module}/website/style.css")
  content_type = "text/css"
}

# 7. Upload JavaScript
resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "script.js"
  source       = "${path.module}/website/script.js"
  source_hash  = filemd5("${path.module}/website/script.js")
  content_type = "application/javascript"
}

# 8. Upload profile image
resource "aws_s3_object" "image" {
  bucket       = aws_s3_bucket.portfolio.id
  key          = "profile.jpg"
  source       = "${path.module}/website/profile.jpg"
  source_hash  = filemd5("${path.module}/website/profile.jpg")
  content_type = "image/jpeg"
}

# 9. Output the S3 website URL
output "portfolio_website_url" {
  description = "S3 static website endpoint"
  value       = "http://${aws_s3_bucket_website_configuration.portfolio.website_endpoint}"
}