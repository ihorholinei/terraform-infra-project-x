terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "eks-project"
      ManagedBy   = "terraform"
    }
  }
}

module "vpc" {
  source = "../../vpc-module"

  vpc_cidr        = var.vpc_cidr
  vpc_name        = var.vpc_name
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}

module "eks" {
  source = "../../eks-module"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets

  instance_types = var.instance_types
  desired_size   = var.desired_size
  max_size       = var.max_size
  min_size       = var.min_size

  tags = merge(var.tags, {
    Environment = "dev"
    Project     = "eks-project"
  })

  depends_on = [module.vpc]
} 