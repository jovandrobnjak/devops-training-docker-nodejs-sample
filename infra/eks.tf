module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "jovand-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["82.117.210.2/32"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    jovand-node-group = {
      create_iam_role = true
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
      ami_type     = "BOTTLEROCKET_x86_64"
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    jovand-access-entry = {
      kubernetes_groups = []
      principal_arn     = module.iam_assumable_role_with_oidc.iam_role_arn
    }
  }
}
