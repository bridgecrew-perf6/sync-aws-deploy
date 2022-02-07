

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Project     = "${var.namespace}-example"
      Team        = var.team
      Creator     = var.creator
    }
  }
}


resource "aws_instance" "sync-runner" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = var.key_name
  user_data     = file("user_data.sh")

  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.snyk_sync_kms_key.key_id
  }


  vpc_security_group_ids = [
    aws_security_group.restrict_ssh_pub.id
  ]

  depends_on           = [aws_security_group.restrict_ssh_pub]
  iam_instance_profile = aws_iam_instance_profile.snyk_instance_profile.name
}


output "ec2instance" {
  value = aws_instance.sync-runner.public_ip
}

