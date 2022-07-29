<h1>Fixit Cloud ☁️ MODULE: AWS Lambda</h1>

Terraform module for defining Lambda resources.

<h2>Table of Contents</h2>

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.6 |
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
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dead_letter_target_arn"></a> [dead\_letter\_target\_arn](#input\_dead\_letter\_target\_arn) | (Optional) ARN of SNS Topic or SQS Queue to notify when a function invocation<br>fails. If this option is used, the function's IAM role must be granted suitable<br>access to write to the target object, which means allowing either the sns:Publish<br>or sqs:SendMessage action on this ARN, depending on which service is targeted. | `string` | `null` | no |
| <a name="input_deployment_package_src"></a> [deployment\_package\_src](#input\_deployment\_package\_src) | The Lambda deployment package source; must be either an absolute path<br>to an executable on the local filesystem, an image URI, or an object<br>configuring retrieval from an S3 bucket. | <pre>object({<br>    local_file_abs_path = optional(string)<br>    image_uri           = optional(string)<br>    s3_bucket = optional(object({<br>      bucket_name    = string<br>      object_key     = string<br>      object_version = string<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The Lambda function description. | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | (Optional) Map of env vars to make accessible to the function during execution. | `map(string)` | `null` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | The IAM Role ARN for the function's execution role. | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | The Lambda function handler. | `string` | `"index.handler"` | no |
| <a name="input_name"></a> [name](#input\_name) | The Lambda function name. | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | (Optional) The Lambda function runtime; see link below for valid runtime values.<br>https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) The Lambda function tags. | `map(string)` | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | (Optional) VPC configs for the Lambda function. | <pre>object({<br>    security_group_ids = list(string)<br>    subnet_ids         = list(string)<br>  })</pre> | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Lambda_Function"></a> [Lambda\_Function](#output\_Lambda\_Function) | The Lambda function resource object. |

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
