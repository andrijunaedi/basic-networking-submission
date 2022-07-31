variable "region" {
  description = "The AWS region to use"
  default     = "ap-southeast-1"
}

variable "profile" {
  description = "The AWS profile to use"
  default     = "default"
}

variable "vpc_name" {
  description = "The name of the VPC"
  default     = "dicoding-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC"
  default     = "10.0.0.0/16"
}

variable "public_key" {
  description = "The public key to use for SSH"
}

variable "private_key" {
  description = "The private key to use for SSH"
}
