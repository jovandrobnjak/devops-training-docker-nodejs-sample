data "aws_availability_zones" "available_zones" {
  state = "available"
}

data "aws_route53_zone" "omage_hosted_zone" {
  name = "omega.devops.sitesstage.com"
}
