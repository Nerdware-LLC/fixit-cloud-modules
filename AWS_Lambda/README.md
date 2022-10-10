<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS Lambda</h1>

Terraform module for defining and managing an AWS Lambda function.

</div>

<h2>Table of Contents</h2>

- [Useful Links](#useful-links)
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

## Useful Links

- AWS Lambda Documentation:
  - [Lambda API Reference](https://docs.aws.amazon.com/lambda/latest/dg/API_Reference.html)
  - [Lambda Event Source Mapping: Filter Syntax](https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventfiltering.html#filtering-syntax)

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
| [aws_iam_policy.Lambda_ExecRole_Policies_Map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.Lambda_ExecRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.Lambda_ExecRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_provisioned_concurrency_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_provisioned_concurrency_config) | resource |
| [aws_iam_policy_document.Lambda_ExecRole_Policies_Map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dead_letter_target_arn"></a> [dead\_letter\_target\_arn](#input\_dead\_letter\_target\_arn) | (Optional) ARN of SNS Topic or SQS Queue to notify when a function invocation<br>fails. If this option is used, the function's IAM role must be granted suitable<br>access to write to the target object, which means allowing either the sns:Publish<br>or sqs:SendMessage action on this ARN, depending on which service is targeted. | `string` | `null` | no |
| <a name="input_deployment_package_src"></a> [deployment\_package\_src](#input\_deployment\_package\_src) | The Lambda deployment package source; must be either an absolute path<br>to an executable on the local filesystem, an image URI, or an object<br>configuring retrieval from an S3 bucket. | <pre>object({<br>    local_file_abs_path = optional(string)<br>    image_uri           = optional(string)<br>    s3_bucket = optional(object({<br>      bucket_name    = string<br>      object_key     = string<br>      object_version = string<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The Lambda function description. | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | (Optional) Map of env vars to make accessible to the function during execution. | `map(string)` | `null` | no |
| <a name="input_event_source_mapping"></a> [event\_source\_mapping](#input\_event\_source\_mapping) | (Optional) Config object to setup an event source mapping for the Lambda function.<br>This allows Lambda functions to get events from Kinesis, DynamoDB, SQS, Amazon MQ<br>and Managed Streaming for Apache Kafka (MSK). Reference documentation for these<br>arguments is available [here][var-ref-event-src-mapping]. | <pre>object({<br>    enabled                            = optional(bool)<br>    event_source_arn                   = optional(string)<br>    filter_patterns                    = optional(list(string))<br>    starting_position                  = optional(string)<br>    starting_position_timestamp        = optional(string) # RFC3339 timestamp<br>    queues                             = optional(string)<br>    batch_size                         = optional(number)<br>    maximum_batching_window_in_seconds = optional(number)<br>    maximum_record_age_in_seconds      = optional(number)<br>    maximum_retry_attempts             = optional(number)<br>    destination_config = optional(object({<br>      on_success_dest_resource_arn = string<br>      on_failure_dest_resource_arn = optional(string)<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_execution_role"></a> [execution\_role](#input\_execution\_role) | Config object for the Lambda function's execution role. | <pre>object({<br>    name               = string<br>    description        = optional(string)<br>    path               = optional(string)<br>    tags               = optional(map(string))<br>    attach_policy_arns = optional(list(string))<br>    attach_policies = optional(map(<br>      # map keys: IAM policy names/IDs<br>      object({<br>        policy_json = optional(string)<br>        statements = optional(list(object({<br>          sid       = optional(string)<br>          effect    = string<br>          actions   = list(string)<br>          resources = optional(list(string))<br>          conditions = optional(map(<br>            # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")<br>            object({<br>              key    = string<br>              values = list(string)<br>            })<br>          ))<br>        })))<br>        description = optional(string)<br>        path        = optional(string)<br>        tags        = optional(map(string))<br>      })<br>    ))<br>  })</pre> | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | The Lambda function handler. | `string` | `"index.handler"` | no |
| <a name="input_lambda_permissions"></a> [lambda\_permissions](#input\_lambda\_permissions) | (Optional) Map of principal names to Lambda permission config objects. Gives an<br>external source (like an EventBridge Rule, SNS, or S3) permission to access the<br>Lambda function. The principals can be AWS services, like "events.amazonaws.com",<br>or AWS account IDs - any external principal that requires permission to invoke<br>the Lambda function. With "qualifier" you can optionally narrow the permission to<br>just a specific version or function alias. To ensure the permissions granted are<br>not too broad, AWS service principals must be provided with a "source\_arn"; for<br>example, if the principal is EventBridge (events.amazonaws.com), the "source\_arn"<br>would be that of the EventBridge Rule. "principal\_org\_id" can be used to provide<br>permissions to all accounts within an Organization. | <pre>map(<br>    # map keys: principal names ("events.amazonaws.com", account IDs, etc.)<br>    object({<br>      action           = string # e.g., "lambda:InvokeFunction"<br>      statement_id     = optional(string)<br>      qualifier        = optional(string) # option to specify a version or alias<br>      source_account   = optional(string)<br>      source_arn       = optional(string) # Required if principal is an AWS service<br>      principal_org_id = optional(string) # Principal would be the Org root account<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The Lambda function name. | `string` | n/a | yes |
| <a name="input_provisioned_concurrent_executions"></a> [provisioned\_concurrent\_executions](#input\_provisioned\_concurrent\_executions) | (Optional) Amount of capacity to allocate. Must be greater than or equal to 1 (default 1). | `number` | `1` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | (Optional) The Lambda function runtime; see link below for valid runtime values.<br>https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) The Lambda function tags. | `map(string)` | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | (Optional) VPC configs for the Lambda function. | <pre>object({<br>    security_group_ids = list(string)<br>    subnet_ids         = list(string)<br>  })</pre> | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Lambda_Event_Source_Mappings"></a> [Lambda\_Event\_Source\_Mappings](#output\_Lambda\_Event\_Source\_Mappings) | Map of Lambda event source mapping resource objects. |
| <a name="output_Lambda_Function"></a> [Lambda\_Function](#output\_Lambda\_Function) | The Lambda function resource object. |
| <a name="output_Lambda_Function_ExecutionRole"></a> [Lambda\_Function\_ExecutionRole](#output\_Lambda\_Function\_ExecutionRole) | The Lambda function execution role resource object. |
| <a name="output_Lambda_Function_Permissions"></a> [Lambda\_Function\_Permissions](#output\_Lambda\_Function\_Permissions) | Map of Lambda function permission resource objects. |
| <a name="output_Lambda_Function_Provisioned_Concurrency_Config"></a> [Lambda\_Function\_Provisioned\_Concurrency\_Config](#output\_Lambda\_Function\_Provisioned\_Concurrency\_Config) | The Lambda function provisoined concurrency config resource object. |

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

<!-- LINKS -->

<!-- Below link in variables.tf -->

[var-ref-event-src-mapping]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping
