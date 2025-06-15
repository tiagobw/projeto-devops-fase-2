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
