variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "vpc_name" {
  type        = string
  description = "Name prefix for VPC resources"
  default     = "main"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to use"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDRs"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

# EKS Variables
variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "dev-eks-cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
  default     = "1.27"
}

variable "instance_types" {
  type        = list(string)
  description = "List of instance types for the EKS nodes"
  default     = ["t3.medium", "t3.small", "t3.micro"]
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 3
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 5
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 1
} 