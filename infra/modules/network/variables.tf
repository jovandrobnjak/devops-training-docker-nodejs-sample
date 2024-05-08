data "aws_availability_zones" "available-azs" {
  state = "available"
}

locals {
  num_subnets = 3

  subnet_cidrs = cidrsubnets(aws_vpc.vpc-jovand-02.cidr_block, 2, 2, 2, 2)
}
