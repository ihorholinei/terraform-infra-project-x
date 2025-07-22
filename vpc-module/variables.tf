variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDRs"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to use"
}

variable "vpc_name" {
  type        = string
  description = "Name prefix for VPC resources"
  default     = "main"
}

variable "tags" {
  type        = map(string)
  default     = {}
} 