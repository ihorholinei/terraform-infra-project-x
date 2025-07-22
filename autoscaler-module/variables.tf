variable "role_name" {
  type        = string
  description = "The name of the IAM role that will be created for the Cluster Autoscaler."
}

variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC identity provider associated with the EKS cluster."
}

variable "oidc_provider_url" {
  type        = string
  description = "The OIDC provider URL (without https://) used in IAM trust relationship conditions."
}

variable "serviceaccount_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "The name of the Kubernetes service account used by the Cluster Autoscaler."
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID in which the EKS cluster and IAM resources are deployed."
}

variable "oidc_sub" {
  description = "OIDC subject (service account)"
  type        = string
}