variable "bucket_1_domain" {
  type    = "string"
  default = "randombucket2.s3.amazonaws.com"
}

variable "bucket_2_domain" {
  type    = "string"
  default = "randombucket2.s3.amazonaws.com"
}

variable "zone_id" {
  default = "Z2G8LLKFL1ORC"
}

variable "url_name" {
  type    = "string"
  default = "random.sandbox.tk"
}

variable "certificate_arn" {
  default = "arn:aws:acm:us-east-1:031342435657:certificate/a7bdc399-76c0-497d-8528-d11bb4963ede"
}
