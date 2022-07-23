######################################################################
### TASK HOST LAUNCH TEMPLATE

resource "aws_launch_template" "this" {
  name = var.task_host_launch_template.name
  description = coalesce(
    var.task_host_launch_template.description,
    "Launch template for '${var.ecs_service.name}' task hosts."
  )

  update_default_version = coalesce(var.task_host_launch_template.update_default_version, true)

  # EC2 SETTINGS
  image_id = coalesce(
    var.task_host_launch_template.ami_id,
    data.aws_ami.ECS_Optimized_AMI.id
  )
  instance_type = local.instance_type_name
  user_data     = var.task_host_launch_template.user_data

  # NETWORK
  vpc_security_group_ids = var.network_params.security_group_ids

  # TAGS
  tags = var.task_host_launch_template.tags

  dynamic "tag_specifications" {
    for_each = {
      instance          = "EC2"
      network-interface = "ENI-primary"
      volume            = "EBS"
    }
    content {
      resource_type = tag_specifications.key
      tags = {
        Name = "${var.ecs_service.name}_TaskHost_${tag_specifications.value}"
      }
    }
  }

  # SETTINGS
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

#---------------------------------------------------------------------

locals {
  instance_type_name = coalesce(
    var.task_host_launch_template.instance_type,
    "t3a.micro"
  )
}

data "aws_ec2_instance_type" "task_host" {
  instance_type = local.instance_type_name
}

data "aws_ami" "ECS_Optimized_AMI" {
  name_regex  = "^amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs$"
  owners      = ["amazon"]
  most_recent = true
}

######################################################################
