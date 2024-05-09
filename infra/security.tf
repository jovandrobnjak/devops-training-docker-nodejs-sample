resource "aws_iam_policy" "ecr_policy" {
  name        = "github_action_policy"
  description = "Policy for pushing images into ECR with github action"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
        ],
        "Resource" : "*"
      }
    ]
  })
}

module "iam_assumable_role_with_oidc" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true

  role_name = "jovand-github-action"

  tags = {
    Role = "role-with-oidc"
  }

  provider_url = "https://token.actions.githubusercontent.com"

  role_policy_arns = [
    aws_iam_policy.ecr_policy.arn
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  number_of_role_policy_arns     = 1
}
