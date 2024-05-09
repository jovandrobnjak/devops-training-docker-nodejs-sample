terraform {
  backend "s3" {
    bucket         = "jovand-terraform-state"
    key            = "terraform/state.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "jovand-terraform-lock"
    encrypt        = true
    profile        = "terraform"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "terraform"
  default_tags {
    tags = {
      Owner = "Jovan Drobnjak"
    }
  }
}

