resource "helm_release" "load_balancer_controller" {
  name       = "jovand-loadbalancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "load-balancer"
  version    = "1.7.2"


  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_load_balancer_irsa.iam_role_arn
  }

  set {
    name  = "defaultTargetType"
    value = "ip"
  }

  set {
    name  = "region"
    value = "eu-central-1"
  }
}
