# infra/variables.tf

# ========================================
# Geral
# ========================================
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
  description = "Nome do projeto (prefixo dos recursos e tag Project)"
  type        = string
  default     = "technova-reservas"
}

variable "environment" {
  description = "Ambiente (tag Environment)"
  type        = string
  default     = "prova"
}

variable "owner" {
  description = "RA do aluno responsável (tag Owner)"
  type        = string
  default     = "6325269"
}

# ========================================
# Rede
# ========================================
variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subnets públicas e privadas em 2 AZs (design D5.3)"
  type = map(object({
    cidr = string
    az   = string
    type = string
  }))
  default = {
    public-1  = { cidr = "10.0.1.0/24", az = "us-east-1a", type = "public" }
    public-2  = { cidr = "10.0.2.0/24", az = "us-east-1b", type = "public" }
    private-1 = { cidr = "10.0.11.0/24", az = "us-east-1a", type = "private" }
    private-2 = { cidr = "10.0.12.0/24", az = "us-east-1b", type = "private" }
  }
}

variable "ssh_allowed_cidr" {
  description = "Seu IP público no formato x.x.x.x/32 (único que pode acessar a porta 22)"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && endswith(var.ssh_allowed_cidr, "/32")
    error_message = "ssh_allowed_cidr deve ser um único IP no formato x.x.x.x/32 (0.0.0.0/0 não é aceito)."
  }
}

# ========================================
# EC2
# ========================================
variable "instance_type" {
  description = "Tipo da instância da API"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair para SSH (padrão do Learner Lab)"
  type        = string
  default     = "vockey"
}

variable "iam_instance_profile" {
  description = "Instance profile pré-existente do Learner Lab (nenhum IAM é criado)"
  type        = string
  default     = "LabInstanceProfile"
}

variable "repo_url" {
  description = "Repositório público clonado pela EC2 para construir a imagem da API"
  type        = string
  default     = "https://github.com/Sir-Jr/prova-primeiro-bimestre-devops.git"
}

variable "repo_branch" {
  description = "Branch clonada pela EC2"
  type        = string
  default     = "main"
}

# ========================================
# RDS
# ========================================
variable "db_name" {
  description = "Nome do database da API"
  type        = string
  default     = "reservas"
}

variable "db_username" {
  description = "Usuário master do RDS"
  type        = string
  default     = "technova"
}

variable "db_password" {
  description = "Senha do usuário master (só letras e números; defina no terraform.tfvars, que não é versionado)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}
