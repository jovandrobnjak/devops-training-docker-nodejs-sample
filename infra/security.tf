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

module "iam_github_oidc_provider" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"

  tags = {
    Owner = "Igor Kostin"
  }
}

module "iam_assumable_role_with_oidc" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  oidc_subjects_with_wildcards = ["repo:jovandrobnjak/devops-training-docker-nodejs-sample:*"]

  create_role = true

  role_name = "JovanDGithubActionRole"

  tags = {
    Role = "role-with-oidc"
  }

  provider_url = module.iam_github_oidc_provider.url

  number_of_role_policy_arns = 1

  role_policy_arns = [module.iam_policy.arn, "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]

  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "jovand-irsa-lb"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:devops-training-docker-nodejs-sample"]
    }
  }
}


module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "jovan-drobnjak.omega.devops.sitesstage.com"
  zone_id     = data.aws_route53_zone.omage_hosted_zone.zone_id

  validation_method = "DNS"

  wait_for_validation = true

}
