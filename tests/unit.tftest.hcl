# Unit test using mock_provider - no real AWS credentials needed.
# Requires Terraform >= 1.7.0

mock_provider "aws" {
  mock_data "aws_ssm_parameter" {
    defaults = {
      value = "ami-0abcdef1234567890"
    }
  }
}

run "unit_test_autoscaling_app" {
  command = plan

  variables {
    name_prefix          = "test-app"
    vpc_id               = "vpc-12345678"
    private_subnet_ids   = ["subnet-11111111", "subnet-22222222"]
    sg_alb_id            = "sg-alb-12345678"
    app_target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/test-tg/abc123"

    app_port      = 8080
    app_protocol  = "HTTP"
    app_user_data = "#!/bin/bash\necho hello"

    asg_min_size         = 1
    asg_max_size         = 3
    asg_desired_capacity = 2

    common_tags = {
      Environment = "Test"
      Project     = "UnitTest"
    }
  }

  assert {
    condition     = aws_autoscaling_group.app_asg.min_size == 1
    error_message = "ASG min_size must be 1"
  }

  assert {
    condition     = aws_autoscaling_group.app_asg.max_size == 3
    error_message = "ASG max_size must be 3"
  }

  assert {
    condition     = aws_autoscaling_group.app_asg.desired_capacity == 2
    error_message = "ASG desired_capacity must be 2"
  }

  assert {
    condition     = aws_autoscaling_group.app_asg.health_check_type == "ELB"
    error_message = "Health check type must be ELB"
  }

  assert {
    condition     = length(aws_autoscaling_group.app_asg.vpc_zone_identifier) == 2
    error_message = "ASG must be deployed in 2 subnets"
  }

  assert {
    condition     = aws_launch_template.app_launch_template.instance_type == "t3.micro"
    error_message = "Default instance type must be t3.micro"
  }

  assert {
    condition     = aws_launch_template.app_launch_template.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be enforced (http_tokens = required)"
  }

  assert {
    condition     = aws_security_group.sg_app.vpc_id == "vpc-12345678"
    error_message = "Security group must be created in the correct VPC"
  }
}
