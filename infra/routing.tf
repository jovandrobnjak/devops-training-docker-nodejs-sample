data "aws_route53_zone" "omage_hosted_zone" {
  name = "omega.devops.sitesstage.com"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "jovan-drobnjak.omega.devops.sitesstage.com"
  zone_id     = data.aws_route53_zone.omage_hosted_zone.zone_id

  validation_method = "DNS"

  wait_for_validation = true

}

resource "aws_route53_record" "todo_app" {
  zone_id = data.aws_route53_zone.omage_hosted_zone.zone_id
  name    = "jovan-drobnjak.omega.devops.sitesstage.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.load_balancer_source.dns_name
    zone_id                = data.aws_lb.load_balancer_source.zone_id
    evaluate_target_health = true
  }
}

data "kubernetes_service" "data_load_balancer" {
  metadata {
    name      = helm_release.load_balancer_controller.name
    namespace = helm_release.load_balancer_controller.namespace
  }
}

data "aws_lb" "load_balancer_source" {
  depends_on = [helm_release.load_balancer_controller]
  name       = "k8s-vegaittr-jovandto-95ab8df602"
}
