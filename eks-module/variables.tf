variable "project_name" {
  type        = string
  description = "Name of the project, used for resource naming and tagging."
}

variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., dev, staging, prod)."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EKS cluster and resources will be deployed."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC, used for internal access rules"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs where EKS control plane and nodes will be launched."
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version to use for the EKS cluster (e.g., 1.32)."
}

variable "ec2_types" {
  type        = list(string)
  description = "List of EC2 instance types to use in the worker node Auto Scaling Group."


  validation {
    condition     = length(var.ec2_types) >= 1
    error_message = "You must provide at least one EC2 instance type."
  }
}

variable "workers_min" {
  type        = number
  description = "Minimum number of worker nodes in the Auto Scaling Group."
}

variable "workers_max" {
  type        = number
  description = "Maximum number of worker nodes in the Auto Scaling Group."
}

variable "workers_desired" {
  type        = number
  description = "Desired number of worker nodes in the Auto Scaling Group."
}

variable "sso_admin_role_arn" {
  type        = string
  description = "IAM Role ARN for the AWS SSO administrator with access to the EKS cluster."
}

variable "github_ci_runner_role_arn" {
  type        = string
  description = "IAM Role ARN for the GitHub Actions CI/CD runner."
}

variable "github_tf_runner_role_arn" {
  type        = string
  description = "IAM Role ARN for the GitHub Actions Terraform deployment runner."
}