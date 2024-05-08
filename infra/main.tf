terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Owner = "Jovan Drobnjak"
    }
  }
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}

module "network" {
  source = "./modules/network"
}

module "routing" {
  source     = "./modules/routing"
  depends_on = [module.network]

  vpc_cidr_block      = module.network.vpc_cidr_block
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_ids
  public_subnet_ids   = module.network.public_ids
  internet_gateway_id = module.network.internet_gateway_id
  nat_gateway_id      = module.network.nat_gateway_id
}
