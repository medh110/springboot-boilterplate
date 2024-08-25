provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.jenkins_key.public_key_openssh

  tags = {
    Name = "Jenkins Key Pair"
  }
}

# Security Group allowing SSH and HTTP
resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg"
  vpc_id      = "vpc-0229dc64"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 8080
    to_port     = 8080
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

# EC2 Instance for Jenkins
resource "aws_instance" "jenkins_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name        = aws_key_pair.jenkins_key_pair.key_name
  security_groups = [aws_security_group.jenkins_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y java-11-amazon-corretto
              wget https://pkg.jenkins.io/redhat-stable/jenkins-2.462.1-1.1.noarch.rpm
              sudo yum localinstall -y jenkins-2.462.1-1.1.noarch.rpm --nogpgcheck
              sudo yum install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF

  tags = {
    Name = "Jenkins Server"
  }
}
