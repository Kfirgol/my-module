output "ec2_instances" {
  value = [
    for app in var.apps : aws_instance.ec2[app.name]
  ]
  description = "A list of EC2 instances created by the module."
}


output "asg" {
  value = [
    for app in var.apps : aws_autoscaling_group.auto_scaling_group["${app.name}-asg"].name
  ]
  description = "A list of Auto Scaling Groups created by the module."
}