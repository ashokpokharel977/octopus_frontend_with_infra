provider "aws" {}

terraform {
  backend "s3" {
    bucket = "auden-octopus-terraform-releasetour"
    region = "us-east-1"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin access identity for ${var.bucket_1} and ${var.bucket_2}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  aliases = ["${var.url_name}"]

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
    domain_name = "${var.bucket_1_domain}"
    origin_id   = "primaryS3"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  origin {
    domain_name = "${var.bucket_2_domain}"
    origin_id   = "failoverS3"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.bucket_1} and ${var.bucket_2}"
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
    acm_certificate_arn      = "${var.certificate_arn}"
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${var.zone_id}"
  name    = "${var.url_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = true
  }
}

output "cloudfrontid" {
  value = "${aws_cloudfront_distribution.s3_distribution.id}"
}

output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "url" {
  value = "${aws_route53_record.www.fqdn}"
}
