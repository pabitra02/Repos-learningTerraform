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

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "Khmer_web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.Khmer_web_sg.security_group_id]

  tags = {
    Name = "Khmer_web"
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "Khmer_web-alb"
  vpc_id  = module.Khmer_web_vpc.vpc_id
  subnets = module.Khmer_web_vpc.publick_subnets
  security_groups = module.Khmer_web_sg.security_group_id
 
  }

listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    
  }
    
  target_groups = {
    ex-instance = {
      name_prefix      = "Khmer_web"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = aws_instance.Khmer_web.id
    }
  }

  tags = {
    Environment = "Khmer_web_Dev"
    Project     = "Using terraform to create this Environment"
  }
}

module "Khmer_web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  vpc_id              = data.aws_vpc.default.id
  name                = "Khmer_web"
  ingress_rules       = ["https-443-tcp","http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}