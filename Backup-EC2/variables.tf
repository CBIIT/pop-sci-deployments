
variable "stack_name" {
  description = "name of the project"
  type = string
}
variable "tags" {
  description = "tags to associate with this instance"
  type = map(string)
}

variable "vpc_id" {
  description = "vpc id to to launch the ALB"
  type        = string
}

variable "region" {
  description = "aws region to use for this resource"
  type = string
  default = "us-east-1"
}
variable "public_subnet_ids" {
  description = "Provide list of public subnets to use in this VPC. Example 10.0.1.0/24,10.0.2.0/24"
  type = list(string)
}

variable "private_subnet_ids" {
  description = "Provide list private subnets to use in this VPC. Example 10.0.10.0/24,10.0.11.0/24"
  type = list(string)
}
variable "allowed_ip_blocks" {
  description = "allowed ip block for the opensearch"
  type = list(string)
  default = []
}
variable "create_os_service_role" {
  type = bool
  default = false
  description = "change this value to true if running this script for the first time"
}
variable "create_dns_record" {
  description = "choose to create dns record or not"
  type = bool
  default = true
}
variable "bastion_host_security_group_id" {
  description = "security group id of the bastion host"
  type = string
  default = "sg-0c94322085acbfd97"
}
variable "katalon_security_group_id" {
  description = "security group id of the bastion host"
  type = string
  default = "sg-0f07eae0a9b3a0bb8"
}

variable "db_subnet_id" {
  description = "subnet id to launch db"
  type = string
  default = ""
}

variable "db_instance_volume_size" {
  description = "volume size of the instances"
  type = number
  default = 100
}
variable "ssh_user" {
  type = string
  description = "name of the ec2 user"
  default = "bento"
}
variable "db_private_ip" {
  description = "private ip of the db instance"
  type = string
  default = "10.0.0.2"
}
variable "ssh_key_name" {
  description = "name of the ssh key to manage the instances"
  type = string
  default = "devops"
}
variable "public_ssh_key_ssm_parameter_name" {
  description = "name of the ssm parameter holding ssh key content"
  default = "ssh_public_key"
  type = string
}
variable "create_db_instance" {
  description = "set this value if you want create db instance"
  default = true
  type = bool
}
variable "database_instance_type" {
  description = "ec2 instance type to use"
  type        = string
  default     = "t3.large"
}
variable "target_account_cloudone"{
  description = "to add check conditions on whether the resources are brought up in cloudone or not"
  type        = bool
  default =   false
}
variable "iam_prefix" {
  type = string
  default = "power-user"
  description = "nci iam power user prefix"
}
variable "create_instance_profile" {
  type = bool
  default = false
  description = "set to create instance profile"
}

variable "db_subnet_ids" {
  type        = list(string)
  default     = []
  description = "list of subnet IDs to usee"
}

variable "cloud_platform=" {
  type        = string
  default     = "leidos"
}
