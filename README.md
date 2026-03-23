# AWS EC2 Auto Scaling App Terraform Module

This Terraform module provisions a scalable infrastructure for applications running on EC2 instances within an Auto Scaling Group (ASG). It automatically configures the instance Security Group to accept traffic only from your Application Load Balancer (ALB) and integrates the instances into the provided Target Group.

## Features

- **Launch Template** creation with User Data support.
- **Auto Scaling Group** configuration with ELB-integrated health checks.
- Restrictive **Security Group**, allowing application port traffic only from the ALB.
- Support for common tags and specific tags for EBS volumes.
- Dynamic AMI selection via SSM parameters.

## Usage Example

```hcl
module "app_asg" {
  source = "smartao/ec2-autoscaling-app/aws" # Exemplo de caminho no Registry
  version = "~> 1.0"

  name_prefix          = "minha-app"
  vpc_id              = "vpc-12345678"
  private_subnet_ids   = ["subnet-111", "subnet-222"]
  sg_alb_id           = "sg-alb-999"
  app_target_group_arn = "arn:aws:elasticloadbalancing:..."
  
  app_port            = 8080
  app_protocol        = "HTTP"
  app_user_data       = <<-EOT
    #!/bin/bash
    echo "Hello World" > index.html
    nohup python3 -m http.server 8080 &
  EOT

  asg_min_size         = 2
  asg_max_size         = 4
  asg_desired_capacity = 2

  common_tags = {
    Environment = "Production"
    Project     = "SkyNet"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.app_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.app_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.sg_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_app_to_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_http_app_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | The port on which the application listens | `number` | n/a | yes |
| <a name="input_app_protocol"></a> [app\_protocol](#input\_app\_protocol) | The protocol used by the application (e.g., HTTP, HTTPS) | `string` | n/a | yes |
| <a name="input_app_target_group_arn"></a> [app\_target\_group\_arn](#input\_app\_target\_group\_arn) | The ARN of the ALB Target Group for the application | `string` | n/a | yes |
| <a name="input_app_user_data"></a> [app\_user\_data](#input\_app\_user\_data) | Rendered user data script for application EC2 instances | `string` | n/a | yes |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | Desired number of instances in the Auto Scaling Group | `number` | `2` | no |
| <a name="input_asg_health_check_grace_period"></a> [asg\_health\_check\_grace\_period](#input\_asg\_health\_check\_grace\_period) | Time (in seconds) that Auto Scaling waits before checking the health status of an instance after it enters the InService state | `number` | `300` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | Maximum number of instances in the ASG | `number` | `3` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | Minimum number of instances in the ASG | `number` | `2` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | n/a | yes |
| <a name="input_disk_delete_on_termination"></a> [disk\_delete\_on\_termination](#input\_disk\_delete\_on\_termination) | Defines whether the EBS volume will be deleted when the instance is terminated. | `bool` | `true` | no |
| <a name="input_disk_encrypted"></a> [disk\_encrypted](#input\_disk\_encrypted) | Defines whether the EBS volume will be encrypted. | `bool` | `true` | no |
| <a name="input_disk_volume_size"></a> [disk\_volume\_size](#input\_disk\_volume\_size) | The size of the EBS volume in GB | `number` | `20` | no |
| <a name="input_disk_volume_type"></a> [disk\_volume\_type](#input\_disk\_volume\_type) | The type of the EBS volume | `string` | `"gp3"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type for the EC2 instances | `string` | `"t3.micro"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming resources | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for application instances and internal ALB | `list(string)` | n/a | yes |
| <a name="input_sg_alb_id"></a> [sg\_alb\_id](#input\_sg\_alb\_id) | The ID of the Security Group for the Application Load Balancer | `string` | n/a | yes |
| <a name="input_ssm_parameter_name"></a> [ssm\_parameter\_name](#input\_ssm\_parameter\_name) | The name of the SSM parameter that contains the AMI ID Launch Template | `string` | `"/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | The ID of the application security group |
| <a name="output_asg_arn"></a> [asg\_arn](#output\_asg\_arn) | The ARN of the Auto Scaling Group |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | The ID of the Launch Template |
<!-- END_TF_DOCS -->