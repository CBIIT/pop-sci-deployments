locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  https_port   = "443"
  bastion_port = 22
  neo4j_http = 7474
  neo4j_https = 7473
  neo4j_bolt = 7687
  redis = "6379"
  #nih_ip_cidrs =  terraform.workspace == "prod" || terraform.workspace == "stage" || var.cloud_platform == "leidos" ? ["0.0.0.0/0"]: [ "129.43.0.0/16" , "137.187.0.0/16"  , "165.112.0.0/16" , "156.40.0.0/16"  , "128.231.0.0/16" , "130.14.0.0/16" , "157.98.0.0/16"]
  nih_ip_cidrs  = ["0.0.0.0/0"]
  all_ips      =  var.cloud_platform == "leidos" ? ["0.0.0.0/0"] : local.nih_ip_cidrs
}
