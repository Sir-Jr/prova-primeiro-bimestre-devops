# infra/backend/variables.tf

variable "aws_region" {
  description = "Região AWS (o Learner Lab só opera em us-east-1)"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "O AWS Academy Learner Lab só permite a região us-east-1."
  }
}

variable "project_name" {
  description = "Nome do projeto (tag Project)"
  type        = string
  default     = "technova-reservas"
}

variable "owner" {
  description = "RA do aluno responsável (tag Owner)"
  type        = string
  default     = "6325269"
}

variable "state_bucket_name" {
  description = "Nome do bucket S3 do remote state (único globalmente — o RA garante isso)"
  type        = string
  default     = "technova-reservas-tfstate-6325269"
}

variable "lock_table_name" {
  description = "Nome da tabela DynamoDB usada para o lock do state"
  type        = string
  default     = "technova-reservas-tf-lock"
}
