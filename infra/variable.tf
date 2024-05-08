variable "aws_access_key" {
  type      = string
  sensitive = true
}
variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}
variable "aws_session_token" {
  type      = string
  sensitive = true
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

locals {
  private_subnet_keys = ["private-a", "private-b", "private-c"]
  public_subnet_keys  = ["public-a", "public-b", "public-c"]
}
