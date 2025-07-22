variable "eks_resource_arns" {
  description = "List of EKS cluster ARNs or resource ARNs"
  type        = list(string)
}

variable "aws_account_id" {
  description = "AWS account ID allowed to assume this role"
  type        = string
  default     = "340924313311"
}