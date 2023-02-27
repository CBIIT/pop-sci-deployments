module "neo4j" {
  source = "git::https://github.com/CBIIT/datacommons-devops.git//terraform/modules/neo4j"
  env = terraform.workspace
  vpc_id = var.vpc_id
  db_subnet_id = var.private_subnet_ids[0]
  db_instance_volume_size = var.db_instance_volume_size
  public_ssh_key_ssm_parameter_name = var.public_ssh_key_ssm_parameter_name
  stack_name = var.stack_name
  db_private_ip = var.db_private_ip
  database_instance_type = var.database_instance_type
  Name = "popsci-backup-neo4j"
}


#create neo4j http ingress rule
resource "aws_security_group_rule" "neo4j_http" {
  from_port = local.neo4j_http
  protocol = local.tcp_protocol
  to_port = local.neo4j_http
  cidr_blocks = var.allowed_ip_blocks
  security_group_id = module.neo4j.db_security_group_id
  type = "ingress"
}

#create bastion host ingress rule
resource "aws_security_group_rule" "bastion_host_ssh" {
  from_port = local.bastion_port
  protocol = local.tcp_protocol
  to_port = local.bastion_port
  source_security_group_id = var.bastion_host_security_group_id
  security_group_id = module.neo4j.db_security_group_id
  type = "ingress"
}

#create neo4j https ingress rule
resource "aws_security_group_rule" "neo4j_https" {
  from_port = local.neo4j_https
  protocol = local.tcp_protocol
  to_port = local.neo4j_https
  cidr_blocks = var.allowed_ip_blocks
  security_group_id = module.neo4j.db_security_group_id
  type = "ingress"
}

#create neo4j bolt https ingress rule
resource "aws_security_group_rule" "neo4j_bolt" {
  from_port = local.neo4j_bolt
  protocol = local.tcp_protocol
  to_port = local.neo4j_bolt
  cidr_blocks = var.allowed_ip_blocks
  security_group_id = module.neo4j.db_security_group_id
  type = "ingress"
}

#create neo4j egress rule
resource "aws_security_group_rule" "neo4j_outbound" {
  from_port = local.any_port
  protocol = local.any_protocol
  to_port = local.any_port
  cidr_blocks = local.all_ips
  security_group_id = module.neo4j.db_security_group_id
  type = "egress"
}

#create dataloader http ingress rule
resource "aws_security_group_rule" "dataloader_http_inbound" {
  from_port = local.neo4j_http
  protocol = local.tcp_protocol
  to_port = local.neo4j_http
  source_security_group_id = var.bastion_host_security_group_id
  security_group_id = module.neo4j.db_security_group_id
  type = "ingress"
}

#create dataloader bolt ingress rule
resource "aws_security_group_rule" "dataloader_bolt_inbound" {
  from_port = local.neo4j_bolt
  protocol = local.tcp_protocol
  to_port = local.neo4j_bolt
  source_security_group_id = var.bastion_host_security_group_id
  security_group_id = module.neo4j.db_security_group_id
  type = "ingress"
}

#create katalon bolt ingress rule
resource "aws_security_group_rule" "katalon_bolt_inbound" {
  from_port = local.neo4j_bolt
  protocol = local.tcp_protocol
  to_port = local.neo4j_bolt
  source_security_group_id = var.katalon_security_group_id
  security_group_id = module.neo4j.db_security_group_id
  type = "ingress"
}
#create katalon http ingress rule
resource "aws_security_group_rule" "katalon_http_inbound" {
  from_port = local.neo4j_http
  protocol = local.tcp_protocol
  to_port = local.neo4j_http
  source_security_group_id = var.katalon_security_group_id
  security_group_id = module.neo4j.db_security_group_id
  type = "ingress"
}