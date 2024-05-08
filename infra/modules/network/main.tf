resource "aws_vpc" "vpc-jovand-02" {
  cidr_block = "172.18.0.0/16"
}

resource "aws_subnet" "private_subnets" {
  count             = local.num_subnets
  vpc_id            = aws_vpc.vpc-jovand-02.id
  cidr_block        = cidrsubnet(aws_vpc.vpc-jovand-02.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.available-azs.names[count.index]
}

resource "aws_subnet" "public_subnets" {
  count             = local.num_subnets
  vpc_id            = aws_vpc.vpc-jovand-02.id
  cidr_block        = cidrsubnet(local.subnet_cidrs[3], 6, count.index)
  availability_zone = data.aws_availability_zones.available-azs.names[count.index]
}

resource "aws_internet_gateway" "igw-jovand-02" {
  vpc_id = aws_vpc.vpc-jovand-02.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gw-jovand-02" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.igw-jovand-02]
}

