# global variables
variable "program" {
  type        = string
  description = "the program name"
}

variable "project" {
  description = "name of the project"
  type        = string
}

variable "tags" {
  description = "tags to associate with this instance"
  type        = map(string)
}

variable "global_tags" {
  description = "tags to associate with all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "vpc id to to launch the ALB"
  type        = string
}

variable "region" {
  description = "aws region to use for this resource"
  type        = string
  default     = "us-east-1"
}

variable "private_subnet_ids" {
  description = "Provide list private subnets to use in this VPC. Example 10.0.10.0/24,10.0.11.0/24"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Provide list of public subnets to use in this VPC. Example 10.0.1.0/24,10.0.2.0/24"
  type        = list(string)
}

# ALB
variable "domain_name" {
  description = "domain name for the application"
  type        = string
}

variable "certificate_domain_name" {
  description = "domain name for the ssl cert"
  type        = string
}

variable "internal_alb" {
  description = "is this alb internal?"
  default     = false
  type        = bool
}

variable "lb_type" {
  description = "Type of loadbalancer"
  type        = string
  default     = "application"
}

# ECS
variable "microservices" {
  type = map(object({
    name                      = string
    port                      = number
    health_check_path         = string
    priority_rule_number      = number
    image_url                 = string
    cpu                       = number
    memory                    = number
    path                      = list(string)
    number_container_replicas = number
  }))
}

variable "add_opensearch_permission" {
  type        = bool
  default     = false
  description = "choose to create opensearch permission or not"
}

variable "application_subdomain" {
  description = "subdomain of the app"
  type        = string
}

# ECR
variable "central_ecr_account_id" {
  type        = string
  description = "central ecr account number"
}

# IAM
variable "iam_prefix" {
  type        = string
  default     = "power-user"
  description = "nci iam power user prefix"
}

# Monitoring
variable "sumologic_access_id" {
  type        = string
  description = "Sumo Logic Access ID"
}
variable "sumologic_access_key" {
  type        = string
  description = "Sumo Logic Access Key"
  sensitive   = true
}

# Newrelic Metrics
variable "account_level" {
  type        = string
  description = "whether the account is prod or non-prod"
}

variable "create_newrelic_pipeline" {
  type        = bool
  description = "whether to create the newrelic pipeline"
  default     = false
}

variable "newrelic_account_id" {
  type        = string
  description = "Newrelic Account ID"
  sensitive   = true
}

variable "newrelic_api_key" {
  type        = string
  description = "Newrelic API Key"
  sensitive   = true
}

variable "newrelic_s3_bucket" {
  type        = string
  description = "the bucket to use for failed metrics"
}

# Opensearch
variable "automated_snapshot_start_hour" {
  description = "hour when automated snapshot to be taken"
  type        = number
  default     = 23
}

variable "cluster_tshirt_size" {
  type        = string
  description = "Size of the OS cluster"
  default     = "xs"
}

variable "create_cloudwatch_log_policy" {
  description = "Due cloudwatch log policy limits, this should be option, we can use an existing policy"
  default     = false
  type        = bool
}

variable "create_os_service_role" {
  type        = bool
  default     = false
  description = "change this value to true if running this script for the first time"
}

variable "create_snapshot_role" {
  type        = bool
  description = "Whether to allow the opensearch module to create the snapshot role for the OpenSearch domain"
  default     = false
  sensitive   = false
}

variable "multi_az_enabled" {
  description = "set to true to enable multi-az deployment"
  type        = bool
  default     = false
}

variable "opensearch_version" {
  type        = string
  description = "specify es version"
  default     = "OpenSearch_1.3"
}

variable "s3_opensearch_snapshot_bucket" {
  type        = string
  description = "name of the S3 Opensearch snapshot bucket created in prod account"
  sensitive   = false
}

# S3
variable "alb_logging_account_id" {
  type        = map(string)
  description = "aws account to allow for alb s3 logging"
}

variable "aws_nonprod_account_id" {
  type        = map(string)
  description = "aws account to allow for cross account access"
}

variable "aws_prod_account_id" {
  type        = map(string)
  description = "aws account to allow for cross account access"
}

# Secrets
variable "secret_values" {
  type = map(object({
    secretKey   = string
    secretValue = map(string)
    description = string
  }))
}

#CloudFront
variable "create_cloudfront" {
  description = "create cloudfront or not"
  type = bool
  default = false
}

variable "alarms" {
  description = "alarms to be configured"
  type = map(map(string))
}

variable "slack_secret_name" {
  type = string
  description = "name of cloudfront slack secret"
}

variable "cloudfront_slack_channel_name" {
  type = string
  description = "cloudfront slack name"
}

variable "create_files_bucket" {
  description = "indicate if you want to create files bucket or use existing one"
  type = bool
  default = false
}

variable "stack_name" {
  description = "name of the project"
  type = string
  default = "popsci"
}

variable "target_account_cloudone"{
  description = "to add check conditions on whether the resources are brought up in cloudone or not"
  type        = bool
  default =   false
}

#S3 for CloudFront
variable "bucket_name" {
  description = "cloudfront s3 bucket name"
  type = string
  default = ""
}
variable "create_bucket_acl" {
  description = "create bucket acl or not"
  type = bool
  default = true
}

variable "s3_force_destroy" {
  description = "force destroy bucket"
  default = true
  type = bool
}