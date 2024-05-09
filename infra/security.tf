module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "JovanDGithubActionPolicy"
  description = "Policy for pushing images into ECR with GitHub Actions"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ecr:CompleteLayerUpload",
              "ecr:GetAuthorizationToken",
              "ecr:UploadLayerPart",
              "ecr:InitiateLayerUpload",
              "ecr:BatchCheckLayerAvailability",
              "ecr:PutImage"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]

  tags = {
    Owner = "Igor Kostin"
  }
}
import {
  id = "arn:aws:iam::162340708442:oidc-provider/token.actions.githubusercontent.com"
  to = aws_iam_openid_connect_provider.github
}
module "iam_assumable_role_with_oidc" {
  depends_on = [module.iam_policy]
  source     = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  oidc_subjects_with_wildcards = ["repo:jovandrobnjak/devops-training-docker-nodejs-sample:*"]

  create_role = true

  role_name = "JovanDGithubActionRole"

  tags = {
    Role = "role-with-oidc"
  }

  provider_url = aws_iam_openid_connect_provider.github.url

  number_of_role_policy_arns = 1

  role_policy_arns = [module.iam_policy.arn]

  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}
