<h1> Fixit Cloud ☁️ MODULE: AWS Account Baseline</h1>

Terraform module for defining ECS Service resources.

<h2>Table of Contents</h2>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-start -->

---

## ⚙️ Module Usage

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.11.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.11.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_ecs_capacity_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_service_discovery_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_ami.ECS_Optimized_AMI](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_instance_type.task_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_group"></a> [autoscaling\_group](#input\_autoscaling\_group) | Config object for the autoscaling group resource. | <pre>object({<br>    name = string<br>    tags = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_capacity_provider"></a> [capacity\_provider](#input\_capacity\_provider) | Config object for the capacity provider resource. | <pre>object({<br>    name = string<br>    tags = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_ecs_service"></a> [ecs\_service](#input\_ecs\_service) | Config object for the ECS Service resource. | <pre>object({<br>    name            = string<br>    ecs_cluster_arn = string<br>    instance_count = object({<br>      min     = number<br>      desired = number<br>      max     = number<br>    })<br>    enable_ecs_exec = optional(bool)<br>    tags            = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_network_params"></a> [network\_params](#input\_network\_params) | Config object containing network parameters. The "assign\_public\_ip" bool<br>switch is used to determine the networking mode in the Task Definition as well<br>as the network configuration for the ECS Service. Since the "awsvpc" net mode<br>can only be used in private subnets, a value of "true" will create a Task Def<br>with the "bridge" network mode ("host" is not supported), and consequently the<br>ECS Service will not have a network configuration. "subnet\_ids" is a list of<br>subnet IDs used by the "aws\_ecs\_service" and "aws\_autoscaling\_group" resources. | <pre>object({<br>    assign_public_ip   = bool<br>    subnet_ids         = list(string)<br>    security_group_ids = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_rolling_update_controls"></a> [rolling\_update\_controls](#input\_rolling\_update\_controls) | (Optional) Config object for rolling updates. Set "force\_new\_deployment"<br>to "true" after the AMI pipeline updates the service image. Min/Max<br>default to 100/200, respectively. | <pre>object({<br>    force_new_deployment               = bool<br>    deployment_minimum_healthy_percent = optional(number)<br>    deployment_maximum_percent         = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_service_discovery_service"></a> [service\_discovery\_service](#input\_service\_discovery\_service) | Config object for the Task launch template resource.<br>"health\_check\_custom\_failure\_threshold", if provided, must be a number<br>between 1-10 which shall implement the number of 30-second intervals<br>the service discovery service should wait before it changes the health<br>status of a service instance. | <pre>object({<br>    name = string<br>    dns_config = optional(object({<br>      namespace_id = string<br>      dns_records = set(object({<br>        type = string # DNS record type, e.g. "A"<br>        ttl  = number # num seconds TTL<br>      }))<br>    }))<br>    health_check_custom_failure_threshold = optional(number)<br>    tags                                  = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_task_definition"></a> [task\_definition](#input\_task\_definition) | Config object for the ECS Task Definition resource. "container\_definitions"<br>must be a JSON-encoded string; refer to AWS docs for an explanation of how<br>to write valid container definitions. If "cpu" or "memory" are not provided,<br>their values will be computed using the "instance\_type" provided in<br>var.task\_host\_launch\_template, which currently defaults to "t3a.micro". | <pre>object({<br>    name                    = string<br>    cpu                     = optional(number)<br>    memory                  = optional(number)<br>    task_execution_role_arn = string # Used to start containers<br>    task_role_arn           = string # Used to access AWS resources during runtime<br>    container_definitions   = string<br>    tags                    = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_task_host_launch_template"></a> [task\_host\_launch\_template](#input\_task\_host\_launch\_template) | Config object for the Task host's launch template resource. If the "instance\_type"<br>is not provided, the default that will be used is "t3a.micro". Note that this default<br>is subject to change over time as prices fluctuate and different features become<br>available, so if a service/workload needs a particular type of instance for whatever<br>reason, it is highly recommended that you provide an explicit instance type value. If<br>"ami\_id" is not provided, the "image\_id" will default to the latest version of the<br>AWS-managed "ECS Optimized" AMI. Please note that in the near future, the default will<br>be changed to the Nerdware Hardened Base AMI image. | <pre>object({<br>    name                          = string<br>    description                   = optional(string)<br>    should_update_default_version = optional(bool) # Default: true<br>    instance_type                 = optional(string)<br>    ami_id                        = optional(string)<br>    user_data                     = optional(string)<br>    tags                          = optional(map(string))<br>  })</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_AutoScaling_Group"></a> [AutoScaling\_Group](#output\_AutoScaling\_Group) | The AutoScaling Group resource object. |
| <a name="output_CapacityProvider"></a> [CapacityProvider](#output\_CapacityProvider) | The Capacity Provider resource object. |
| <a name="output_ECS_Service"></a> [ECS\_Service](#output\_ECS\_Service) | The ECS Service resource object. |
| <a name="output_LaunchTemplate"></a> [LaunchTemplate](#output\_LaunchTemplate) | The Task Host Launch Template resource object. |
| <a name="output_Service_Discovery_Service"></a> [Service\_Discovery\_Service](#output\_Service\_Discovery\_Service) | The Service Discovery Service resource object. |
| <a name="output_TaskDefinition"></a> [TaskDefinition](#output\_TaskDefinition) | The Task Definition resource object. |

---

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center" style="margin-top:30px;">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [Trevor@Nerdware.cloud](mailto:trevor@nerdware.cloud)

  <a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
    <img src="/.github/assets/YouTube\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/meet-trevor-anderson/">
    <img src="/.github/assets/LinkedIn\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://twitter.com/TeeRevTweets">
    <img src="/.github/assets/Twitter\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="mailto:trevor@nerdware.cloud">
    <img src="/.github/assets/email\_icon\_circle.svg" height="40" />
  </a>
  <br><br>

  <a href="https://daremightythings.co/">
    <strong><i>Dare Mighty Things.</i></strong>
  </a>

</div>
<!-- prettier-ignore-end -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
