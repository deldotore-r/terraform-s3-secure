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

## Destruição da Infraestrutura

```bash
# Remove todos os recursos criados
terraform destroy
```

⚠️ **Atenção**: Este comando remove permanentemente todos os recursos. Certifique-se de fazer backup dos dados importantes.

## Documentação Adicional

Para uma análise detalhada das configurações de segurança, otimizações de custo e lições aprendidas, consulte o artigo completo:

- 📖 [Artigo completo - S3 Seguro com Terraform](https://www.linkedin.com/pulse/implementa%C3%A7%C3%A3o-segura-de-bucket-s3-com-terraform-do-ao-del-dotore-cduif/?trackingId=OnyYL1qiQAqVOZsjLvbpDw%3D%3D)

## Autor

**Reinaldo Del Dotore**

- LinkedIn: [reinaldo-del-dotore](https://linkedin.com/in/reinaldo-del-dotore)
- GitHub: [@deldotore-r](https://github.com/deldotore-r)

## Licença

Este projeto está sob a licença MIT.

---

⭐ Se este projeto foi útil para você, considere dar uma estrela no GitHub!

**Tags**: `terraform` `aws` `s3` `security` `devops` `infrastructure-as-code` `cloud` `cost-optimization`
