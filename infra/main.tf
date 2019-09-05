provider "aws" {

}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}
# terraform {
#   backend "s3" {
#     bucket = "auden-octopus-terraform-releasetour"
#     region = "us-east-1"
#   }
# }
resource "aws_s3_bucket" "auden_bucket_1" {
  bucket        = "${var.bucket_name_1}"
  provider      = "aws.ireland"
  region        = "eu-west-1"
  force_destroy = true
  tags = {
    Name = "Auden Bucket"
  }
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
resource "aws_s3_bucket_policy" "b1" {
  bucket     = "${aws_s3_bucket.auden_bucket_1.id}"
  provider   = "aws.ireland"
  depends_on = [aws_s3_bucket_policy.b1]
  policy     = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.auden_bucket_1.arn}/*"
    }
  ]
}
POLICY
}
resource "aws_s3_bucket" "auden_bucket_2" {
  bucket = "${var.bucket_name_2}"
  provider = "aws.london"
  region = "us-east-1"
  force_destroy = true
  tags = {
    Name = "Auden Bucket"
  }
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
resource "aws_s3_bucket_policy" "b2" {
  bucket = "${aws_s3_bucket.auden_bucket_2.id}"
  provider = "aws.london"
  depends_on = [aws_s3_bucket.auden_bucket_2]
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.auden_bucket_2.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin access identity for ${aws_s3_bucket.auden_bucket_1.id} and ${aws_s3_bucket.auden_bucket_2.id}"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin_group {
    origin_id = "groupS3"

    failover_criteria {
      status_codes = [403, 404, 500, 502]
    }

    member {
      origin_id = "primaryS3"
    }

    member {
      origin_id = "failoverS3"
    }
  }
  origin {
    domain_name = "${aws_s3_bucket.auden_bucket_1.bucket_regional_domain_name}"
    origin_id   = "primaryS3"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }
  origin {
    domain_name = "${aws_s3_bucket.auden_bucket_2.bucket_regional_domain_name}"
    origin_id   = "failoverS3"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${aws_s3_bucket.auden_bucket_1.id} and ${aws_s3_bucket.auden_bucket_2.id}"
  default_root_object = "index.html"
  wait_for_deployment = false
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "groupS3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "Test"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
output "cloudfrontid" {
  value = "${aws_cloudfront_distribution.s3_distribution.id}"
}
output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}
