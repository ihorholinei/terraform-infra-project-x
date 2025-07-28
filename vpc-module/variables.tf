variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., dev, staging, prod)."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC to be created"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of 3 CIDR blocks for the public subnets, one in each availability zone."

  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "Exactly 3 public subnet CIDRs must be provided."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of 3 CIDR blocks for the private subnets, one in each availability zone."


  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "Exactly 3 private subnet CIDRs must be provided."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of exactly 3 availability zones where public and private subnets will be deployed."

  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones must be provided."
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project, used for naming and tagging resources."
}