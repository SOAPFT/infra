variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "enable_github_actions" {
  description = "Enable GitHub Actions role"
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repository (format: owner/repo)"
  type        = string
  default     = ""
}