resource "helm_release" "bitnami_psql" {
  name       = "jovand-psql-bitnami"
  repository = "oci://registry-1.docker.io/bitnamicharts/postgresql"
  chart      = "my-release"
  namespace  = "vegait-training"

  set {
    name  = "auth.username"
    value = "postgres"
  }
  set {
    name  = "auth.password"
    value = "postgres"
  }
  set {
    name  = "auth.database"
    value = "todo"
  }
  set {
    name  = "containerPorts.postgresql"
    value = 5432
  }
  set {
    name  = "primary.persistence.enabled"
    value = true
  }
  set {
    name  = "primary.persistence.volumeName"
    value = "jovand-postgres-pvc"
  }
}
