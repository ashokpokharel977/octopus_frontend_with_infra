# provider "aws" {
#   region = "us-east-1"
# }

terraform {
  backend "s3" {
    bucket = "auden-octopus-terraform-releasetour"
    region = "us-east-1"
  }
}

module "website_frontend_bucket_ireland" {
  source      = "./modules/s3bucket"
  bucket_name = "${var.bucket_name_1}"

  providers = {
    aws = "aws.ireland"
  }
}

module "website_frontend_bucket_london" {
  source      = "./modules/s3bucket"
  bucket_name = "${var.bucket_name_2}"

  providers = {
    aws = "aws.london"
  }
}

module "cloudfront_distribution" {
  source          = "./modules/cloudfront"
  bucket_1_domain = "${module.website_frontend_bucket_ireland.s3_domain_name}"
  bucket_2_domain = "${module.website_frontend_bucket_london.s3_domain_name}"
}
