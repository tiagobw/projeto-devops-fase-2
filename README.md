# Projeto DevOps: Aplicação NestJS com CI/CD e IaC

## Aplicação NestJS para o Projeto de DevOps

Esta é uma aplicação "dummy" gerada com o NestJS CLI, com o objetivo de servir como base para **CI/CD** com GitHub Actions e **Infrastructure as Code (IaC)** com Terraform.

### Criação do Projeto

```bash
nest new projeto-devops
cd projeto-devops
```

### Geração de Recursos (CRUD Todos)

```bash
nest generate resource todos
```

Opções selecionadas:

- Transport layer: `REST API`
- Generate CRUD entry points: `Yes`

Recursos gerados:

- Module
- Controller
- Service
- Entity
- DTOs (Data Transfer Objects)

### Rodar o projeto

```bash
npm run start:dev
```

### A aplicação estará disponível em

```bash
http://localhost:3000/todos
```

## Rodar os testes unitários

```bash
npm run test
```

### Rodar os testes end-to-end

```bash
npm run test:e2e
```

## Pipeline de Integração Contínua e Entrega Contínua (CI/CD)

### O workflow do GitHub Actions está localizado em `.github/workflows/ci-cd.yml` com as seguintes etapas

- Provisionamento da infraestrutura AWS com Terraform
- Checkout do código
- Configuração do ambiente Node.js (versão 22)
- Instalação de dependências com npm ci
- Execução de testes unitários
- Execução de testes end-to-end
- Execução de lint para verificação de estilo de código
- Compilação do projeto com npm run build
- Cópia automatizada do projeto para a EC2 via SCP
- Deploy remoto automatizado via SSH com PM2

### Esse pipeline é acionado nas seguintes condições

- Push para a branch main
- Pull requests para a branch main
- Execução manual via workflow_dispatch

## IaC com Terraform

### Criar o usuário IAM na AWS

Security, Identity, & Compliance -> IAM -> Users -> Create User

User name: `terraform-user`

Attach policies directly: `AmazonEC2FullAccess` e `AmazonVPCFullAccess`

Create access key -> Use case -> Other

Description tag value: `terraform-access-key`

Anotar `Access key` e `Secret access key` ou fazer download do arquivo CSV.

### Configuração dos GitHub Secrets (pré-requisito para CI/CD)

No repositório do GitHub, acesse:

**Settings → Secrets and variables → Actions → [Repository secrets] → New repository secret**

- `AWS_ACCESS_KEY_ID`: Access key do usuário IAM `terraform-user`
- `AWS_SECRET_ACCESS_KEY`: Secret key do usuário IAM `terraform-user`
- `EC2_SSH_KEY`: Conteúdo da chave privada `devops-key.pem`

### Instalar a AWS CLI (Ubuntu 24.04)

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Configurar a AWS CLI

```bash
aws configure
```

- AWS Access Key ID [None]: Insira a `Access key` do usuário `terraform-user` criado anteriormente.
- AWS Secret Access Key [None]: Insira a `Secret access key` do usuário `terraform-user` criado anteriormente.
- Default region name [None]: `us-east-1`
- Default output format [None]: `json`

### Gerar chave SSH (Ubuntu 24.04 - terminal local)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/devops-key
```

### Importar chave pública no AWS EC2

Acesse o console do AWS EC2 e vá para `Network & Security` -> `Key pairs` -> `Import key pair`

- Name: `devops-key`
- Public key contents: Cole o conteúdo do arquivo `~/.ssh/devops-key.pub`
- Clique em `Import key pair`

### Instalar o Terraform (Ubuntu 24.04)

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Configuração do Backend Remoto com S3 (Terraform)

Para garantir a consistência e evitar conflitos no estado da infraestrutura, este projeto utiliza um **backend remoto com o Amazon S3** para armazenar o arquivo `terraform.tfstate`.

#### Por que usar backend remoto (S3)?

- Permite **persistência** do estado da infraestrutura entre execuções.
- Evita sobrescritas acidentais (problemas comuns com `terraform apply` local).
- Facilita execução do Terraform em pipelines CI/CD sem necessidade de arquivos locais.
- Indispensável para ambientes reais com múltiplos colaboradores ou execuções automatizadas.

---

#### Configuração adotada no projeto

Arquivo `infra/terraform/provider.tf`:

```hcl
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "unique-devops-state-june-2025"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

#### Etapa manual obrigatória (executar uma única vez)

O Terraform **não cria automaticamente** o bucket S3. Você deve criá-lo manualmente **antes** de rodar `terraform init`.

O Terraform exige que o backend S3 já exista antes da inicialização (`terraform init`) porque ele precisa acessar esse local remoto para armazenar ou ler o estado da infraestrutura. Como o backend é responsável justamente por controlar o estado, o Terraform não pode criar o bucket automaticamente, pois ele ainda não tem onde registrar esse tipo de operação. Portanto, a criação manual do bucket é necessária uma única vez, antes da primeira execução.

##### Opção 1 — Criar via terminal (AWS CLI) [Observação: é necessário que o usuário `terraform-user` tenha permissão para criar buckets S3, recomendado usar a opção 2]

```bash
aws s3api create-bucket \
  --bucket unique-devops-state-june-2025 \
  --region us-east-1

# Reforce a segurança bloqueando acesso público:
aws s3api put-public-access-block \
  --bucket unique-devops-state-june-2025 \
  --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'
```

##### Opção 2 — Criar via Console AWS

1. Acesse [https://s3.console.aws.amazon.com/s3/](https://s3.console.aws.amazon.com/s3/)
2. Clique em **"Create bucket"**
3. Nome: `unique-devops-state-june-2025`
4. Região: `us-east-1`
5. **Mantenha marcada a opção "Block all public access" (recomendado)**
6. Clique em **"Create bucket"** (as configurações padrão são suficientes)

---

##### Concedendo permissão ao usuário `terraform-user`

Para que o usuário `terraform-user` consiga acessar o bucket S3 de backend, é necessário criar e anexar uma política personalizada com as permissões adequadas.

1. Acesse [IAM → Policies](https://console.aws.amazon.com/iam/home#/policies)
2. Clique em **"Create policy"** e selecione a aba **"JSON"**
3. Cole o seguinte conteúdo:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "AllowS3BackendAccess",
         "Effect": "Allow",
         "Action": [
           "s3:GetObject",
           "s3:PutObject",
           "s3:DeleteObject",
           "s3:ListBucket"
         ],
         "Resource": [
           "arn:aws:s3:::unique-devops-state-june-2025",
           "arn:aws:s3:::unique-devops-state-june-2025/*"
         ]
       }
     ]
   }
   ```

4. Clique em **"Next"**, dê um nome como `TerraformS3StateAccess` e clique em **"Create policy"**
5. Vá para [IAM → Users](https://console.aws.amazon.com/iam/home#/users), selecione o usuário `terraform-user`, e em **Permissions**, clique em **"Add permissions" → "Attach policies directly"**
6. Marque a política `TerraformS3StateAccess` e clique em **"Next" → "Add permissions"**

---

#### Inicializar o Terraform com backend remoto

Depois que o bucket existir, inicialize o backend:

```bash
cd infra/terraform
terraform init
```

Essa etapa conecta o Terraform ao S3 e sincroniza o estado da infraestrutura.

### Navegar até o diretório com as configurações do Terraform

```bash
cd infra/terraform
```

### Inicializar o Terraform

```bash
terraform init
```

### Verificar o plano de execução

```bash
terraform plan
```

### Aplicar o plano de execução

```bash
terraform apply
```

Enter a value: `yes`

**Atenção: Se você alterar o bloco `user_data` no arquivo `main.tf` (por exemplo, para instalar pacotes adicionais ou configurar algo novo na EC2), será necessário recriar a instância para que essas alterações tenham efeito.**

Você pode fazer isso com o comando:

```bash
terraform destroy
terraform apply
```

### Após pressionar enter, o Terraform irá provisionar a infraestrutura na AWS e retornar o IP público da instância EC2 criada

```bash
instance_public_ip = "xx.xxx.xxx.xx"
```

### Espere alguns minutos até que a instância EC2 esteja disponível e faça um teste com curl (usando o IP público retornado pelo Terraform)

```bash
curl http://xx.xxx.xxx.xx:3000/todos
```

### A resposta será

```bash
This action returns all todos
```

### A instância também pode ser acessada via SSH

```bash
ssh -i ~/.ssh/devops-key ubuntu@xx.xxx.xxx.xx
```

### Para destruir a infraestrutura provisionada

```bash
terraform destroy
```

Enter a value: `yes`

Observação: O comando deve ser executado no diretório `infra/terraform`.

### Deploy com Docker e Docker Compose

A aplicação agora é empacotada e executada dentro de um container Docker, seguindo práticas modernas de DevOps.

Arquivos adicionados:

`Dockerfile`: define como a aplicação NestJS será containerizada.

`docker-compose.yml`: orquestra o container da aplicação.

`.dockerignore`: ignora arquivos desnecessários durante o build da imagem.

#### Funcionamento no CI/CD

**O pipeline do GitHub Actions foi atualizado para**:

Executar `docker-compose up -d --build`, que:

Constrói a imagem com base no Dockerfile.

Executa o container em segundo plano.

Expõe a porta 3000 da aplicação NestJS.

**Benefícios da abordagem com Docker**:

Facilita a portabilidade da aplicação entre ambientes.

Reduz problemas de "funciona na minha máquina".

Automatiza completamente o ciclo de build, deploy e execução.

Alinha o projeto a padrões profissionais de DevOps.

**Observação: para que as mudanças do `user_data` do `main.tf` tenham efeito, você deve:**

```bash
cd infra/terraform
terraform destroy
terraform apply
```

## Objetivo do Projeto

O objetivo deste projeto é demonstrar, de forma prática, a aplicação de conceitos de DevOps utilizando uma API NestJS simplificada como base para configurar pipelines de Integração Contínua (CI) e Entrega Contínua (CD) com GitHub Actions, e provisionamento de infraestrutura (IaC) com Terraform na AWS.

A aplicação NestJS não utiliza dependências externas como banco de dados ou autenticação, mantendo o foco exclusivo em práticas de DevOps e automação de infraestrutura.

Além disso, o projeto incorpora conteinerização com Docker e orquestração com Docker Compose, garantindo consistência entre ambientes de desenvolvimento, teste e produção. Essa abordagem elimina problemas de ambiente e torna o deploy mais previsível, portátil e alinhado com padrões modernos da engenharia de software.
