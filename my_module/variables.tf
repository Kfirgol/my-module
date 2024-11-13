variable "vpc" {
  type        = string
  description = "ID of the VPC in which the cluster exists."
}


variable "availability_zone" {
  type        = string
  description = "Availability zone to deploy infrastructure to."
  default     = "us-east-2a"
}


variable "apps" {
  type = list(object({
    name            = string
    deploy_type     = string
    subnets         = list(string)
    security_groups = list(string)  // existing security groups
    ami             = string
    instance_type   = optional(string, "t2.micro")
    volume_size     = optional(number)
    user_data       = optional(string)
    iam_role        = optional(string)
    asg = optional(object({
      min     = optional(number, 1)
      max     = optional(number, 1)
      desired = optional(number, 1)
    }))
    sg_rules = optional(list(object({  // security groups to create
      type        = string
      protocol    = string
      from_port   = number
      to_port     = number
      cidr_blocks = list(string)
      description = optional(string, "N/A")
    })), [{type = "", protocol = null, from_port = null, to_port = null, cidr_blocks = null}])
    alb = optional(object({
      deploy      = optional(bool, true)
      subnets     = optional(list(string))
      sg          = optional(string, "")
      listen_port = optional(number, 80)
      dest_port   = optional(number, 80)
      host        = optional(string, "")  
      path        = optional(string, "/")
    }), {deploy = false})
  }))
}



