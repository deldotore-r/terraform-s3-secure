# variables.tf

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket S3 (deve ser globalmente único)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Nome do bucket deve conter apenas letras minúsculas, números e hífens, entre 3-63 caracteres."
  }
}

variable "environment" {
  description = "Ambiente de deployment"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Ambiente deve ser: dev, staging ou prod."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "s3-secure-project"
}

variable "enable_versioning" {
  description = "Habilitar versionamento do bucket"
  type        = bool
  default     = true
}

variable "enable_access_logging" {
  description = "Habilitar logging de acesso (cria bucket adicional para logs)"
  type        = bool
  default     = false
}

variable "enable_lifecycle_policy" {
  description = "Habilitar política de ciclo de vida para otimização de custos"
  type        = bool
  default     = true
}

variable "restrict_to_account_only" {
  description = "Restringir acesso apenas à conta AWS atual"
  type        = bool
  default     = true
}