## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75.0 |


## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.auto_scaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_launch_template.launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.asg_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.security_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.sg_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.sg_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apps"></a> [apps](#input\_apps) | n/a | <pre>list(object({<br/>    name            = string<br/>    deploy_type     = string<br/>    subnets         = list(string)<br/>    security_groups = list(string)  // existing security groups<br/>    ami             = string<br/>    instance_type   = optional(string, "t2.micro")<br/>    volume_size     = optional(number)<br/>    user_data       = optional(string)<br/>    iam_role        = optional(string)<br/>    asg = optional(object({<br/>      min     = optional(number, 1)<br/>      max     = optional(number, 1)<br/>      desired = optional(number, 1)<br/>    }))<br/>    sg_rules = optional(list(object({  // security groups to create<br/>      type        = string<br/>      protocol    = string<br/>      from_port   = number<br/>      to_port     = number<br/>      cidr_blocks = list(string)<br/>      description = optional(string, "N/A")<br/>    })), [{type = "", protocol = null, from_port = null, to_port = null, cidr_blocks = null}])<br/>    alb = optional(object({<br/>      deploy      = optional(bool, true)<br/>      subnets     = optional(list(string))<br/>      sg          = optional(string, "")<br/>      listen_port = optional(number, 80)<br/>      dest_port   = optional(number, 80)<br/>      host        = optional(string, "")  <br/>      path        = optional(string, "/")<br/>    }), {deploy = false})<br/>  }))</pre> | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone to deploy infrastructure to. | `string` | `"us-east-2a"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | ID of the VPC in which the cluster exists. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg"></a> [asg](#output\_asg) | A list of Auto Scaling Groups created by the module. |
| <a name="output_ec2_instances"></a> [ec2\_instances](#output\_ec2\_instances) | A list of EC2 instances created by the module. |
