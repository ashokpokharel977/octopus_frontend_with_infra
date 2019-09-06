provider "aws" {}

resource "aws_s3_bucket" "auden_bucket" {
  bucket        = "${var.bucket_name}"
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
  bucket = "${aws_s3_bucket.auden_bucket.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.auden_bucket.arn}/*"
    }
  ]
}
EOF
}

output "s3_domain_name" {
  value = "${aws_s3_bucket.auden_bucket.bucket_regional_domain_name}"
}
