# modules/ec2/main.tf

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  # IMDSv2 obrigatório: o metadata service só responde com token de sessão, o que protege as
  # credenciais do instance profile (LabInstanceProfile) contra SSRF
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
