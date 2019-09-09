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
  default = "arn:aws:acm:us-east-1:031342435657:certificate/b39dd996-c66b-4ce0-9bc5-f56087dc56df"
}
