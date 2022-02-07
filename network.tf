module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.namespace}-vpc"
  cidr = "10.0.0.0/16"

  #azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  azs = ["${var.region}a"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # public_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  public_subnets = ["10.0.11.0/24"]

  enable_nat_gateway = true
}

resource "aws_security_group" "restrict_ssh_pub" {
  name        = "${var.namespace}-restrict_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Restricted SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.source_subnet]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-restrict_ssh_pub"
  }
}
