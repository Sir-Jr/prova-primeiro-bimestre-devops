# modules/ec2/variables.tf

variable "instance_name" {
  description = "Nome da instância EC2 (tag Name)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID para a instância"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet onde a instância será criada"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de Security Group IDs associados à instância"
  type        = list(string)
}

variable "key_name" {
  description = "Nome do key pair para acesso SSH (opcional; no Learner Lab: vockey)"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "Instance profile já existente (no Learner Lab: LabInstanceProfile — o módulo não cria IAM)"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Script de inicialização (texto puro; opcional)"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Recriar a instância quando o user_data mudar (o cloud-init só roda no primeiro boot)"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto para tags"
  type        = string
}
