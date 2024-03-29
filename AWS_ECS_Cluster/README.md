<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS ECS Cluster</h1>

Terraform module for defining an ECS Cluster, complete with AppMesh and other related resources.

</div>

<h3>Table of Contents</h3>

- [🔗 Helpful Links](#-helpful-links)
- [⚙️ Module Usage](#️-module-usage)
  - [Usage Examples](#usage-examples)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)

## 🔗 Helpful Links

- [AWS Docs: Task Definition Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html)
  - [Container Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions)
  - [Network Mode](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#network_mode)
- [AWS Docs: Service Definition Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-start -->

---

## ⚙️ Module Usage

### Usage Examples

- Terragrunt: [view Terragrunt usage exmaple](examples/terragrunt.hcl)
- Terraform: &nbsp;[view vanilla Terraform usage exmaple](examples/terraform.tf)

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.34.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.34.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_appmesh_mesh.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_mesh) | resource |
| [aws_appmesh_route.http2_routes_map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_route) | resource |
| [aws_appmesh_route.http_routes_map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_route) | resource |
| [aws_appmesh_virtual_node.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_node) | resource |
| [aws_appmesh_virtual_router.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_router) | resource |
| [aws_appmesh_virtual_service.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_service) | resource |
| [aws_autoscaling_group.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_ecs_capacity_provider.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_launch_template.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_service_discovery_private_dns_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_service_discovery_service.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_ami.ECS_Optimized_AMI](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_instance_type.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appmesh_mesh"></a> [appmesh\_mesh](#input\_appmesh\_mesh) | Config object for the App Mesh resource. | <pre>object({<br>    name                        = string<br>    should_allow_egress_traffic = optional(bool)<br>    tags                        = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_appmesh_nodes"></a> [appmesh\_nodes](#input\_appmesh\_nodes) | Map of AppMesh Node names to config objects. | <pre>map(<br>    # map keys: node names e.g. "serviceBv1"<br>    object({<br>      service_name         = string<br>      service_dns_hostname = optional(string)<br>      listener_port_mappings = set(object({<br>        port     = number<br>        protocol = string<br>      }))<br>      cloud_map_config = optional(object({<br>        stack = string<br>      }))<br>      # TODO add health_check<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_appmesh_routers"></a> [appmesh\_routers](#input\_appmesh\_routers) | Map of AppMesh Virtual Router names to config objects. "protocol"<br>can be either "http", "http2", "tcp", or "grpc". | <pre>map(<br>    # map keys: router names<br>    object({<br>      port     = number<br>      protocol = string<br>      tags     = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_appmesh_routes"></a> [appmesh\_routes](#input\_appmesh\_routes) | Map of AppMesh Route names to route config objects. "spec" must have a<br>"priority" between 0-1000 and a "type", which can be "http\_route" or "http2\_route"<br>(support for "tcp\_route" and "grpc\_route" will be added in the future). | <pre>map(<br>    # map keys: AppMesh route names e.g. "serviceB-route"<br>    object({<br>      virtual_router_name = string<br>      type                = string # "http_route" or "http2_route" (future support: "tcp_route"/"grpc_route")<br>      spec = object({<br>        action_targets = map(<br>          # map keys: appmesh node names<br>          object({<br>            weight = number<br>        }))<br>        match = object({<br>          prefix = string<br>          method = optional(string)<br>          scheme = optional(string) # can be "http" or "https"<br>          header = optional(object({<br>            name   = string<br>            invert = optional(bool)<br>            match = optional(object({<br>              exact  = optional(string)<br>              prefix = optional(string)<br>              suffix = optional(string)<br>              regex  = optional(string)<br>              range = optional(object({<br>                start = string<br>                end   = string<br>              }))<br>            }))<br>          }))<br>        })<br>        retry_policy = object({<br>          max_retries       = number<br>          http_retry_events = optional(list(string))<br>          tcp_retry_events  = optional(list(string))<br>          per_retry_timeout = object({<br>            unit : string # "ms" or "s"<br>            value = number<br>          })<br>        })<br>        idle_timeout = optional(object({<br>          unit : string # "ms" or "s"<br>          value = number<br>        }))<br>      })<br>      tags = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_appmesh_services"></a> [appmesh\_services](#input\_appmesh\_services) | Map of AppMesh Service names to config objects. All "provider\_type"<br>values must be either "NODE" or "ROUTER". | <pre>map(<br>    # map keys: service names e.g. "servicea.simpleapp.local"<br>    object({<br>      provider_type = string # "ROUTER" or "NODE"<br>      provider_name = string<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_autoscaling_groups"></a> [autoscaling\_groups](#input\_autoscaling\_groups) | Map of autoscaling group names to config objects. All "task\_host\_launch\_template\_name"<br>values must be unique, and must point to a task host launch template defined in<br>var.task\_host\_launch\_templates. If not provided, "task\_host\_launch\_template\_version"<br>defaults to "$Default". | <pre>map(<br>    # map keys: autoscaling group names<br>    object({<br>      subnet_ids                        = list(string)<br>      task_host_launch_template_name    = string<br>      task_host_launch_template_version = optional(string)<br>      instance_count = object({<br>        min     = number<br>        desired = number<br>        max     = number<br>      })<br>      tags = optional(set(object({<br>        key                 = string<br>        value               = string<br>        propagate_at_launch = bool<br>      })))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | Map of capacity provider names to config objects. All "autoscaling\_group\_name"<br>values must be unique, and must point to an ASG defined in var.autoscaling\_groups.<br>The managed\_scaling step\_size params are both optional, and default to "1" if not<br>provided. If provided, the value(s) must be between 1 and 10,000. If not provided,<br>"should\_enable\_managed\_termination\_protection" defaults to "true". | <pre>map(<br>    # map keys: capacity provider names<br>    object({<br>      autoscaling_group_name = string<br>      managed_scaling = object({<br>        is_enabled                = bool<br>        minimum_scaling_step_size = optional(number)<br>        maximum_scaling_step_size = optional(number)<br>        # TODO Add params "instance_warmup_period", "target_capacity"<br>      })<br>      should_enable_managed_termination_protection = optional(bool)<br>      tags                                         = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | Config object for the ECS Cluster resource object. ECS Exec will be<br>disabled by default, unless "ecs\_exec\_config.should\_enable" is true.<br>"kms\_key\_id", if provided, will be used to encrypt the data between<br>the local client and container. If you'd like to view logs from ECS<br>Exec activity, you can optionally have logs sent to a CloudWatch Logs<br>log group and/or an S3 Bucket. | <pre>object({<br>    name = string<br>    ecs_exec_config = optional(object({<br>      should_enable                = bool<br>      kms_key_id                   = optional(string)<br>      cloud_watch_log_group_name   = optional(string)<br>      s3_bucket_name               = optional(string)<br>      s3_bucket_encryption_enabled = optional(string)<br>      s3_key_prefix                = optional(string)<br>    }))<br>    tags = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_ecs_services"></a> [ecs\_services](#input\_ecs\_services) | Map of ECS Service names to config objects. All "capacity\_provider\_name"<br>values must be unique, and must point to a capacity provider defined in<br>var.capacity\_providers. All "task\_definition\_name" values must be unique,<br>and must point to a task definition defined in var.task\_definitions. All<br>"service\_discovery\_service" values must be unique, and must point to a<br>service discovery service defined in var.service\_discovery\_services.<br>Regarding "rolling\_update\_controls", set "force\_new\_deployment" to "true"<br>after the AMI pipeline updates the service image. Min/Max default to<br>100/200, respectively. | <pre>map(<br>    # map keys: ecs service names<br>    object({<br>      task_definition_name      = string<br>      capacity_provider_name    = string<br>      service_discovery_service = string<br>      network_configs = object({<br>        assign_public_ip   = bool<br>        subnet_ids         = list(string)<br>        security_group_ids = list(string)<br>      })<br>      load_balancer_config = optional(object({<br>        target_group_arn = string<br>        container_name   = string<br>        container_port   = number<br>      }))<br>      rolling_update_controls = optional(object({<br>        force_new_deployment               = bool<br>        deployment_minimum_healthy_percent = optional(number)<br>        deployment_maximum_percent         = optional(number)<br>      }))<br>      enable_ecs_exec = optional(bool)<br>      tags            = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_service_discovery_namespace"></a> [service\_discovery\_namespace](#input\_service\_discovery\_namespace) | Config object for the service discovery namespace. | <pre>object({<br>    name        = string<br>    description = string<br>    vpc_id      = string<br>    tags        = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_service_discovery_services"></a> [service\_discovery\_services](#input\_service\_discovery\_services) | Map of service discovery service names to config objects. The<br>"routing\_policy" DNS config, if provided, can be either "MULTIVALUE" or<br>"WEIGHTED". "health\_check\_custom\_failure\_threshold", if provided, must<br>be a number between 1-10 which shall implement the number of 30-second<br>intervals the service discovery service should wait before it changes the<br>health status of a service instance. | <pre>map(<br>    # map keys: service discovery service names<br>    object({<br>      dns_config = optional(object({<br>        routing_policy = optional(string) # null, "MULTIVALUE", or "WEIGHTED"<br>        dns_records = set(object({<br>          type = string # DNS record type, e.g. "A"<br>          ttl  = number # num seconds TTL<br>        }))<br>      }))<br>      health_check_custom_failure_threshold = optional(number)<br>      tags                                  = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_task_definitions"></a> [task\_definitions](#input\_task\_definitions) | Map of ECS Task Definition names to config objects. All "ecs\_service" values must<br>be unique, and must point to an ECS Service defined in var.ecs\_services. All Task<br>Definitions must include "container\_definitions", a map of container-enums to container<br>def config objects. Supported container-enum keys are "SERVICE", "ENVOY" - both of<br>which are required - and optionally "XRAY".<br>Please refer to AWS docs regarding the keys/values of ECS container definitions<br>([link here](#🔗-helpful-links)). Regarding "proxy\_config", all "appmesh\_node\_name"<br>values must be unique, and must point to an AppMesh Node defined in var.appmesh\_nodes.<br>"egress\_ignored\_ips" defaults to "169.254.170.2,169.254.169.254" if not provided.<br>The ingress/egress port values default to 15000/15001. If "cpu" or "memory" are not<br>provided, their values will be computed using "instance\_type" if provided. | <pre>map(<br>    # map keys: task definition names<br>    object({<br>      ecs_service = string<br>      container_definitions = map(<br>        # map keys: "SERVICE", "ENVOY", and optionally "XRAY"<br>        object({<br>          name  = string<br>          image = string<br>          portMappings = list(object({<br>            containerPort = number<br>            hostPort      = number<br>            protocol      = string<br>          }))<br>          logConfiguration = object({<br>            logDriver = string<br>            options = object({<br>              awslogs-region        = string<br>              awslogs-group         = string<br>              awslogs-stream-prefix = string<br>            })<br>          })<br>          linuxParameters = optional(object({<br>            capabilities = object({<br>              add  = list(string)<br>              drop = list(string)<br>            })<br>          }))<br>          dependsOn = optional(list(object({<br>            containerName = string<br>            condition     = string<br>          })))<br>          environment = optional(list(object({<br>            name  = string<br>            value = string<br>          })))<br>          environmentFiles = optional(list(object({<br>            type  = string<br>            value = string<br>          })))<br>          cpu               = optional(number)<br>          memoryReservation = optional(number)<br>          user              = optional(string)<br>          healthCheck = optional(object({<br>            command     = list(string)<br>            startPeriod = number<br>            interval    = number<br>            timeout     = number<br>            retries     = number<br>          }))<br>        })<br>      )<br>      task_execution_role_arn = string # Used to start containers<br>      task_role_arn           = string # Used to access AWS resources during runtime<br>      instance_type           = optional(string)<br>      cpu                     = optional(number)<br>      memory                  = optional(number)<br>      proxy_config = object({<br>        appmesh_node_name  = string           # Example: "Nginx_node1"<br>        egress_ignored_ips = optional(string) # Default: "169.254.170.2,169.254.169.254"<br>        proxy_ingress_port = optional(number) # Default: 15000<br>        proxy_egress_port  = optional(number) # Default: 15001<br>      })<br>      tags = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_task_host_launch_templates"></a> [task\_host\_launch\_templates](#input\_task\_host\_launch\_templates) | Map of launch template names to config objects. The launch templates configured by<br>this variable define Task Hosts for ECS Service AutoScaling Groups (referred to as<br>"Container Instances" in AWS documentation parlance). If "ami\_id" is not provided,<br>the "image\_id" will default to the latest version of the AWS-managed "ECS Optimized"<br>AMI. Please note that this default is subject to change. | <pre>map(<br>    # map keys: launch template names<br>    object({<br>      instance_type                 = string<br>      description                   = optional(string)<br>      should_update_default_version = optional(bool) # Default: true<br>      ami_id                        = optional(string)<br>      user_data                     = optional(string)<br>      tags                          = optional(map(string))<br>      tag_specifications = optional(set(object({<br>        resource_type = string # Refer to AWS docs for valid values<br>        tags          = map(string)<br>      })))<br>    })<br>  )</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_AppMesh"></a> [AppMesh](#output\_AppMesh) | The App Mesh resource object. |
| <a name="output_AppMesh_Nodes"></a> [AppMesh\_Nodes](#output\_AppMesh\_Nodes) | Map of App Mesh Virtual Node resource objects. |
| <a name="output_AppMesh_Routers"></a> [AppMesh\_Routers](#output\_AppMesh\_Routers) | Map of App Mesh Virtual Router resource objects. |
| <a name="output_AppMesh_Routes"></a> [AppMesh\_Routes](#output\_AppMesh\_Routes) | Map of App Mesh Route resource objects. |
| <a name="output_AppMesh_Services"></a> [AppMesh\_Services](#output\_AppMesh\_Services) | Map of App Mesh Virtual Service resource objects. |
| <a name="output_AutoScaling_Groups"></a> [AutoScaling\_Groups](#output\_AutoScaling\_Groups) | Map of AutoScaling Group resource objects. |
| <a name="output_Capacity_Providers"></a> [Capacity\_Providers](#output\_Capacity\_Providers) | Map of Capacity Provider resource objects. |
| <a name="output_ECS_Cluster"></a> [ECS\_Cluster](#output\_ECS\_Cluster) | The ECS Cluster resource object. |
| <a name="output_ECS_Services"></a> [ECS\_Services](#output\_ECS\_Services) | Map of ECS Service resource objects. |
| <a name="output_Service_Discovery_Namespace"></a> [Service\_Discovery\_Namespace](#output\_Service\_Discovery\_Namespace) | The Service Discovery "private DNS" Namespace resource object. |
| <a name="output_Service_Discovery_Services"></a> [Service\_Discovery\_Services](#output\_Service\_Discovery\_Services) | Map of Service Discovery Service resource objects. |
| <a name="output_Task_Definition"></a> [Task\_Definition](#output\_Task\_Definition) | Map of Task Definition resource objects. |
| <a name="output_Task_Host_Launch_Template"></a> [Task\_Host\_Launch\_Template](#output\_Task\_Host\_Launch\_Template) | Map of Task Host Launch Template resource objects. |

---

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center" style="margin-top:30px;">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [Trevor@Nerdware.cloud](mailto:trevor@nerdware.cloud)

<a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
<img src="../.github/assets/YouTube_icon_circle.svg" height="40" />
</a>
&nbsp;
<a href="https://www.linkedin.com/in/meet-trevor-anderson/">
<img src="../.github/assets/LinkedIn_icon_circle.svg" height="40" />
</a>
&nbsp;
<a href="https://twitter.com/TeeRevTweets">
<img src="../.github/assets/Twitter_icon_circle.svg" height="40" />
</a>
&nbsp;
<a href="mailto:trevor@nerdware.cloud">
<img src="../.github/assets/email_icon_circle.svg" height="40" />
</a>
<br><br>

<a href="https://daremightythings.co/">
<strong><i>Dare Mighty Things.</i></strong>
</a>

</div>

<!-- prettier-ignore-end -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
