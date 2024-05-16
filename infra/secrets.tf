module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  name = "jovand/postgres/credentials"

  ignore_secret_changes = true
  secret_string = jsonencode({
    username = ""
    password = ""
    dbname   = ""
    port     = 0
  })
}


data "aws_secretsmanager_secret_version" "current" {
  secret_id  = module.secrets_manager.secret_id
  version_id = module.secrets_manager.secret_version_id
}
