resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name      = "jovand-postgres-db-pv"
    namespace = "vegait-training"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}


resource "helm_release" "bitnami_psql" {
  name       = "jovand-psql-bitnami"
  repository = "oci://registry-1.docker.io/bitnamicharts/postgresql"
  chart      = "my-release"
  namespace  = "vegait-training"

  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
  }
}
