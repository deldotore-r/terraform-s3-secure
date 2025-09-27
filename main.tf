# main.tf

terraform {
  required_version = ">= 1.0"
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
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedBy   = "VSCode"
    }
  }
}

# Data source para obter a conta AWS atual
data "aws_caller_identity" "current" {}

# Bucket S3 principal
resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Description = "Bucket S3 seguro criado com Terraform via VSCode"
  }
}

# Configuração de versionamento
resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Configuração de encriptação
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Bloqueio de acesso público
resource "aws_s3_bucket_public_access_block" "secure_bucket_pab" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuração de logging de acesso (condicional)
resource "aws_s3_bucket_logging" "secure_bucket_logging" {
  count = var.enable_access_logging ? 1 : 0

  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = aws_s3_bucket.access_logs_bucket[0].id
  target_prefix = "access-logs/"
}

# Bucket para logs de acesso (se habilitado)
resource "aws_s3_bucket" "access_logs_bucket" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = "${var.bucket_name}-access-logs"

  tags = {
    Name        = "${var.bucket_name}-access-logs"
    Description = "Bucket para logs de acesso do bucket principal"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs_bucket_pab" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Política do bucket
resource "aws_s3_bucket_policy" "secure_bucket_policy" {
  bucket = aws_s3_bucket.secure_bucket.id
  policy = data.aws_iam_policy_document.secure_bucket_policy.json
}

# Documento da política
data "aws_iam_policy_document" "secure_bucket_policy" {
  # Negar acesso não encriptado (HTTPS obrigatório)
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.secure_bucket.arn,
      "${aws_s3_bucket.secure_bucket.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Permitir acesso apenas da conta atual (se habilitado)
  dynamic "statement" {
    for_each = var.restrict_to_account_only ? [1] : []
    content {
      sid    = "AllowAccountAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }

      actions = ["s3:*"]

      resources = [
        aws_s3_bucket.secure_bucket.arn,
        "${aws_s3_bucket.secure_bucket.arn}/*"
      ]
    }
  }
}

# Configuração de ciclo de vida (se habilitado)
resource "aws_s3_bucket_lifecycle_configuration" "secure_bucket_lifecycle" {
  count  = var.enable_lifecycle_policy ? 1 : 0
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "main_lifecycle_rule"
    status = "Enabled"

    # ✅ Filtro adicionado - aplica a todos os objetos
    filter {
      prefix = ""
    }

    # Transição para IA após 30 dias
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Transição para Glacier após 90 dias
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Deletar versões antigas após 365 dias
    noncurrent_version_expiration {
      noncurrent_days = 365
    }

    # Deletar uploads multipart incompletos após 7 dias
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
