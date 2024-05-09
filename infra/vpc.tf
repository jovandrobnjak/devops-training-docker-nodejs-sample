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
    {
      name     = "database-a"
      new_bits = 8
    },
    {
      name     = "database-b"
      new_bits = 8
    },
    {
      name     = "database-c"
      new_bits = 8
    },
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-jovand-02"
  cidr = module.subnet_addrs.base_cidr_block
  azs  = data.aws_availability_zones.available_zones.names

  private_subnets = [lookup(module.subnet_addrs.network_cidr_blocks, "private-a", "what?"),
    lookup(module.subnet_addrs.network_cidr_blocks, "private-b", "what?"),
    lookup(module.subnet_addrs.network_cidr_blocks, "private-c", "what?"),
  ]
  public_subnets = [lookup(module.subnet_addrs.network_cidr_blocks, "public-a", "what?"),
    lookup(module.subnet_addrs.network_cidr_blocks, "public-b", "what?"),
    lookup(module.subnet_addrs.network_cidr_blocks, "public-c", "what?"),
  ]
  database_subnets = [lookup(module.subnet_addrs.network_cidr_blocks, "database-a", "what?"),
    lookup(module.subnet_addrs.network_cidr_blocks, "database-b", "what?"),
  lookup(module.subnet_addrs.network_cidr_blocks, "database-c", "what?")]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  create_igw             = true

}
