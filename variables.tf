variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "soapft"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "database_name" {
  description = "RDS database name"
  type        = string
  default     = "soapft_dev_db"
}

variable "database_username" {
  description = "RDS master username"
  type        = string
  default     = "soapft_admin"
}

variable "database_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 7777
}

variable "container_cpu" {
  description = "Container CPU units"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Container memory"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "domain_name" {
  description = "Domain name for the API (e.g., api.ounwan.site)"
  type        = string
  default     = "api.ounwan.site"
}

variable "root_domain_name" {
  description = "Root domain name (e.g., ounwan.site)"
  type        = string
  default     = "ounwan.site"
}

variable "enable_https" {
  description = "Enable HTTPS with ACM certificate"
  type        = bool
  default     = true
}

variable "enable_bastion" {
  description = "Enable bastion host for database access"
  type        = bool
  default     = false
}

variable "use_ec2" {
  description = "Use EC2 instead of Fargate for ECS"
  type        = bool
  default     = true
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access (optional)"
  type        = string
  default     = null
}