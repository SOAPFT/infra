variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3000
}

variable "ec2_security_group_id" {
  description = "EC2 ECS security group ID for RDS access"
  type        = string
  default     = ""
}