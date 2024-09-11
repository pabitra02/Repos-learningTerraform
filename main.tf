data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-20240701.1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["895370532475"] # Bitnami
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"

  tags = {
    Name = "HelloWorld"
  }
}
