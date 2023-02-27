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
  all_ips =  var.cloud_platform == "leidos" ? ["0.0.0.0/0"] : local.nih_ip_cidrs
}
