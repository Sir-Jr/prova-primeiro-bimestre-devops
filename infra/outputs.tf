# infra/outputs.tf

output "ec2_public_ip" {
  description = "IP público da EC2 da API"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do RDS PostgreSQL (host:porta) — acessível só a partir da EC2"
  value       = module.rds.db_endpoint
}

output "api_url" {
  description = "URL base da API de Reservas"
  value       = "http://${module.ec2.public_ip}:3000"
}

output "health_url" {
  description = "Health check da API"
  value       = "http://${module.ec2.public_ip}:3000/health"
}

output "ssh_command" {
  description = "Acesso SSH à EC2 (chave labsuser.pem baixada do AWS Details do Lab)"
  value       = "ssh -i labsuser.pem ec2-user@${module.ec2.public_ip}"
}
