# variable "greeting" {
#   description = "A greeting phrase"
# }
# variable "project" {}
variable "environment" {}
# variable "vpc_id" {}
# variable "private_subnet_ids" {
#   type = list(string)
# }
# variable "eks_nodes_sg_id" {}
variable "enable_condition" {
  description = "Set to true to enable provisioning of this module's resources; set to false to skip creation. Useful for controlling deployments in multi-module or multi-environment setups."
  type        = bool
  default     = false
}

#Variables for ReadOnlyIAMRole
# variable "eks_resource_arns" {
#   description = "List of EKS cluster ARNs or resource ARNs"
#   type        = list(string)
# }

variable "aws_account_id" {
  description = "AWS account ID that is allowed to assume the ReadOnly Cluster Role; also where the EKS cluster and other IAM resources are provisioned"
  type        = string
}

# variable "role_name" {
#   type        = string
#   description = "The name of the IAM role to be created for the Cluster Autoscaler."
# }

# variable "serviceaccount_name" {
#   type        = string
#   description = "The name of the Kubernetes service account used by the Cluster Autoscaler."
# }

# variable "oidc_provider_url" {
#   type        = string
#   description = "The OIDC provider URL associated with the EKS cluster, without the https:// prefix."
# }

# variable "oidc_provider_arn" {
#   type        = string
#   description = "The ARN of the OIDC provider linked to the EKS cluster."
# }

# variable "oidc_sub" {
#   description = "OIDC subject (наприклад system:serviceaccount:kube-system:cluster-autoscaler)"
#   type        = string
# }
variable "project_name" {
  type        = string
  description = "Name of the project, used for resource naming and tagging."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of 3 CIDR blocks for the public subnets (one per AZ)."

  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "Exactly 3 public subnet CIDRs must be provided."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of 3 CIDR blocks for the private subnets (one per AZ)."

  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "Exactly 3 private subnet CIDRs must be provided."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of 3 AWS Availability Zones to distribute subnets across."

  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones must be provided."
  }
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version to use for the EKS cluster"
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
  description = "IAM Role ARN for the SSO admin user to access the EKS cluster."
}

variable "github_ci_runner_role_arn" {
  type        = string
  description = "IAM Role ARN for GitHub Actions CI runner (used for deploying workloads)."
}

variable "github_tf_runner_role_arn" {
  type        = string
  description = "IAM Role ARN for GitHub Actions Terraform runner (used for provisioning infrastructure)."
}

variable "ec2_types" {
  type        = list(string)
  description = "List of EC2 instance types for worker nodes (used in ASG mixed instances)."

  validation {
    condition     = length(var.ec2_types) >= 1
    error_message = "You must provide at least one EC2 instance type."
  }
}

# variable "oidc_provider_id" {
#   description = "OIDC provider ID for EKS cluster"
#   type        = string
# }

# variable "external_dns_sa_namespace" {
#   description = "Namespace of the external-dns ServiceAccount"
#   type        = string
# }

# variable "external_dns_sa_name" {
#   description = "Name of the external-dns ServiceAccount"
#   type        = string
# }

// ********** RDS Variabes **********
# variable "versus_db_instance_class" {
#   description = "DB instance class for Versus MySQL"
#   type        = string
# }

# variable "versus_db_allocated_storage" {
#   description = "Allocated storage in GB for Versus MySQL DB"
#   type        = number
# }

# variable "versus_db_username" {
#   description = "Database username for Versus MySQL"
#   type        = string
# }

# variable "rds_private_subnet_ids" {
#   description = "Private subnet IDs for RDS subnet group"
#   type        = list(string)
# }

# variable "multi_az" {
#   description = "Enable Multi-AZ deployment for MySQL"
#   type        = bool
# }

# variable "eks_security_group_ids" {
#   description = "EKS security group IDs allowed to access RDS"
#   type        = list(string)
# }

# variable "alert_email" {
#   description = "Email Alert"
#   type        = string
# }

# variable "cpu_threshold" {
#   description = "CPU utilization threshold for RDS CloudWatch alarm"
#   type        = number
# }

# variable "versus_db_name" {
#   description = "The initial database name for Versus MySQL"
#   type        = string
#   default     = "versusdb"
# }

# variable "engine_version" {
#   description = "The engine version of MySQL Database"
#   type        = string
# }

# variable "mysql_parameter_group_name" {
#   description = "Parameter group name of MySQL Database"
#   type        = string
# }