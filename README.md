# Bucket S3 Seguro com Terraform

Projeto para criar um bucket Amazon S3 com configurações de segurança robustas usando Terraform via VSCode.

## 🔒 Recursos de Segurança

- ✅ **Encriptação AES-256** obrigatória
- ✅ **Bloqueio de acesso público** completo
- ✅ **HTTPS obrigatório** para todas as conexões
- ✅ **Versionamento** habilitado
- ✅ **Política restritiva** de acesso
- ✅ **Lifecycle policies** para otimização de custos
- ✅ **Logging de acesso** (opcional)

## 📁 Estrutura do Projeto

```
terraform-s3-secure/
├── main.tf          # Configuração principal
├── variables.tf     # Variáveis do projeto
├── outputs.tf       # Outputs após deployment
├── .gitignore       # Arquivos ignorados pelo Git
├── .env.example     # Template de variáveis de ambiente
└── README.md        # Esta documentação
```

## 🚀 Como Usar no VSCode

### 1. Pré-requisitos

```bash
# Instalar Terraform
# Windows (Chocolatey):
choco install terraform

# macOS (Homebrew):
brew install terraform

# Verificar instalação
terraform --version
```

### 2. Configurar AWS CLI

```bash
# Instalar AWS CLI
# Windows: https://aws.amazon.com/cli/
# macOS: brew install awscli

# Configurar credenciais
aws configure
```

### 3. Configurar Projeto

```bash
# 1. Criar diretório do projeto
mkdir terraform-s3-secure
cd terraform-s3-secure

# 2. Copiar os arquivos .tf fornecidos

# 3. Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com seus valores específicos
```

### 4. Deploy Manual via Terminal VSCode

```bash
# 1. Inicializar Terraform
terraform init

# 2. Validar configuração
terraform validate

# 3. Ver plano de execução
terraform plan

# 4. Aplicar mudanças (após revisar o plano)
terraform apply

# 5. Ver informações do bucket criado
terraform output
```

## ⚙️ Configuração via Variáveis de Ambiente

Edite o arquivo `.env` com suas configurações:

```bash
# Configuração obrigatória
TF_VAR_bucket_name=meu-bucket-unico-123456

# Configurações opcionais
TF_VAR_environment=dev
TF_VAR_project_name=meu-projeto
TF_VAR_aws_region=us-east-1
TF_VAR_enable_versioning=true
TF_VAR_enable_lifecycle_policy=true
TF_VAR_enable_access_logging=false
TF_VAR_restrict_to_account_only=true
```

## 📋 Comandos Essenciais

### Comandos Básicos

```bash
# Inicializar projeto
terraform init

# Planejar mudanças
terraform plan

# Aplicar mudanças
terraform apply

# Ver outputs
terraform output

# Destruir recursos (CUIDADO!)
terraform destroy
```

### Comandos Úteis

```bash
# Formatar código
terraform fmt

# Validar sintaxe
terraform validate

# Listar recursos no state
terraform state list

# Ver detalhes de um recurso
terraform state show aws_s3_bucket.secure_bucket

# Importar recurso existente
terraform import aws_s3_bucket.secure_bucket nome-do-bucket
```

## 🛠️ Personalização

### Habilitando Logging de Acesso

```bash
# No arquivo .env
TF_VAR_enable_access_logging=true
```

**Nota:** Isso criará um bucket adicional para armazenar logs de acesso.

### Mudando Configurações de Lifecycle

Edite as configurações no `main.tf`:

```hcl
# Transição para IA após X dias
transition {
  days          = 30  # Altere conforme necessário
  storage_class = "STANDARD_IA"
}
```

## 🔧 Troubleshooting

### Erro: "Bucket name already exists"

**Solução:** Altere `TF_VAR_bucket_name` para um nome único globalmente.

```bash
# Exemplo com timestamp
TF_VAR_bucket_name=meu-projeto-$(date +%s)
```

### Erro: "Access Denied"

**Solução:** Verifique suas credenciais AWS:

```bash
# Verificar identidade atual
aws sts get-caller-identity

# Reconfigurar se necessário
aws configure
```

### Erro: "Invalid bucket name"

**Solução:** Nome deve seguir regras do S3:
- Apenas letras minúsculas, números e hífens
- Começar e terminar com letra ou número
- Entre 3-63 caracteres

## 📊 Estimativa de Custos

Para um bucket com poucos dados:
- **Bucket vazio**: ~$0.00/mês
- **1GB de dados**: ~$0.023/mês
- **Requests**: ~$0.0004 por 1000 requests
- **Versionamento**: +20-30% nos custos de storage

## 🧹 Limpeza

Para remover todos os recursos:

```bash
terraform destroy
```

**⚠️ ATENÇÃO:** Esta operação é irreversível e apagará todos os dados!

## 📝 Dicas VSCode

### Extensions Recomendadas

- **HashiCorp Terraform** - Syntax highlighting e validação
- **AWS Toolkit** - Integração com AWS
- **GitLens** - Controle de versão aprimorado

### Configurações VSCode

Crie `.vscode/settings.json`:

```json
{
  "terraform.experimentalFeatures.validateOnSave": true,
  "terraform.experimentalFeatures.prefillRequiredFields": true,
  "files.associations": {
    "*.tf": "terraform"
  }
}
```

## 🔒 Checklist de Segurança

Antes do deployment em produção:

- [ ] Bucket name é único e não contém informações sensíveis
- [ ] Variáveis de ambiente estão no `.env` (não no código)
- [ ] `.env` está no `.gitignore`
- [ ] AWS credentials não estão no código
- [ ] Revisou o `terraform plan` antes do `apply`
- [ ] Testou acesso ao bucket após criação
- [ ] Configurou monitoramento (se necessário)

## 📚 Próximos Passos

1. **Monitoramento:** Configurar CloudWatch alarms
2. **Backup:** Implementar cross-region replication
3. **Automação:** Criar CI/CD pipeline
4. **Compliance:** Adicionar AWS Config rules

---

**Projeto criado para deployment via VSCode Terminal** 🚀