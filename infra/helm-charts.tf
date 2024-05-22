resource "helm_release" "bitnami_psql" {
  name             = "jovand-psql-bitnami"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "postgresql"
  namespace        = "vegait-training"
  version          = "15.3.2"
  create_namespace = true
  set {
    name  = "auth.username"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string)), "username", "what?")
  }
  set {
    name  = "auth.password"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string)), "password", "what?")
  }
  set {
    name  = "auth.database"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string)), "dbname", "what?")
  }
  set {
    name  = "containerPorts.postgresql"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string)), "port", 0)
  }
  set {
    name  = "primary.persistence.enabled"
    value = true
  }
  set {
    name  = "primary.persistence.volumeName"
    value = "jovand-postgres-pvc"
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "primary.persistence.storageClass"
    value = kubernetes_storage_class.eks_storage_class.metadata[0].name
  }
  set {
    name  = "primary.persistence.size"
    value = "8Gi"
  }
}

resource "helm_release" "load_balancer_controller" {
  name             = "jovand-loadbalancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "load-balancer"
  version          = "1.7.2"
  create_namespace = true
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

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
}
