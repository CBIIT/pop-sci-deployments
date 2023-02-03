module "dns" {
  source = "git::https://github.com/CBIIT/datacommons-devops.git//terraform/modules/route53?ref=v1.0"
  env = terraform.workspace
  alb_zone_id = module.alb.alb_zone_id
  alb_dns_name = module.alb.alb_dns_name
  application_subdomain = var.application_subdomain
  domain_name = var.domain_name
