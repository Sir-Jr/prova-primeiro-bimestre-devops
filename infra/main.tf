# infra/main.tf — composição dos módulos (outputs de um alimentam inputs de outro)

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ========================================
# AMI Amazon Linux 2023 padrão (sempre a mais recente, sem ID fixo)
# "al2023-ami-2023.*" exige a versão logo após o prefixo: exclui as variantes
# "al2023-ami-minimal-*" e "al2023-ami-ecs-*", que o curinga "al2023-ami-*" também pegaria
# ========================================
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ========================================
# VPC — subnets públicas e privadas em 2 AZs
# ========================================
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
  subnets      = var.subnets
}

# ========================================
# Security Group da EC2 — SSH só do meu IP, API na 3000
# Composição: vpc_id ← módulo vpc
# ========================================
module "sg_ec2" {
  source = "./modules/security-group"

  name         = "${local.name_prefix}-ec2-sg"
  description  = "API na 3000 e SSH apenas do IP do administrador"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name

  ingress_rules = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "API de Reservas"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowed_cidr]
      description = "SSH do administrador"
    }
  ]
}

# ========================================
# Security Group do RDS — 5432 apenas a partir do SG da EC2
# Composição: vpc_id ← módulo vpc; origem ← módulo sg_ec2
# ========================================
module "sg_rds" {
  source = "./modules/security-group"

  name         = "${local.name_prefix}-rds-sg"
  description  = "PostgreSQL apenas a partir do SG da EC2"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name

  ingress_rules = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.sg_ec2.sg_id
      description              = "PostgreSQL a partir da EC2 da API"
    }
  ]
}

# ========================================
# RDS PostgreSQL — banco da API na nuvem, nas subnets privadas
# Composição: subnet_ids ← módulo vpc; security_group_ids ← módulo sg_rds
# ========================================
module "rds" {
  source = "./modules/rds"

  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.sg_rds.sg_id]
  instance_class     = var.db_instance_class
  environment        = var.environment
  project_name       = var.project_name
}

# ========================================
# EC2 da API — subnet pública, sobe a API em Docker apontando para o RDS
# Composição: subnet_id ← módulo vpc; security_group_ids ← módulo sg_ec2;
#             db_address/db_port ← módulo rds (entra no user_data, então o RDS é criado antes)
# ========================================
module "ec2" {
  source = "./modules/ec2"

  instance_name        = "${local.name_prefix}-api"
  instance_type        = var.instance_type
  ami_id               = data.aws_ami.amazon_linux.id
  subnet_id            = module.vpc.public_subnet_ids[0]
  security_group_ids   = [module.sg_ec2.sg_id]
  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile
  environment          = var.environment
  project_name         = var.project_name

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    repo_url    = var.repo_url
    repo_branch = var.repo_branch
    db_host     = module.rds.db_address
    db_port     = module.rds.db_port
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = var.db_password
  })
}
