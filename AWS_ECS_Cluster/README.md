<h1>Fixit Cloud ☁️ MODULE: AWS ECS Cluster</h1>

Terraform module for defining an ECS Cluster with related resources.

- [⚙️ Module Usage](#️-module-usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)

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
| [aws_appmesh_mesh.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_mesh) | resource |
| [aws_appmesh_route.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_route) | resource |
| [aws_appmesh_virtual_node.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_node) | resource |
| [aws_appmesh_virtual_router.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_router) | resource |
| [aws_appmesh_virtual_service.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_service) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_service_discovery_private_dns_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_mesh"></a> [app\_mesh](#input\_app\_mesh) | Config object for the App Mesh resource. | <pre>object({<br>    name                        = string<br>    should_allow_egress_traffic = optional(bool)<br>    tags                        = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_app_mesh_nodes"></a> [app\_mesh\_nodes](#input\_app\_mesh\_nodes) | Map of AppMesh Node names to config objects. | <pre>map(<br>    # map keys: node names e.g. "serviceBv1"<br>    object({<br>      service_name    = string<br>      cloud_map_stack = string<br>      # TODO add health_check<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_app_mesh_routers"></a> [app\_mesh\_routers](#input\_app\_mesh\_routers) | Map of AppMesh Virtual Router names to config objects. "protocol"<br>can be either "http", "http2", "tcp", or "grpc". | <pre>map(<br>    # map keys: router names<br>    object({<br>      port     = number<br>      protocol = string<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_app_mesh_routes"></a> [app\_mesh\_routes](#input\_app\_mesh\_routes) | Map of AppMesh Route names to route config objects. "spec" must have a<br>"priority" between 0-1000 and a "type", which can be "http\_route", "http2\_route",<br>"tcp\_route", or "grpc\_route". | <pre>map(<br>    # map keys: AppMesh route names e.g. "serviceB-route"<br>    object({<br>      virtual_router_name = string<br>      type                = string # "http_route", "http2_route", "tcp_route", or "grpc_route"<br>      spec = object({<br>        action = string<br>        match = optional(object({<br>          method = string<br>          prefix = string<br>        }))<br>        retry_policy = string<br>        timeout      = number<br>      })<br>      tags = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_app_mesh_services"></a> [app\_mesh\_services](#input\_app\_mesh\_services) | Map of AppMesh Service names to config objects. | <pre>map(<br>    # map keys: service names e.g. "servicea.simpleapp.local"<br>    object({<br>      provider_type = string # "ROUTER" or "NODE"<br>      provider_name = string<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | Config object for the ECS Cluster and its CloudWatch Logs log group. The<br>"should\_enable\_container\_insights" property defaults to "true". If a<br>value for "cloudwatch\_log\_group.retention\_in\_days" is not provided, the<br>default is 400 days. ECS Exec will be enabled if "ecs\_exec\_kms\_key\_alias"<br>is provided; to ensure it's DISABLED, simply don't provide a value or set<br>it to "null". | <pre>object({<br>    name                   = string<br>    capacity_provider_arns = optional(list(string))<br>    tags                   = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_ecs_exec_config"></a> [ecs\_exec\_config](#input\_ecs\_exec\_config) | (Optional) Config object for "ECS Exec". Should not be used in production.<br>"kms\_key\_id", if provided, will be used to encrypt the data between the local<br>client and container. If you'd like to view logs from ECS Exec activity, you<br>can optionally have logs sent to a CloudWatch Logs log group and/or an S3 Bucket. | <pre>object({<br>    should_enable_ecs_exec       = bool<br>    kms_key_id                   = optional(string)<br>    cloud_watch_log_group_name   = optional(string)<br>    s3_bucket_name               = optional(string)<br>    s3_bucket_encryption_enabled = optional(string)<br>    s3_key_prefix                = optional(string)<br>  })</pre> | <pre>{<br>  "should_enable_ecs_exec": false<br>}</pre> | no |
| <a name="input_service_discovery_namespace"></a> [service\_discovery\_namespace](#input\_service\_discovery\_namespace) | Config object for the "aws\_service\_discovery\_private\_dns\_namespace" resource. | <pre>object({<br>    name        = string<br>    description = string<br>    vpc_id      = string<br>    tags        = optional(map(string))<br>  })</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_AppMesh"></a> [AppMesh](#output\_AppMesh) | The App Mesh resource object. |
| <a name="output_AppMesh_Nodes"></a> [AppMesh\_Nodes](#output\_AppMesh\_Nodes) | Map of App Mesh Virtual Node resource objects. |
| <a name="output_AppMesh_Routers"></a> [AppMesh\_Routers](#output\_AppMesh\_Routers) | Map of App Mesh Virtual Router resource objects. |
| <a name="output_AppMesh_Routes"></a> [AppMesh\_Routes](#output\_AppMesh\_Routes) | Map of App Mesh Route resource objects. |
| <a name="output_AppMesh_Services"></a> [AppMesh\_Services](#output\_AppMesh\_Services) | Map of App Mesh Virtual Service resource objects. |
| <a name="output_ECS_Cluster"></a> [ECS\_Cluster](#output\_ECS\_Cluster) | The ECS Cluster resource object. |
| <a name="output_ECS_Cluster_CapacityProviders"></a> [ECS\_Cluster\_CapacityProviders](#output\_ECS\_Cluster\_CapacityProviders) | The cluster's Capacity Provider resource objects. |
| <a name="output_ECS_Service_Discovery_Namespace"></a> [ECS\_Service\_Discovery\_Namespace](#output\_ECS\_Service\_Discovery\_Namespace) | The cluster's Service Discovery Namespace resource object. |

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
