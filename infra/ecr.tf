module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "jovand-private-ecr"

  repository_read_write_access_arns = [module.iam_assumable_role_with_oidc.iam_role_arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_ecr_authorization_token" "token" {
  registry_id = module.ecr.repository_registry_id
}
