data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}


data "aws_VPC" "default"{
  default = true 
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.blog.id]

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "blog_sg"{
  name        = "blog"
  description = "Web traffic https http in, and allow everything"

  vpc_id = data.aws_VPC.default.vpc_id
}

resource"aws_security_group_in" "blog_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidar_block = ["0.0.0.0/0"]

  security_group_id = "aws_security_group.blog.id" 
}

resource"aws_security_group_in" "blog_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidar_block = ["0.0.0.0/0"]

  security_group_id = "aws_security_group.blog.id" 
}

resource"aws_security_group_in" "blog_everything_out"{
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidar_block = ["0.0.0.0/0"]

  security_group_id = "aws_security_group.blog.id" 
}