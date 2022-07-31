locals {
  vpc_name   = var.vpc_name
  vpc_cidr   = var.vpc_cidr
  azs        = slice(data.aws_availability_zones.available.names, 0, 3)
  public_key = var.public_key
}

data "aws_availability_zones" "available" {}

# Find Ubuntu 22.04 AMI
data "aws_ami" "ubuntu_22_04" {
  owners      = ["099720109477"] # Canonical
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a VPC
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  create_igw           = true
  enable_nat_gateway   = false
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Create a Security Group
resource "aws_security_group" "instance_sg" {
  name        = "dicoding-sg"
  description = "Allow SSH, HTTP, HTTPS & port 3000 inbound traffic"
  vpc_id      = module.aws_vpc.vpc_id

  ingress {
    description      = "SSH from internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS from internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Custom HTTP port from internet"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create a keypair for ec2 instance
resource "aws_key_pair" "instance_key" {
  key_name   = "instance-keypair"
  public_key = file(local.public_key)
}

# Create a EC2 Instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.instance_key.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id              = module.aws_vpc.public_subnets[0]
}

# Provisioner EC2 instance with Terraform & Ansible
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ssh-keyscan -H ${module.ec2_instance.public_ip} >> ~/.ssh/known_hosts"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${module.ec2_instance.public_ip},' --private-key ${var.private_key} -e 'pub_key=${var.public_key}' playbooks/setup-webserver.yml"
  }

  depends_on = [
    module.ec2_instance,
  ]
}
