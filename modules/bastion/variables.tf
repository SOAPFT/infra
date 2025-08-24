variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where bastion host will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "rds_endpoint_host" {
  description = "RDS endpoint hostname for connection script"
  type        = string
}

variable "database_username" {
  description = "Database username for connection script"
  type        = string
}

variable "database_name" {
  description = "Database name for connection script"
  type        = string
}