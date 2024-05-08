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

module "subnet_addrs" {
  source          = "hashicorp/subnets/cidr"
  base_cidr_block = "172.18.0.0/16"
  networks = [
    {
      name     = "private-a"
      new_bits = 2
    },
    {
      name     = "private-b"
      new_bits = 2
    },
    {
      name     = "private-c"
      new_bits = 2
    },
    {
      name     = "public-a"
      new_bits = 8
    },
    {
      name     = "public-b"
      new_bits = 8
    },
    {
      name     = "public-c"
      new_bits = 8
    },
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-jovand-02"
  cidr = module.subnet_addrs.base_cidr_block
  azs  = data.aws_availability_zones.available_zones.names

  private_subnets        = [for key in local.private_subnet_keys : module.subnet_addrs.network_cidr_blocks[key]]
  public_subnets         = [for key in local.public_subnet_keys : module.subnet_addrs.network_cidr_blocks[key]]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  create_igw             = true

}
