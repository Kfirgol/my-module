resource "aws_launch_template" "launch_template" {
  for_each = { for app in var.apps : app.name => app }
  name     = "${each.value.name}-launch-template"

  block_device_mappings {
    device_name = "/dev/${each.value.name}"

    ebs {
      volume_size = each.value.volume_size
    }
  }

  iam_instance_profile {
    name = each.value.iam_role
  }

  image_id = each.value.ami

  instance_type = each.value.instance_type

  placement {
    availability_zone = var.availability_zone
  }

  vpc_security_group_ids = each.value.security_groups
  user_data              = each.value.user_data
}

resource "aws_instance" "ec2" {
  // Filter to only include objects of type ec2
  for_each        = { for app in var.apps : app.name => app if app.deploy_type == "EC2" }
  ami             = each.value.ami
  subnet_id       = each.value.subnets[0]
  instance_type   = each.value.instance_type
  vpc_security_group_ids = each.value.security_groups
  user_data            = each.value.user_data
  iam_instance_profile = each.value.iam_role

  launch_template {
    name    = "${each.value.name}-launch-template"
    version = "$Latest"
  }
  tags = {
    Name = "${each.value.name}-instance"
  }
}


resource "aws_autoscaling_group" "auto_scaling_group" {
  // Filter to only include objects of type ASG
  for_each           = { for app in var.apps : app.name => app if app.deploy_type == "ASG" }
  name               = "${each.value.name}-asg"
  availability_zones = [var.availability_zone]
  desired_capacity   = each.value.asg.desried
  max_size           = each.value.asg.max
  min_size           = each.value.asg.min

  launch_template {
    name    = "${each.value.name}-launch-template"
    version = "$Latest"
  }
}

resource "aws_lb" "asg_lb" {
  for_each = { for app in var.apps : app.name => app.alb if app.deploy_type == "ASG" && app.alb.deploy == true }

  name               = "${each.value.name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = toset(each.value.sg)
  subnets            = each.value.lb.subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "lb_listener" {
  for_each          = { for app in var.apps : app.name => app.alb if app.alb.deploy == true }
  load_balancer_arn = aws_lb.asg_lb["${each.value.name}-lb"].arn
  port              = each.value.listen_port

  protocol = "HTTP"

  default_action {
    type             = (each.value.host != "" ? "forward" : "redirect" )
    target_group_arn = aws_lb_target_group.target_group["${each.value.name}-tg"].arn

  }

  depends_on = [aws_lb.asg_lb, aws_lb_target_group.target_group]
}

resource "aws_lb_target_group" "target_group" {
  for_each = { for app in var.apps : app.name => app.alb if app.alb.deploy == true }

  name     = "${each.key}-tg"
  port     = each.value.dest_port
  protocol = "HTTP"

  vpc_id = var.vpc

  health_check {
    enabled = (each.value.path != "" ? true : false)
    path    = each.value.path

  }
}


resource "aws_security_group" "security_groups" {
  for_each    = {for app in var.apps : app.name => app.sg_rules }
  name        = "${each.key}-security-group"
  vpc_id      = var.vpc
  
  tags = {
    Name = "${each.key}-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress" {
  
  // results in {app_1: {sg_rules_1}, ... , app_1: {sg_rules_1}, ... , app_n: {sg_rules_n}}
  for_each          = { for app in var.apps : app.name => flatten([for rule in app.sg_rules : rule ])} // inner list ends up empty
  security_group_id = aws_security_group.security_groups["${each.key}-security-group"].id

  // filters to only include cidr_ipv4
  cidr_ipv4         = [for cidr in each.value.cidr_blocks : cidr if can(regex("::", each.value.cidr_blocks))]
  // filters to only include cidr_ipv6
  cidr_ipv6         = [for cidr in each.value.cidr_blocks : cidr if !can(regex("::", each.value.cidr_blocks))]
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
  description       = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "sg_egress" {

  // results in {app_1: [sg_rules_1], ... , app_1: [sg_rules_1], ... , app_n[sg_rules_n]}
  for_each          = { for app_name, sg in {for app in var.apps: app.name => app.sg_rules} : app_name => sg if sg.type == "egress"} 
  security_group_id = "${each.key}-security-group"
  // filters to only include cidr_ipv4
  cidr_ipv4         = [for cidr in each.value.cidr_blocks : cidr if can(regex("::", each.value.cidr_blocks))]
  // filters to only include cidr_ipv6
  cidr_ipv6         = [for cidr in each.value.cidr_blocks : cidr if !can(regex("::", each.value.cidr_blocks))]
  ip_protocol       = each.value.ip_protocol

}

