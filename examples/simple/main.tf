provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "example-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}

resource "aws_security_group" "alb_sg" {
  name        = "example-alb-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Example ALB Security Group"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb_target_group" "app_tg" {
  name     = "example-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

module "app_asg" {
  source = "../../"

  name_prefix          = "example-app"
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnets
  sg_alb_id            = aws_security_group.alb_sg.id
  app_target_group_arn = aws_lb_target_group.app_tg.arn

  app_port      = 8080
  app_protocol  = "HTTP"
  app_user_data = <<-EOT
    #!/bin/bash
    echo "Hello World" > index.html
    nohup python3 -m http.server 8080 &
  EOT

  asg_min_size         = 1
  asg_max_size         = 2
  asg_desired_capacity = 1

  common_tags = {
    Environment = "Example"
    Project     = "AppDemo"
  }
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = module.app_asg.asg_arn
}
