provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "parabucksf" {
  bucket = var.bucket_name
}

resource "aws_security_group" "http_sg" {
  name_prefix = "http-sg"

  ingress {
    from_port   = 5000
    to_port     = 5000
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

resource "aws_instance" "app_server" {
  ami           = "ami-02df5cb5ad97983ba" 
  instance_type = "t3.micro"
  subnet_id = "subnet-0381e3869f71712e0"

  security_groups = [aws_security_group.http_sg.name]

  tags = {
    Name = "s3-listing-service"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3
              pip3 install flask boto3
              export AWS_ACCESS_KEY_ID=${var.aws_access_key_id}
              export AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}
              export BUCKET_NAME=${var.bucket_name}
              python3 /home/ec2-user/app.py &
              EOF
}
