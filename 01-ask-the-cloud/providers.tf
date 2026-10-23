# Which Terraform and which provider plugins this project needs.
# `terraform init` reads this block and downloads the AWS provider.
terraform {
  required_version = ">= 1.17"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.70"
    }
  }
}

# How Terraform talks to AWS.
provider "aws" {
  region              = var.region # set in the variables.tf
  profile             = "personal"
  allowed_account_ids = ["165811308370"]

  default_tags {
    tags = {
      Project   = var.project_name # set in the variables.tf
      ManagedBy = "terraform"
    }
  }
}
