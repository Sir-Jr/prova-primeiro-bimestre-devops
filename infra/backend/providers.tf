# infra/backend/providers.tf — aplicado ANTES do projeto principal, com state LOCAL
# (o terraform.tfstate deste diretório fica fora do Git pelo .gitignore)

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "prova"
      ManagedBy   = "terraform"
      Owner       = var.owner
      Purpose     = "terraform-remote-state"
    }
  }
}
