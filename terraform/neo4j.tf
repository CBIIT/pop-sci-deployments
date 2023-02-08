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
  tags = var.tags
}