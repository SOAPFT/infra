terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # 백엔드 설정은 환경별로 다르게 설정
    # terraform init -backend-config="backend.tfvars" 사용
  }
}