provider "aws" {
  region = var.aws_region
}
resource "aws_key_pair" "jarvis" {
  key_name   = var.key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jarvis" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.jarvis.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data = file("user_data.sh")
  tags = {
    Name = "jarvis-deploy"
  }
}

output "public_ip" {
  value = aws_instance.jarvis.public_ip
}