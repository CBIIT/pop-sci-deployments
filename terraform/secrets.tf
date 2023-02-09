locals {

  dynamic_secrets = {
    app = {
      secretKey = ""
      description = ""
      secretValue = {
        es_host = var.create_opensearch_cluster ? module.opensearch[0].opensearch_endpoint : ""
        sumo_collector_token_frontend = module.monitoring.sumo_source_urls.frontend[0]
        sumo_collector_token_backend  = module.monitoring.sumo_source_urls.backend[0]
        sumo_collector_token_files    = module.monitoring.sumo_source_urls.files[0]
        sumo_collector_token_auth     = module.monitoring.sumo_source_urls.auth[0]
        sumo_collector_token_user     = module.monitoring.sumo_source_urls.users[0]
        aurora_cluster_endpoint       = module.aurora.cluster_endpoint
        aurora_db_password            = module.aurora.db_password
      }
    }
  }

}

#secrets
variable "secret_values" {
  type = map(object({
    app = map(string)
    description = string
    secretKey = string
    secretValue = map(string)
    neo4j_user = string
    neo4j_password = string
    neo4j_ip = string
    indexd_url = string
    sumo_collector_endpoint = string
  }))
}
module "deepmerge" {
  source  = "Invicton-Labs/deepmerge/null"
  maps = [
    local.dynamic_secrets,
    var.secret_values
  ]
}

module "secrets" {
  source                        = "git::https://github.com/CBIIT/datacommons-devops.git//terraform/modules/secrets?ref=v1.0"
  app                           = var.stack_name
  secret_values                 = module.deepmerge.merged
}
