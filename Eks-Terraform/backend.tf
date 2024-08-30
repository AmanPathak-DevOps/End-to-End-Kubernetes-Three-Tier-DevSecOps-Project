terraform {
  backend "s3" {
    bucket         = " three-tier.projects.2024"
    region         = "ap-south-1"
    key            = "https://github.com/Manojsiriparthi/End-to-End-Kubernetes-Three-Tier-DevSecOps-Project.git/Eks-Terraform/terraform.tfstate"
  }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}
