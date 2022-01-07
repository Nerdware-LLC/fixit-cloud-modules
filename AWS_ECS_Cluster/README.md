# Fixit Cloud Module: AWS ECS Cluster

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.Default_CapacityProvider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.ECS_Cluster_CloudWatch_LogGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_capacity_provider.Default_CapacityProvider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_launch_template.Default_CapacityProvider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_service_discovery_private_dns_namespace.ECS_Service_Discovery_Namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_ami.ECS_Optimized_AMI](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_kms_alias.ECS_Cluster_CloudWatch_LogGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_kms_alias.ECS_Exec_Key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_capacity_provider"></a> [default\_capacity\_provider](#input\_default\_capacity\_provider) | Config object for the cluster's default capacity provider. | <pre>object({<br>    name = optional(string)<br>    tags = optional(map(string))<br>    autoscaling_group = optional(object({<br>      name = optional(string)<br>      tags = optional(map(string))<br>      launch_template = optional(object({<br>        name        = optional(string)<br>        description = optional(string)<br>        tags        = optional(map(string))<br>      }))<br>    }))<br>  })</pre> | <pre>{<br>  "autoscaling_group": {<br>    "launch_template": {<br>      "description": "Terraform-managed launch template for an ECS Cluster's default capacity provider.",<br>      "name": "Default_CapacityProvider_LaunchTemplate",<br>      "tags": {<br>        "Name": "Default_CapacityProvider_LaunchTemplate"<br>      }<br>    },<br>    "name": "Default_CapacityProvider_AutoScaling_Group",<br>    "tags": {<br>      "Name": "Default_CapacityProvider_AutoScaling_Group"<br>    }<br>  },<br>  "name": "Default_CapacityProvider",<br>  "tags": {<br>    "Name": "Default_CapacityProvider"<br>  }<br>}</pre> | no |
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | Config object for the ECS Cluster and its CloudWatch Logs log group. If<br>a value for "retention\_in\_days" is not provided, the default is 400 days.<br>ECS Exec will be enabled if "ecs\_exec\_kms\_key\_alias" is provided; to ensure<br>it's DISABLED, simply don't provide a value or set it to "null". | <pre>object({<br>    name                   = string<br>    capacity_provider_arns = optional(list(string))<br>    ecs_exec_kms_key_alias = optional(string)<br>    tags                   = optional(map(string))<br>    cloudwatch_log_group = object({<br>      name              = string<br>      kms_key_alias     = string<br>      retention_in_days = optional(number)<br>      tags              = optional(map(string))<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_service_discovery_namespace"></a> [service\_discovery\_namespace](#input\_service\_discovery\_namespace) | Config object for the "aws\_service\_discovery\_private\_dns\_namespace" resource. | <pre>object({<br>    name        = string<br>    description = string<br>    vpc_id      = string<br>    tags        = optional(map(string))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Default_CapacityProvider"></a> [Default\_CapacityProvider](#output\_Default\_CapacityProvider) | The cluster's default Capacity Provider resource object. |
| <a name="output_Default_CapacityProvider_AutoScaling_Group"></a> [Default\_CapacityProvider\_AutoScaling\_Group](#output\_Default\_CapacityProvider\_AutoScaling\_Group) | The AutoScaling Group resource of the cluster's default capacity provider. |
| <a name="output_Default_CapacityProvider_AutoScaling_Group_LaunchTemplate"></a> [Default\_CapacityProvider\_AutoScaling\_Group\_LaunchTemplate](#output\_Default\_CapacityProvider\_AutoScaling\_Group\_LaunchTemplate) | The Launch Template resource used in the default capacity provider's autoscaling group. |
| <a name="output_ECS_Cluster"></a> [ECS\_Cluster](#output\_ECS\_Cluster) | The ECS Cluster resource object. |
| <a name="output_ECS_Cluster_CloudWatch_LogGroup"></a> [ECS\_Cluster\_CloudWatch\_LogGroup](#output\_ECS\_Cluster\_CloudWatch\_LogGroup) | The CloudWatch Logs log group for the ECS Cluster. |
| <a name="output_ECS_Service_Discovery_Namespace"></a> [ECS\_Service\_Discovery\_Namespace](#output\_ECS\_Service\_Discovery\_Namespace) | The cluster's Service Discovery Namespace resource object. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->