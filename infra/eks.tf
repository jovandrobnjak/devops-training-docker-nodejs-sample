module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.10"

  cluster_name    = "jovand-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    aws-ebs-csi-driver = {
      addon_version            = "v1.30.0-eksbuild.1"
      service_account_role_arn = module.iam_csi_driver_irsa.iam_role_arn
      resolve_conflicts        = "PRESERVE"
    }
  }
  access_entries = {
    github = {
      principal_arn = module.iam_assumable_role_with_oidc.iam_role_arn

      policy_associations = {
        github = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            namespaces = ["vegait-training"]
            type       = "namespace"
          }
        }
      }
    }
  }

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
      tags = {
        "k8s.io/cluster-autoscaler/enabled"        = true
        "k8s.io/cluster-autoscaler/jovand-cluster" = "jovand-node-group"
      }
    }
  }
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true
}


resource "kubernetes_storage_class" "eks_storage_class" {
  metadata {
    name = "jovand-storage-class"
  }
  depends_on = [module.eks]

  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    "encrypted" = "true"
  }
}
