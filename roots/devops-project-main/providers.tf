provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    # bucket         = "project-x-state-bucket-staging" 
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraformlock"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }
  }
}