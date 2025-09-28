# Implementação segura de bucket S3 com Terraform: do deploy ao destroy.

Este artigo documenta a jornada desde a concepção até a destruição completa de uma infraestrutura de bucket S3 seguro utilizando Terraform, destacando as configurações de segurança implementadas e as otimizações de custo aplicadas.

**Nota:** Este documento foi adaptado de um artigo original que continha imagens. As referências visuais foram removidas para esta versão em texto.

## O contexto: por que Terraform ao invés do console AWS?

Antes de mergulharmos na implementação, é importante entender por que escolhi o Terraform ao invés de simplesmente criar o bucket por meio do console da AWS.

O console AWS é a interface gráfica onde você clica em botões para criar recursos. É como usar um aplicativo no seu celular - visual e intuitivo. O Terraform, por outro lado, é uma ferramenta que usa código (texto) para criar e gerenciar recursos na nuvem.

### Vantagens do Terraform sobre o console:

*   **Reprodutibilidade:** Uma vez criado o código, posso replicar exatamente a mesma infraestrutura quantas vezes quiser (e em clouds diferentes, como Microsoft Azure ou Google Cloud, com poucos ajustes).
*   **Documentação viva:** O código serve como documentação de como a infraestrutura foi construída.
*   **Automação:** Pode ser integrado a pipelines de CI/CD para deploys automatizados.
*   **Prevenção de erros:** Valida a configuração antes de aplicar as mudanças.
*   **Economia de tempo:** Evita cliques repetitivos e configurações manuais propensas a erros.

## Arquitetura da solução.

Minha implementação seguiu uma estrutura modular com quatro arquivos principais:

*   `main.tf`: Contém os recursos principais e suas configurações.
*   `variables.tf`: Define as variáveis de entrada com validações.
*   `outputs.tf`: Especifica os valores de saída após o deploy.
*   `terraform.tfvars`: Valores específicos para este ambiente.

Acesse aqui o repositório Github com os arquivos.

## Análise das configurações de segurança.

### 1. Encriptação Server-Side (AES256).

```terraform
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}
```

Esta configuração força todos os objetos armazenados no bucket a serem automaticamente criptografados usando o algoritmo AES-256. É como se cada arquivo que você colocasse numa gaveta fosse automaticamente trancado com uma chave segura. Mesmo se alguém conseguisse acesso físico aos servidores da Amazon, não conseguiria ler seus arquivos.

**Benefício de custo:** O `bucket_key_enabled = true` reduz os custos de criptografia ao reutilizar chaves de criptografia, diminuindo as chamadas para o AWS KMS.

### 2. Bloqueio total de acesso público.

```terraform
resource "aws_s3_bucket_public_access_block" "secure_bucket_pab" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

Estas configurações criam uma barreira em quatro camadas, impedindo qualquer forma de acesso público ao bucket, seja através de ACLs, políticas, ou outras configurações. É como ter quatro tipos diferentes de fechaduras na mesma porta. Mesmo que você acidentalmente tente deixar algo público, o sistema impede automaticamente.

### 3. Política de bucket com HTTPS obrigatório.

```terraform
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
```

Esta política nega explicitamente qualquer operação que não use HTTPS, garantindo que todos os dados em trânsito sejam criptografados. É como uma regra que diz "só aceito conversas por telefone seguro". Se alguém tentar se comunicar com seu bucket de forma insegura, a conexão é automaticamente rejeitada.

### 4. Versionamento habilitado.

```terraform
resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}
```

O versionamento mantém múltiplas versões de cada objeto, permitindo recuperação em caso de alterações acidentais ou corrupção. É como ter um histórico automático de todas as versões dos seus arquivos, similar ao "Control+Z" do Word, mas muito mais poderoso.

## Outras otimizações de custos implementadas.

### Política de ciclo de vida inteligente.

```terraform
resource "aws_s3_bucket_lifecycle_configuration" "secure_bucket_lifecycle" {
  rule {
    id     = "main_lifecycle_rule"
    status = "Enabled"
    
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
```

Esta configuração move automaticamente os dados para classes de armazenamento mais baratas conforme eles envelhecem, balanceando custo e acessibilidade. É como organizar automaticamente seus documentos: os mais recentes ficam na mesa (acesso rápido, mais caro), os de mês passado vão para uma gaveta próxima (acesso médio, preço médio), e os muito antigos vão para o arquivo no porão (acesso lento, muito barato).

**Estratégia de otimização por camadas:**

*   **Primeiros 30 dias:** STANDARD (acesso frequente esperado).
*   **30-90 dias:** STANDARD_IA (acesso infrequente, 68% mais barato).
*   **Após 90 dias:** GLACIER (arquivamento, 77% mais barato).
*   **Limpeza automática:** Remove uploads incompletos e versões muito antigas.

**Impacto financeiro estimado:** Para um cenário típico de 1TB de dados, esta estratégia pode gerar uma economia de até 60% nos custos de armazenamento ao longo de um ano.

## O processo de implementação: passo a passo.

### Pré-requisito: instalação do Terraform.

Antes de começar, é necessário ter o Terraform instalado na máquina. Aqui estão as opções mais comuns:

#### Instalação no Windows.

**Opção 1: Download direto.**

```bash
# 1. Baixe o Terraform do site oficial
# https://www.terraform.io/downloads

# 2. Extraia o arquivo ZIP para uma pasta (ex: C:\terraform)
# 3. Adicione a pasta ao PATH do sistema
$env:PATH += ";C:\terraform"

# 4. Verifique a instalação
terraform version
```

**Opção 2: Chocolatey**

```bash
choco install terraform
```

**Opção 3: Winget**

```bash
winget install HashiCorp.Terraform
```

#### Instalação no macOS.

**Opção 1: Homebrew (mais comum).**

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Opção 2: download manual.**

```bash
# Similar ao Windows, baixar, extrair e adicionar ao PATH
export PATH="$PATH:/usr/local/bin/terraform"
```

#### Instalação no Linux (Ubuntu/Debian).

```bash
# Adiciona o repositório HashiCorp
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Instala o Terraform
sudo apt update && sudo apt install terraform
```

#### Verificação da instalação.

Independentemente do método escolhido, confirme que a instalação foi bem-sucedida:

```bash
terraform version
```

**Output esperado:**

```
Terraform v1.5.x
on windows_amd64  # ou linux_amd64, darwin_amd64
```

### Pré-requisito: configuração das credenciais AWS.

Além do Terraform, você precisa configurar as credenciais da AWS:

**Opção 1: AWS CLI (recomendado).**

```bash
# Instale o AWS CLI e configure
aws configure
```

**Opção 2: Variáveis de ambiente.**

```bash
export AWS_ACCESS_KEY_ID="sua-access-key"
export AWS_SECRET_ACCESS_KEY="sua-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Opção 3: Arquivo de credenciais.**

```
# Crie o arquivo ~/.aws/credentials
[default]
aws_access_key_id = sua-access-key
aws_secret_access_key = sua-secret-key
region = us-east-1
```

### Implementação (criação do bucket).

#### Fase 1: inicialização do Terraform.

```bash
terraform init
```

Durante esta fase, o Terraform:

*   Baixa o provider da AWS (versão ~> 5.0).
*   Cria o arquivo de estado (`.terraform.lock.hcl`).
*   Prepara o ambiente para execução.

#### Fase 2: planejamento e validação.

```bash
terraform plan
```

O comando `plan` revelou exatamente quais recursos seriam criados:

*   1 bucket principal (`safe-bucket-rdd01`).
*   Regras de ciclo de vida.
*   Políticas de segurança.
*   Bloqueio de acesso público.
*   Configurações de encriptação.
*   Configurações de versionamento.

**Insight importante:** O Terraform mostrou que criaria exatamente 6 recursos, permitindo validar antes da execução real, e ao final pergunta: você quer mesmo aplicar este plano?

#### Fase 3: aplicação das configurações.

```bash
terraform apply
```

A configuração de `lifecycle` foi a que mais demorou, possivelmente devido à complexidade das regras de transição entre classes de armazenamento.

## Validação no Console AWS.

Após a aplicação, validei no console AWS que todas as configurações foram aplicadas corretamente:

*   ✅ Bloqueio de acesso público ativo em todas as camadas.
*   ✅ Política de bucket aplicada com negação de conexões inseguras.
*   ✅ Encriptação AES-256 ativa por padrão.
*   ✅ Versionamento habilitado.

## O processo de destruição: Terraform Destroy.

Uma parte crucial é destruir adequadamente a infraestrutura (quando aplicável).

### Por que aplicar o destroy?

A execução do `terraform destroy` foi uma etapa fundamental deste projeto de aprendizado, não apenas para evitar custos desnecessários na AWS, mas principalmente para validar o ciclo completo de vida da infraestrutura.

O Terraform demonstrou sua principal vantagem durante a destruição: a capacidade de remover todos os recursos de forma ordenada e completa, algo que seria extremamente trabalhoso fazer manualmente no console AWS. Sem o Terraform, eu teria que navegar por múltiplas telas, lembrar de cada configuração aplicada, e remover manualmente as políticas, configurações de lifecycle, encriptação, versionamento e, por fim, o bucket - um processo propenso a erros e recursos órfãos.

Com um único comando `terraform destroy`, toda a infraestrutura foi removida na ordem correta, seguindo as dependências entre recursos, garantindo limpeza total e zero custos remanescentes.

Esta capacidade de "desfazer" completamente uma implementação é uma das razões pelas quais Infrastructure as Code é considerada uma best practice essencial - você tem controle total sobre o que foi criado e pode removê-lo com a mesma precisão.

```bash
terraform destroy
```

**Insight importante:** O Terraform seguiu uma ordem lógica, removendo primeiro as configurações dependentes antes de destruir o recurso principal. Mas, na vida real, é importante verificar se não restaram serviços atrelados ao bucket que não foram criados pelo Terraform - o que pode persistir gerando custos. (O Terraform destrói apenas os recursos que ele mesmo criou.)

## Lições aprendidas e best practices.

### 1. Importância da Validação de Variáveis

```terraform
variable "bucket_name" {
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Nome do bucket deve conter apenas letras minúsculas, números e hífens, entre 3-63 caracteres."
  }
}
```

Esta validação previne erros comuns de nomenclatura que poderiam causar falha na criação.

### 2. Tags padronizadas e automáticas.

```terraform
default_tags {
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedBy   = "VSCode"
  }
}
```

Facilita o billing, governança e identificação de recursos órfãos.

### 3. Uso de data sources para informações dinâmicas.

```terraform
data "aws_caller_identity" "current" {}
```

Permite referenciar a conta AWS atual sem hardcoding, tornando o código portável entre diferentes contas.

### 4. Configurações condicionais.

```terraform
count = var.enable_access_logging ? 1 : 0
```

Permite ativar/desativar recursos opcionais sem alterar o código principal.

## Considerações de segurança em produção.

Para ambientes produtivos, consideraria ainda:

*   **KMS Customer Managed Keys:** Ao invés de AES-256, usar chaves KMS para maior controle.
*   **Cross-Region Replication:** Para disaster recovery.
*   **CloudTrail Integration:** Para auditoria detalhada.
*   **VPC Endpoints:** Para tráfego que não sai da AWS.
*   **Bucket Notifications:** Para integração com Lambda/SNS.

## Análise de custos: configurações vs. economia.

### Configurações que geram custos:

*   **Versionamento:** Armazena múltiplas versões (mitigado pela política de limpeza). Use o versionamento apenas se efetivamente precisar dele.
*   **Encriptação:** Overhead mínimo com bucket keys habilitadas.

### Configurações que economizam:

*   **Lifecycle Policy:** Até 60% de economia no armazenamento.
*   **Cleanup de uploads incompletos:** Evita cobranças por uploads abandonados.
*   **Bucket Keys:** Reduz custos de criptografia em até 99%.

## ROI das configurações de segurança.

O investimento em configurações de segurança se paga ao evitar:

*   Vazamentos de dados (multas LGPD podem chegar a 2% da receita bruta anual).
*   Custos de remediação de incidentes.
*   Perda de reputação e confiança de clientes.

## Conclusão.

Este exercício prático demonstrou que a segurança e a otimização de custos no S3 não são conceitos antagônicos. Através do Terraform, conseguimos implementar uma solução que é simultaneamente:

*   **Segura:** Múltiplas camadas de proteção contra acessos indevidos.
*   **Econômica:** Otimizações inteligentes de ciclo de vida.
*   **Auditável:** Código versionado e reproduzível.
*   **Escalável:** Configurações parametrizáveis e modulares.

Ainda que de escopo educacional, este foi um projeto real de infraestrutura como código. Cada configuração que vimos resolve um problema específico do mundo real e segue práticas recomendadas pela AWS.

Este caso de estudo ilustra como pequenos projetos de aperfeiçoamento podem consolidar conhecimentos e revelar nuances importantes das ferramentas que usamos diariamente.

O mais importante aprendizado foi perceber que a verdadeira maestria em cloud computing vem da compreensão profunda de como cada configuração impacta segurança, performance e custos. O Terraform não é apenas uma ferramenta de automação - é um facilitador para implementar as melhores práticas de forma consistente e auditável.

#DevOps #Terraform #AWS #S3 #CloudSecurity #InfrastructureAsCode

