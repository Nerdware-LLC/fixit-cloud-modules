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

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | 1.2.7     |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.11.0 |

### Providers

| Name                                             | Version   |
| ------------------------------------------------ | --------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 4.11.0 |

### Modules

No modules.

### Resources

| Name                                                                                                          | Type     |
| ------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |

### Inputs

| Name                                                                                                                     | Description                                                                                                                       | Type                                                                                              | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_cloud_watch_logs_config"></a> [cloud_watch_logs_config](#input_cloud_watch_logs_config)                   | Config object for delivery of CloudTrail log files to a<br>CloudWatch Logs log group.                                             | <pre>object({<br> log_group_arn = string<br> logs_delivery_service_role_arn = string<br> })</pre> | n/a     |   yes    |
| <a name="input_include_global_service_events"></a> [include_global_service_events](#input_include_global_service_events) | Boolean indicator as to whether the CloudTrail trail should<br>include global service events (default: false).                    | `bool`                                                                                            | `false` |    no    |
| <a name="input_is_organization_trail"></a> [is_organization_trail](#input_is_organization_trail)                         | Boolean indicator as to whether the CloudTrail trail is<br>an organization trail (default: false).                                | `bool`                                                                                            | `false` |    no    |
| <a name="input_logging_config"></a> [logging_config](#input_logging_config)                                              | Logging config object for the CloudTrail trail. If the S3 Bucket<br>uses a KMS Key for SSE, provide the ARN to "sse_kms_key_arn". | <pre>object({<br> s3_bucket_name = string<br> sse_kms_key_arn = optional(string)<br> })</pre>     | n/a     |   yes    |
| <a name="input_trail_name"></a> [trail_name](#input_trail_name)                                                          | The name of the CloudTrail trail.                                                                                                 | `string`                                                                                          | n/a     |   yes    |
| <a name="input_trail_tags"></a> [trail_tags](#input_trail_tags)                                                          | Tags for the CloudTrail trail.                                                                                                    | `map(string)`                                                                                     | `null`  |    no    |

### Outputs

| Name                                                                                | Description                           |
| ----------------------------------------------------------------------------------- | ------------------------------------- |
| <a name="output_CloudTrail_Trail"></a> [CloudTrail_Trail](#output_CloudTrail_Trail) | The CloudTrail trail resource object. |

---

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center" style="margin-top:30px;">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [Trevor@Nerdware.cloud](mailto:trevor@nerdware.cloud)

  <a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
    <img src="../.github/assets/YouTube\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/meet-trevor-anderson/">
    <img src="../.github/assets/LinkedIn\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://twitter.com/TeeRevTweets">
    <img src="../.github/assets/Twitter\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="mailto:trevor@nerdware.cloud">
    <img src="../.github/assets/email\_icon\_circle.svg" height="40" />
  </a>
  <br><br>

  <a href="https://daremightythings.co/">
    <strong><i>Dare Mighty Things.</i></strong>
  </a>

</div>
<!-- prettier-ignore-end -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
