<h1>Fixit Cloud ☁️ MODULE: AWS CloudWatch</h2>

Terraform module for defining AWS CloudWatch Logs resources, including metrics and alarms.

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

- [CloudWatch Metrics: AWS Services](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)
- [CloudWatch Log Metric Filter Pattern Syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html)

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
| [aws_cloudwatch_log_group.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_logs_log_groups"></a> [cloudwatch\_logs\_log\_groups](#input\_cloudwatch\_logs\_log\_groups) | Map of CloudWatch Logs log group names to config objects. If not<br>provided, "retention\_in\_days" defaults to 400. | <pre>map(<br>    # map keys: log group names<br>    object({<br>      retention_in_days = optional(number)<br>      kms_key_arn       = optional(string)<br>      tags              = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_cloudwatch_metrics"></a> [cloudwatch\_metrics](#input\_cloudwatch\_metrics) | Map of CloudWatch metric names to config objects. For both "alarm" and<br>"log\_metric\_filter", if "name" is not specified, the metric name will<br>be used instead.<br><br>Within "metric\_transformations", if neither "default\_value" nor<br>"dimensions" are provided, "default\_value" will be set to "0". | <pre>map(<br>    # map keys: metric names<br>    object({<br>      namespace = string<br>      log_metric_filter = object({<br>        name           = optional(string)<br>        pattern        = string<br>        log_group_name = string<br>        metric_transformation = object({<br>          name          = string<br>          value         = string<br>          default_value = optional(string)<br>          dimensions    = optional(string)<br>          unit          = optional(string)<br>        })<br>      })<br>      alarm = object({<br>        name        = optional(string)<br>        description = optional(string)<br>        tags        = optional(map(string))<br>      })<br>    })<br>  )</pre> | n/a | yes |

### Outputs

No outputs.

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
