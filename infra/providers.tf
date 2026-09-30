# infra/providers.tf — provider AWS + backend remoto (S3 + DynamoDB), criado antes em infra/backend/

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend não aceita variáveis: os nomes repetem os defaults de infra/backend/variables.tf
  backend "s3" {
    bucket         = "technova-reservas-tfstate-6325269"
    key            = "prova/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "technova-reservas-tf-lock"
  }
}

provider "aws" {
  region = var.aws_region

  # Tags em todos os recursos (R7.7); os módulos acrescentam Name/Type
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}
