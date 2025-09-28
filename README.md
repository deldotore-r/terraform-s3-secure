# Bucket S3 Seguro com Terraform

> **Configurações de segurança S3 com otimização inteligente de custos, implementadas por meio de IaaS - Infrastructure as Code**

[![Terraform](https://img.shields.io/badge/terraform-v1.5+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-S3-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/s3/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Visão Geral

Este projeto demonstra uma implementação de bucket S3 com controles de segurança abrangentes e estratégias de otimização de custos. Construído como um exercício de aprendizado em Infrastructure as Code, apresenta práticas recomendadas do mundo real para segurança de armazenamento em nuvem.

### Recursos Principais

- **Segurança em Múltiplas Camadas**: Bloqueio completo de acesso público, políticas HTTPS-only e criptografia AES-256
- **Otimização de Custos**: Políticas inteligentes de ciclo de vida que podem reduzir custos em até 60%
- **Infrastructure as Code**: Configuração declarativa e reproduzível via Terraform
- **Configurações Parametrizáveis**: Variáveis com validação para diferentes ambientes
- **Documentação Completa**: Artigo técnico detalhado no LinkedIn documentando todo o processo

## Arquitetura de Segurança

### Configurações Implementadas

| Recurso | Configuração | Benefício |
|---------|-------------|-----------|
| **Encriptação** | AES-256 + Bucket Keys | Proteção de dados em repouso + redução de custos |
| **Acesso Público** | Bloqueio em 4 camadas | Prevenção total contra exposição acidental |
| **Transporte** | HTTPS obrigatório | Proteção de dados em trânsito |
| **Versionamento** | Habilitado | Recuperação de arquivos e proteção contra alterações |
| **Lifecycle** | Transições automáticas | Otimização de custos por classe de armazenamento |

### Política de Lifecycle

```
Dias 0-30:    STANDARD        (acesso frequente)
Dias 30-90:   STANDARD_IA     (68% mais econômico)
Dias 90+:     GLACIER         (77% mais econômico)
```

## Início Rápido

### Pré-requisitos

- [Terraform](https://www.terraform.io/downloads) v1.5+
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- Credenciais AWS com permissões S3

### Instalação e Deploy

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/terraform-s3-secure.git
cd terraform-s3-secure

# 2. Personalize as configurações
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com seus valores

# 3. Inicialize o Terraform
terraform init

# 4. Visualize o plano de execução
terraform plan

# 5. Aplique as configurações
terraform apply
```

### Configuração Rápida

```hcl
# terraform.tfvars
bucket_name              = "meu-bucket-seguro-001"
environment              = "dev"
project_name             = "meu-projeto"
aws_region               = "us-east-1"
enable_versioning        = true
enable_lifecycle_policy  = true
restrict_to_account_only = true
```

## Estrutura do Projeto

```
├── main.tf                # Recursos principais
├── variables.tf           # Definição das variáveis
├── outputs.tf             # Valores de saída
├── terraform.tfvars       # Configurações específicas
├── README.md              # Este arquivo
```

## Recursos Terraform

### Recursos Criados

- `aws_s3_bucket` - Bucket principal
- `aws_s3_bucket_versioning` - Configuração de versionamento
- `aws_s3_bucket_server_side_encryption_configuration` - Encriptação
- `aws_s3_bucket_public_access_block` - Bloqueio de acesso público
- `aws_s3_bucket_policy` - Políticas de segurança
- `aws_s3_bucket_lifecycle_configuration` - Otimização de custos

### Variáveis Disponíveis

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `bucket_name` | string | - | Nome do bucket (obrigatório) |
| `environment` | string | `"dev"` | Ambiente (dev/staging/prod) |
| `enable_versioning` | bool | `true` | Habilitar versionamento |
| `enable_lifecycle_policy` | bool | `true` | Habilitar otimização de custos |
| `restrict_to_account_only` | bool | `true` | Restringir à conta AWS atual |

## Destruição da Infraestrutura

```bash
# Remove todos os recursos criados
terraform destroy
```

⚠️ **Atenção**: Este comando remove permanentemente todos os recursos. Certifique-se de fazer backup dos dados importantes.

## Custo Estimado

### Cenário Típico (1TB)

| Configuração | Custo Mensal (USD) | Economia |
|--------------|-------------------|----------|
| **Sem lifecycle** | ~$23.00 | - |
| **Com lifecycle** | ~$9.20 | 60% |
| **Versionamento** | +$2-5.00 | Variável |
| **Encriptação** | +$0.01 | Mínimo |


## Documentação Adicional

- 📖 [Artigo Técnico Completo](https://www.linkedin.com/pulse/implementa%25C3%25A7%25C3%25A3o-segura-de-bucket-s3-com-terraform-do-ao-del-dotore-cduif/) - Case study detalhado

## Autor

**Seu Nome**
- LinkedIn: [seu-perfil](https://linkedin.com/in/reinaldo-del-dotore)
- GitHub: [@seu-usuario](https://github.com/deldotore-r)

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---

⭐ Se este projeto foi útil para você, considere dar uma estrela no GitHub!

**Tags**: `terraform` `aws` `s3` `security` `devops` `infrastructure-as-code` `cloud` `cost-optimization`
