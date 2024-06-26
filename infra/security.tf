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
                "ecr:GetAuthorizationToken",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:PutImage",
                "ecr:DescribeImages"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:AccessKubernetesApi",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "sts:AssumeRoleWithWebIdentity"
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

  role_policy_arns = [module.iam_policy.arn]

  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}

module "iam_load_balancer_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "jovand-irsa-lb"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["load-balancer:load-balancer-controller"]
    }
  }
}

module "iam_csi_driver_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "jovand-irsa-csi"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
module "iam_cluster_autoscaler_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "jovand-irsa-cluster-autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cluster-autoscaler:cluster-autoscaler-sa"]
    }
  }
}
