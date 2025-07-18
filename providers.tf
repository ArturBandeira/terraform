terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      AMBIENTE      = var.ambiente
      RESPONSAVEL   = var.responsavel
      SCHEDULE      = var.schedule
    }
  }
}