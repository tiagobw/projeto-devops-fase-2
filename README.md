# Projeto: Aplicação NestJS com Pipeline de Integração Contínua (CI)

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

## Pipeline de Integração Contínua (CI)

### O workflow do GitHub Actions esá localizado em `.github/workflows/ci.yml` com as seguintes etapas

- Checkout do código

- Configuração do ambiente Node.js (versão 22)

- Instalação de dependências com npm ci

- Execução de testes unitários

- Execução de testes end-to-end

- Execução de lint para verificação de estilo de código

- Compilação do projeto com npm run build

### Esse pipeline é acionado nas seguintes condições

- Push para a branch main

- Pull requests para a branch main

- Execução manual via workflow_dispatch

## IaC com Terraform

### Criar o usuário no AWS IAM

Security, Identity, & Compliance -> IAM -> Users -> Create User

User name: `terraform-user`

Attach policies directly: `AmazonEC2FullAccess` e `AmazonVPCFullAccess`

Create access key -> Use case -> Other

Description tag value: `terraform-access-key`

Anotar `Access key` e `Secret access key` ou fazer download do arquivo CSV.

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

## Objetivo do Projeto

O objetivo deste projeto é demonstrar, de forma prática, a aplicação de conceitos de DevOps utilizando uma API NestJS simplificada como base para configurar pipelines de Integração Contínua (CI) com GitHub Actions e provisionamento de infraestrutura (IaC) com Terraform na AWS.

A aplicação NestJS não utiliza dependências externas, como banco de dados ou autenticação, mantendo o foco exclusivamente na infraestrutura.
