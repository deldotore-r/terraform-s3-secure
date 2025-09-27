# outputs.tf

output "bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.secure_bucket.id
}

output "bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.secure_bucket.arn
}

output "bucket_region" {
  description = "Região onde o bucket foi criado"
  value       = aws_s3_bucket.secure_bucket.region
}

output "bucket_domain_name" {
  description = "Nome de domínio do bucket"
  value       = aws_s3_bucket.secure_bucket.bucket_domain_name
}

output "versioning_enabled" {
  description = "Status do versionamento"
  value       = var.enable_versioning
}

output "encryption_enabled" {
  description = "Confirmação de que a encriptação está habilitada"
  value       = true
}

output "access_logs_bucket" {
  description = "Nome do bucket de logs (se habilitado)"
  value       = var.enable_access_logging ? aws_s3_bucket.access_logs_bucket[0].id : "Não habilitado"
}

output "public_access_blocked" {
  description = "Confirmação de que o acesso público está bloqueado"
  value       = true
}