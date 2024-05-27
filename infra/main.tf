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
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"

    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "terraform"
  default_tags {
    tags = {
      Owner = "Jovan Drobnjak"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }


  registry {
    url      = join("", ["oci://", module.ecr.repository_url])
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}
