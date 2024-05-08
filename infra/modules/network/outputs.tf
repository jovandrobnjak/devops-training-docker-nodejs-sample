output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc-jovand-02.id
  depends_on  = [aws_vpc.vpc-jovand-02]
}
output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.vpc-jovand-02.id
  depends_on  = [aws_vpc.vpc-jovand-02]
}

output "internet_gateway_id" {
  description = "ID for the internet gateway"
  value       = aws_internet_gateway.igw-jovand-02.id
  depends_on  = [aws_internet_gateway.igw-jovand-02]
}

output "nat_gateway_id" {
  description = "ID for the nat gateway"
  value       = aws_nat_gateway.nat-gw-jovand-02.id
  depends_on  = [aws_nat_gateway.nat-gw-jovand-02]
}

output "public_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.private_subnets[*].id
}
