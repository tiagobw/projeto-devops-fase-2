# Aplicação Dummy com NestJS para o Projeto de DevOps

Esta é uma aplicação "dummy" gerada com o NestJS CLI, com o objetivo de servir como base para **CI/CD** com GitHub Actions e **Infrastructure as Code (IaC)** com Terraform.

## Criação do Projeto

```bash
nest new projeto-devops
cd projeto-devops
```

## Geração de Recursos (CRUD Todos)

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

## Rodar o projeto

```bash
npm run start:dev
```

## A aplicação estará disponível em

```bash
http://localhost:3000/todos
```

## Rodar os testes unitários

```bash
npm run test
```

## Rodar os testes end-to-end

```bash
npm run test:e2e
```

## Objetivo

Esta aplicação foi criada somente para demonstração dos pipelines de CI/CD com GitHub Actions e provisionamento via IaC com Terraform.

Não foram utilizadas dependências externas (banco de dados, autenticação) para manter o foco em infraestrutura.
