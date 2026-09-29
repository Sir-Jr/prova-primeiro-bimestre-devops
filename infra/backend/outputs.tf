# infra/backend/outputs.tf

output "state_bucket_name" {
  description = "Bucket S3 do remote state (usado no backend \"s3\" de infra/providers.tf)"
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN do bucket do remote state"
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "Tabela DynamoDB de lock (usada no backend \"s3\" de infra/providers.tf)"
  value       = aws_dynamodb_table.lock.name
}
