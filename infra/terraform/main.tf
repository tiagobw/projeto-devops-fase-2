resource "aws_instance" "nestjs_app" {
  ami           = "ami-084568db4383264d4" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.nest_sg.id]

  tags = {
    Name = "NestJSTodoApp"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y curl git docker.io docker-compose
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              git clone https://github.com/tiagobw/projeto-devops-fase-2.git app
              cd app
              docker-compose up -d --build
              EOF
}

resource "aws_security_group" "nest_sg" {
  name        = "nestjs_sg"
  description = "Allow HTTP traffic for NestJS app"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
