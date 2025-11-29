provider "aws" {
  region = var.region
}

# --------------------------
# S3 BUCKET (HOSTING)
# --------------------------
resource "aws_s3_bucket" "frontend" {
  bucket        = var.bucket_acortador   # Debe ser único en todo AWS
  force_destroy = true                    # Permite borrar contenido si destruyes el bucket
}

# Permitir hosting web
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Hacer bucket público
resource "aws_s3_bucket_acl" "public" {
  bucket = aws_s3_bucket.frontend.id
  acl    = "public-read"
}

# Política para permitir acceso público a todos los objetos
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

# --------------------------
# CLOUDFRONT DISTRIBUTION
# --------------------------
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "s3-origin"
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# --------------------------
# OUTPUTS
# --------------------------
output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
