<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS CloudTrail</h2>

Terraform module for defining a multi-region AWS CloudTrail resource.

</div>

<h2>Table of Contents</h2>

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
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_watch_logs_config"></a> [cloud\_watch\_logs\_config](#input\_cloud\_watch\_logs\_config) | Config object for delivery of CloudTrail log files to a<br>CloudWatch Logs log group. | <pre>object({<br>    log_group_arn                  = string<br>    logs_delivery_service_role_arn = string<br>  })</pre> | n/a | yes |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Boolean indicator as to whether the CloudTrail trail should<br>include global service events (default: false). | `bool` | `false` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | Boolean indicator as to whether the CloudTrail trail is<br>an organization trail (default: false). | `bool` | `false` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | Logging config object for the CloudTrail trail. If the S3 Bucket<br>uses a KMS Key for SSE, provide the ARN to "sse\_kms\_key\_arn". | <pre>object({<br>    s3_bucket_name  = string<br>    sse_kms_key_arn = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_trail_name"></a> [trail\_name](#input\_trail\_name) | The name of the CloudTrail trail. | `string` | n/a | yes |
| <a name="input_trail_tags"></a> [trail\_tags](#input\_trail\_tags) | Tags for the CloudTrail trail. | `map(string)` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_CloudTrail_Trail"></a> [CloudTrail\_Trail](#output\_CloudTrail\_Trail) | The CloudTrail trail resource object. |

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
