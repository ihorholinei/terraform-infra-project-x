variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster (one release prior to latest)"
  default     = "1.27"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be created"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the EKS cluster"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EKS nodes (Amazon EKS-optimized AMI)"
  default     = "ami-0c7217cdde317cfec" # Amazon EKS-optimized AMI for us-east-1
}

variable "instance_types" {
  type        = list(string)
  description = "List of instance types for the EKS nodes (t3.medium and similar)"
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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
} 