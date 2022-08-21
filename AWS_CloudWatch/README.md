<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS CloudWatch</h2>

Terraform module for defining AWS CloudWatch resources, including log groups, metrics, alarms, and dashboards.

</div>

<h2>Table of Contents</h2>

- [Usage Examples](#usage-examples)
- [CloudWatch Metrics](#cloudwatch-metrics)
- [CloudWatch Alarms](#cloudwatch-alarms)
- [Useful Links](#useful-links)
- [⚙️ Module Usage](#️-module-usage)
  - [Usage Examples](#usage-examples-1)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)

## Usage Examples

- Terragrunt: [view Terragrunt usage exmaple](examples/terragrunt.hcl)
- Terraform: &nbsp;[view vanilla Terraform usage exmaple](examples/terraform.tf)

## CloudWatch Metrics

At its core, CloudWatch is essentially a repository of metrics. An AWS user or service puts metrics into the repository, and statistics based on those metrics can be retrieved for evaluation, or used to create alarms and dashboards.

<div align="center">
  <img src="https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/images/CW-Overview.png" />
</div>

## CloudWatch Alarms

When you create an alarm, you specify three settings to enable CloudWatch to evaluate when to change the alarm state:

1. <u><b>Period</b></u> is the length of time to evaluate the metric or expression to create each individual data point for an alarm. It is expressed in seconds. If you choose one minute as the period, the alarm evaluates the metric once per minute.
2. <u><b>Evaluation Periods</b></u> is the number of the most recent periods, or data points, to evaluate when determining alarm state.
3. <u><b>Datapoints to Alarm</b></u> is the number of data points within the Evaluation Periods that must be breaching to cause the alarm to go to the ALARM state. The breaching data points don't have to be consecutive, but they must all be within the last number of data points equal to Evaluation Period.

In the following figure, the alarm threshold for a metric alarm is set to three units. Both Evaluation Period and Datapoints to Alarm are 3. That is, when all existing data points in the most recent three consecutive periods are above the threshold, the alarm goes to ALARM state. In the figure, this happens in the third through fifth time periods. At period six, the value dips below the threshold, so one of the periods being evaluated is not breaching, and the alarm state changes back to OK. During the ninth time period, the threshold is breached again, but for only one period. Consequently, the alarm state remains OK.

<div align="center">
  <img src="https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/images/alarm_graph.png" />
</div>

## Useful Links

- [CloudWatch Metrics: AWS Services](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)
- [CloudWatch Log Metric Filter Pattern Syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html)
- [AWS Docs: Add a custom widget to a CloudWatch dashboard](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/add_custom_widget_dashboard.html)

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.7 |
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
| [aws_cloudwatch_dashboard.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_log_group.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_dashboards"></a> [cloudwatch\_dashboards](#input\_cloudwatch\_dashboards) | Map of CloudWatch Dashboard names to JSON-encoded dashboard definitions. | `map(string)` | `{}` | no |
| <a name="input_cloudwatch_log_metric_filters"></a> [cloudwatch\_log\_metric\_filters](#input\_cloudwatch\_log\_metric\_filters) | Map of CloudWatch log metric filter names to config objects. Within<br>"metric\_transformation", if neither "default\_value" nor "dimensions"<br>are provided, "default\_value" will be set to "0". "dimensions" can<br>at most contain three key-value pairs. | <pre>map(<br>    # map keys: CloudWatch log metric filter names<br>    object({<br>      log_group_name = string<br>      pattern        = string<br>      metric_transformation = object({<br>        namespace     = string<br>        name          = string<br>        value         = string<br>        default_value = optional(string)<br>        dimensions    = optional(map(string))<br>        unit          = optional(string)<br>      })<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_cloudwatch_logs_log_groups"></a> [cloudwatch\_logs\_log\_groups](#input\_cloudwatch\_logs\_log\_groups) | Map of CloudWatch Logs log group names to config objects. If not<br>provided, "retention\_in\_days" defaults to 400. To configure a log<br>group's logs to never expire, provide 0. | <pre>map(<br>    # map keys: log group names<br>    object({<br>      retention_in_days = optional(number)<br>      kms_key_arn       = optional(string)<br>      tags              = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_cloudwatch_metric_alarms"></a> [cloudwatch\_metric\_alarms](#input\_cloudwatch\_metric\_alarms) | Map of CloudWatch metric alarm names to config objects. "comparison\_operator" can<br>be "GreaterThanOrEqualToThreshold", "GreaterThanThreshold", "LessThanThreshold", or<br>"LessThanOrEqualToThreshold". Additionally, the values "GreaterThanUpperThreshold",<br>"LessThanLowerThreshold", and "LessThanLowerOrGreaterThanUpperThreshold" can be used<br>for alarms based on anomaly detection models.<br><br>For alarms based on a single static metric in the same account which don't involve<br>metric math expressions nor anomaly detection models, use the "static\_metric" property.<br>For alarms which involve any of those features, use "metric\_queries" to map query ID/<br>short names to query config objects (max 20). For "metric\_queries", at least 1 query<br>must have "return\_data" and "use\_query\_to\_set\_threshold" set to true. For both types,<br>"statistic" must be one of "SampleCount", "Average", "Sum", "Minimum", or "Maximum".<br><br>"treat\_missing\_data" must be one of "ignore", "breaching", "notBreaching", or "missing"<br>(default). "actions\_enabled" defaults to "true" if not provided. | <pre>map(<br>    # map keys: CloudWatch metric alarm names<br>    object({<br>      description = optional(string)<br>      tags        = optional(map(string))<br>      static_metric = optional(object({<br>        namespace  = string<br>        name       = string<br>        statistic  = string<br>        period     = number<br>        unit       = optional(string)<br>        dimensions = optional(map(string))<br>        threshold  = string<br>      }))<br>      metric_queries = optional(map(<br>        # map keys: metric query ID/short name<br>        object({<br>          account_id           = optional(string)<br>          expression           = optional(string)<br>          label                = optional(string)<br>          return_data          = optional(bool) # Default: false<br>          use_to_set_threshold = optional(bool) # Default: false<br>          metric = optional(object({<br>            namespace  = string<br>            name       = string<br>            statistic  = string<br>            period     = number<br>            unit       = optional(string)<br>            dimensions = optional(map(string))<br>          }))<br>        })<br>      ))<br>      # Threshold evaluation properties:<br>      comparison_operator = string<br>      evaluation_periods  = string<br>      datapoints_to_alarm = optional(number)<br>      treat_missing_data  = optional(string)<br>      # Action properties:<br>      actions_enabled               = optional(bool) # Default: true<br>      alarm_action_arns             = optional(list(string))<br>      ok_action_arns                = optional(list(string))<br>      insufficient_data_action_arns = optional(list(string))<br>    })<br>  )</pre> | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_CloudWatch_Dashboards"></a> [CloudWatch\_Dashboards](#output\_CloudWatch\_Dashboards) | Map of CloudWatch dashboard resource objects. |
| <a name="output_CloudWatch_Log_Metric_Filters"></a> [CloudWatch\_Log\_Metric\_Filters](#output\_CloudWatch\_Log\_Metric\_Filters) | Map of CloudWatch log metric filter resource objects. |
| <a name="output_CloudWatch_Logs_Log_Groups"></a> [CloudWatch\_Logs\_Log\_Groups](#output\_CloudWatch\_Logs\_Log\_Groups) | Map of CloudWatch Logs log group resource objects. |
| <a name="output_CloudWatch_Metric_Alarm"></a> [CloudWatch\_Metric\_Alarm](#output\_CloudWatch\_Metric\_Alarm) | Map of CloudWatch alarm resource objects. |

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
