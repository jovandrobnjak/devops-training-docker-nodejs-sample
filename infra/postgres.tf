resource "helm_release" "bitnami_psql" {
  name       = "jovand-psql-bitnami"
  repository = "oci://registry-1.docker.io/bitnamicharts/postgresql"
  chart      = "my-release"
  namespace  = "vegait-training"
  version    = "15.3.2"

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
}
