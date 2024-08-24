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

module "Khmer_web_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2bc"]
  # private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "Khmer_web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.Khmer_web_SG.security_group_id]

  subnet_id = module.Khmer_web_vpc.private_subnets[0]

  tags = {
    Name = "Khmer_Pride"
  }
}

module "Khmer_web_SG" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

 # vpc_id              = data.aws_vpc.default.id

  vpc_id              = module.Khmer_web_vpc.vpc_id
  name    = "Khmer-web_noude-sec"

  ingress_rules        = ["http-80-tcp","https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules        = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

}

