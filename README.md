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

## Objetivo do Projeto

O projeto consiste em uma aplicação "dummy" NestJS criada para demonstração dos pipelines de `CI/CD` com GitHub Actions e provisionamento via `IaC` com Terraform.

A aplicação NestJS não utiliza dependências externas, como banco de dados ou autenticação, mantendo o foco exclusivamente na infraestrutura.
