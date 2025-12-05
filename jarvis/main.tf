provider "aws" {
  region = "us-west-1"
}
/*
resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins1"
  public_key = file("~/.ssh/id_rsa.pub")
}*/

resource "aws_security_group" "jarvis-2-0" {
  name = "jarvis-2-0"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "jarvis-2-0" {
  ami                    = "ami-0e6a50b0059fd2cc3"  # Updated Ubuntu AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jarvis-2-0.id]
  key_name               =  "terraformkey"  # Ensure this key pair exists in your AWS account

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "jarvis-2-0"
  }
}
