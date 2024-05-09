data "aws_availability_zones" "available_zones" {
  state = "available"
}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = "https://token.actions.githubusercontent.com"
}
