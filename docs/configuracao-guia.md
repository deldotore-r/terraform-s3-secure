# Guia de Configuração - terraform.tfvars

> **Instruções passo a passo para configurar seu ambiente Terraform S3 Seguro**

## Como Usar Este Guia

1. **Copie o arquivo de exemplo**: `cp terraform.tfvars.example terraform.tfvars`
2. **Siga as seções abaixo** para personalizar cada configuração
3. **Nunca commite** o arquivo `terraform.tfvars` final (contém dados específicos do seu ambiente)

## Configurações Obrigatórias

### Nome do Bucket S3

```hcl
bucket_name = "seu-bucket-seguro-001"
```

**Por que é importante**: Nomes de bucket S3 são globalmente únicos em toda a AWS. Duas pessoas no mundo inteiro não podem ter o mesmo nome.

**Como escolher**:

- Use seu nome/empresa + projeto + número: `joaosilva-backup-001`
- Inclua o ambiente: `minhaapp-dev-bucket-001`
- Mantenha entre 3-63 caracteres
- Apenas letras minúsculas, números e hífens

**Exemplos válidos**:

- `minhaempresa-dados-prod-001`
- `projeto-uploads-dev-2024`
- `backup-pessoal-v1`

**Evite**:

- `MeuBucket` (maiúsculas não permitidas)
- `meu_bucket` (underscores não recomendados)
- `aws-meu-bucket` (evite prefixos AWS)

---

## Configurações de Ambiente

### Região AWS

```hcl
aws_region = "us-east-1"
```

**Considerações para escolha**:

| Região      | Vantagem                   | Desvantagem               |
| ----------- | -------------------------- | ------------------------- |
| `us-east-1` | Mais barata, mais serviços | Maior latência do Brasil  |
| `sa-east-1` | Menor latência do Brasil   | Mais cara, menos serviços |
| `us-west-2` | Boa performance, completa  | Latência média            |

### Ambiente de Deployment

```hcl
environment = "dev"
```

**Opções disponíveis**: `dev`, `staging`, `prod`

**Impacto prático**:

- **dev**: Configurações mais permissivas, custos otimizados
- **staging**: Espelha produção para testes finais
- **prod**: Máxima segurança, todas as proteções ativas

### Nome do Projeto

```hcl
project_name = "terraform-s3-seguro"
```

**Para que serve**: Organização de custos e recursos através de tags AWS. Facilita identificar recursos órfãos e calcular custos por projeto.

---

## Configurações de Segurança

### Versionamento do Bucket

```hcl
enable_versioning = true
```

**Quando usar `true`**:

- Ambientes de produção
- Dados importantes que podem ser alterados
- Quando você precisa de histórico de mudanças

**Quando usar `false`**:

- Ambientes de desenvolvimento
- Dados temporários ou logs
- Quando o custo extra do versionamento é uma preocupação

**Impacto nos custos**: Cada versão de arquivo é cobrada separadamente. Com lifecycle policy, versões antigas são removidas automaticamente.

### Restrição de Acesso por Conta

```hcl
restrict_to_account_only = true
```

**Recomendação**: Sempre `true` para máxima segurança.

**O que faz**: Garante que apenas recursos da sua conta AWS possam acessar o bucket, criando uma camada extra de proteção.

---

## Configurações de Custo e Performance

### Política de Ciclo de Vida

```hcl
enable_lifecycle_policy = true
```

**Economia potencial**: Até 60% nos custos de armazenamento

**Como funciona**:

```
Dias 0-30:    STANDARD        ($0.023/GB)
Dias 30-90:   STANDARD_IA     ($0.0125/GB)  ← 46% mais barato
Dias 90+:     GLACIER         ($0.004/GB)   ← 83% mais barato
```

**Quando desabilitar**: Apenas se você precisar de acesso imediato a todos os arquivos, independente da idade.

### Logging de Acesso

```hcl
enable_access_logging = false
```

**Por que padrão é `false`**:

- Cria um bucket adicional (custos extras)
- Gera logs que também custam para armazenar
- Útil apenas para auditoria detalhada

**Quando habilitar**:

- Ambientes de produção críticos
- Compliance regulatório exigir
- Investigação de padrões de acesso

---

## Configurações por Tipo de Ambiente

### Desenvolvimento

Foque em economia e simplicidade:

```hcl
bucket_name = "meuapp-dev-bucket-001"
environment = "dev"
enable_versioning = false
enable_lifecycle_policy = false
enable_access_logging = false
restrict_to_account_only = true
```

**Custo estimado mensal**: $2-5 para testes básicos

### Staging

Simule produção com custos controlados:

```hcl
bucket_name = "meuapp-staging-bucket-001"
environment = "staging"
enable_versioning = true
enable_lifecycle_policy = true
enable_access_logging = false
restrict_to_account_only = true
```

**Custo estimado mensal**: $5-15 para testes completos

### Produção

Máxima segurança e otimização:

```hcl
bucket_name = "meuapp-prod-bucket-001"
environment = "prod"
enable_versioning = true
enable_lifecycle_policy = true
enable_access_logging = true
restrict_to_account_only = true
```

**Custo estimado mensal**: Varia conforme volume, mas com 40-60% de economia pela lifecycle policy

---

## Checklist de Validação

Antes de executar `terraform apply`, confirme:

- [ ] Nome do bucket é único e segue convenções
- [ ] Região escolhida atende seus requisitos de latência
- [ ] Configurações de segurança adequadas ao ambiente
- [ ] Políticas de custo alinhadas com seu orçamento
- [ ] Arquivo `terraform.tfvars` não será commitado no Git

## Exemplo Completo

```hcl
# Configuração recomendada para a maioria dos casos
bucket_name              = "minhaemp-projeto-dev-001"
environment              = "dev"
project_name             = "projeto-s3-seguro"
aws_region               = "us-east-1"
enable_versioning        = true
enable_access_logging    = false
enable_lifecycle_policy  = true
restrict_to_account_only = true
```

## Próximos Passos

1. **Configure seu arquivo**: Use as orientações acima
2. **Execute o plano**: `terraform plan` para revisar
3. **Aplique as mudanças**: `terraform apply` quando estiver satisfeito
4. **Monitore os custos**: Use AWS Cost Explorer para acompanhar gastos

## Problemas Comuns

### "BucketAlreadyExists"

**Solução**: Mude o `bucket_name` para algo mais único

### "AccessDenied"

**Solução**: Verifique se suas credenciais AWS têm permissões S3

### Custos inesperados

**Solução**: Revise as configurações de versionamento e lifecycle policy

---

**Dica**: Comece sempre com configurações conservadoras (dev) e evolua conforme ganha confiança com a ferramenta.
