resource "aws_route_table" "rt-jovand-public-02" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
}

resource "aws_route_table" "rt-jovand-private-02" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.nat_gateway_id
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  route_table_id = aws_route_table.rt-jovand-public-02.id
  subnet_id      = var.public_subnet_ids[count.index]
}

resource "aws_route_table_association" "private" {
  count          = 3
  route_table_id = aws_route_table.rt-jovand-private-02.id
  subnet_id      = var.private_subnet_ids[count.index]
}
