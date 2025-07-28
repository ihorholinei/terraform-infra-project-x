provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    # bucket         = "project-x-state-bucket-den-iho" 
    key            = "terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    # dynamodb_table = "terraformlock"
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