######################################################################
### TASK HOST LAUNCH TEMPLATE

resource "aws_launch_template" "map" {
  for_each = var.task_host_launch_templates

  name                   = each.key
  description            = each.value.description
  update_default_version = coalesce(each.value.should_update_default_version, true)

  # EC2 SETTINGS
  image_id      = coalesce(each.value.ami_id, data.aws_ami.ECS_Optimized_AMI.id)
  instance_type = each.value.instance_type
  user_data     = each.value.user_data

  # TAGS
  tags = each.value.tags

  dynamic "tag_specifications" {
    for_each = coalesce(each.value.tag_specifications, [])

    content {
      /* See link below for valid "resource_type" values.
      https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateTagSpecificationRequest.html  */
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
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

data "aws_ami" "ECS_Optimized_AMI" {
  name_regex  = "^amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs$"
  owners      = ["amazon"]
  most_recent = true
}

######################################################################
