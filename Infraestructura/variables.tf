variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}

variable "bucket_acortador" {
  type        = string
  description = "Unique name for S3 bucket"
}
