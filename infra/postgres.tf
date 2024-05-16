resource "helm_release" "bitnami_psql" {
  name       = "jovand-psql-bitnami"
  repository = "oci://registry-1.docker.io/bitnamicharts/postgresql"
  chart      = "my-release"
  namespace  = "vegait-training"
  version    = "15.3.2"

  set {
    name  = "auth.username"
    value = jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string))["username"]
  }
  set {
    name  = "auth.password"
    value = jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string))["password"]
  }
  set {
    name  = "auth.database"
    value = jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string))["dbname"]
  }
  set {
    name  = "containerPorts.postgresql"
    value = jsondecode(sensitive(data.aws_secretsmanager_secret_version.current.secret_string))["port"]
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
