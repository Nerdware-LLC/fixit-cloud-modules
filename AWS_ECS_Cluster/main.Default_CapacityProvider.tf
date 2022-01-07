######################################################################
### ECS Cluster: Default Capacity Provider

resource "aws_ecs_capacity_provider" "Default_CapacityProvider" {
  name = coalesce(var.default_capacity_provider.name, "Default_CapacityProvider")

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.Default_CapacityProvider.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }

  tags = var.default_capacity_provider.tags
}

#---------------------------------------------------------------------
### ECS Cluster: AutoScaling Group for the Default Capacity Provider

locals {
  # This local serves to simply shorten some long lines
  asg = var.default_capacity_provider.autoscaling_group
}

resource "aws_autoscaling_group" "Default_CapacityProvider" {
  name = coalesce(local.asg.name, "Default_CapacityProvider_AutoScaling_Group")

  min_size              = 0
  desired_capacity      = 0
  max_size              = 0
  protect_from_scale_in = false

  launch_template {
    id      = aws_launch_template.Default_CapacityProvider.id
    version = "$Latest"
  }

  tags = toset(flatten([
    {
      key                 = "AmazonECSManaged"
      value               = ""
      propagate_at_launch = true
    },
    [
      for tag_key, tag_value in local.asg.tags : {
        key                 = tag_key
        value               = tag_value
        propagate_at_launch = false
      }
    ]
  ]))
}

#---------------------------------------------------------------------
### LAUNCH TEMPLATE for the Default Capacity Provider's AutoScaling Group

/* NOTE: We don't want our cluster's default capacity provider to ever
actually launch EC2s via the default ASG; all EC2s should be launched
with explicit configuration that was designed purposefully and carefully.
Note that the following properties were removed from this LT resource:
  - iam_instance_profile
  - vpc_security_group_ids
  - user_data
  - key_name
We almost certainly don't need these properties, since we want "default"
resources to be locked down. However, if upon "apply" operations in the
FCL repo we encounter errors pertaining to the cluster's default resources,
consider that the removal of 1 or more of these properties could be the issue. */

resource "aws_launch_template" "Default_CapacityProvider" {
  name = coalesce(
    local.asg.launch_template.name,
    "Default_CapacityProvider_LaunchTemplate"
  )
  description = coalesce(
    local.asg.launch_template.description,
    "Terraform-managed launch template for an ECS Cluster's default capacity provider."
  )
  update_default_version = true

  # EC2 SETTINGS
  image_id      = data.aws_ami.ECS_Optimized_AMI.id # TODO change this to our base hardened AMI once that's available
  instance_type = "t2.nano"                         # arbitrary cheap instance

  # TAGS
  tags = local.asg.launch_template.tags

  dynamic "tag_specifications" {
    for_each = {
      instance          = "EC2"
      network-interface = "ENI-primary"
      volume            = "EBS"
    }
    content {
      resource_type = tag_specifications.key
      tags = {
        Name = "Default_CapacityProvider_${tag_specifications.value}"
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

# TODO change this to our base hardened AMI once that's available
data "aws_ami" "ECS_Optimized_AMI" {
  name_regex  = "^amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs$"
  owners      = ["amazon"]
  most_recent = true
}

######################################################################
