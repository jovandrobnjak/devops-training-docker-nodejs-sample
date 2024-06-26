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
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
}

resource "helm_release" "todo_app" {
  name       = "jovand-todo-app"
  repository = join("", ["oci://", module.ecr.repository_registry_id, ".dkr.ecr.", var.aws_region, ".amazonaws.com"])
  chart      = "jovand-private-ecr"
  version    = "0.0.4"
  namespace  = "vegait-training"

  set {
    name  = "label"
    value = "todo"
  }
  set {
    name  = "service.protocol"
    value = "TCP"
  }
  set {
    name  = "service.target_port"
    value = 3000
  }
  set {
    name  = "service.port"
    value = 443
  }
  set {
    name  = "ingress.class"
    value = "alb"
  }
  set {
    name  = "ingress.host"
    value = "jovan-drobnjak.omega.devops.sitesstage.com"
  }
  set {
    name  = "ingress.path"
    value = "/"
  }
  set {
    name  = "ingress.path_type"
    value = "Prefix"
  }
  set {
    name  = "ingress.certificateArn"
    value = module.acm.acm_certificate_arn
  }

  set {
    name  = "secret.user"
    value = base64encode(lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string)), "username", "what?"))
  }
  set {
    name  = "secret.password"
    value = base64encode(lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string)), "password", "what?"))
  }
  set {
    name  = "secret.db"
    value = base64encode(lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string)), "dbname", "what?"))
  }
  set {
    name  = "configmap.port"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string)), "port", 0)
  }
  set {
    name  = "configmap.host"
    value = "jovand-psql-bitnami-postgresql-hl"
  }

  set {
    name  = "app.image"
    value = module.ecr.repository_url
  }
  set {
    name  = "app.tag"
    value = "docker-v1.6.2"
  }
  set {
    name  = "app.replica_count"
    value = 1
  }
  set {
    name  = "app.port"
    value = 3000
  }

}


resource "helm_release" "cluster_autoscaler" {
  name             = "jovand-cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "cluster-autoscaler"
  version          = "9.37.0"
  create_namespace = true

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_cluster_autoscaler_irsa.iam_role_arn
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler-sa"
  }
  set {
    name  = "rbac.serviceAccount.create"
    value = true
  }
  set {
    name  = "rbac.create"
    value = true
  }
}
