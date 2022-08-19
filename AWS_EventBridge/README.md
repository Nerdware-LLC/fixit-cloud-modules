<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS EventBridge</h2>

Terraform module for defining AWS EventBridge resources.

</div>

> AWS EventBridge was formerly called "CloudWatch Events".

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

## Useful Links

- [AWS Docs: EventBridge Events](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)

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
| [aws_cloudwatch_event_bus.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_bus_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus_policy) | resource |
| [aws_cloudwatch_event_rule.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy_document.Event_Bus_Policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_event_buses"></a> [event\_buses](#input\_event\_buses) | (Optional) Map of EventBridge Event Bus names to config objects.<br>// TODO write more here | <pre>map(<br>    # map keys: Event Bus names<br>    object({<br>      event_source_name     = optional(string)<br>      tags                  = optional(map(string))<br>      event_bus_policy_json = optional(string)<br>      event_bus_policy_statements = optional(list(object({<br>        sid    = optional(string)<br>        effect = string<br>        principals = optional(map(<br>          # map keys: "AWS", "Service", and/or "Federated"<br>          list(string)<br>        ))<br>        actions   = list(string)<br>        resources = optional(list(string))<br>        conditions = optional(map(<br>          # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")<br>          object({<br>            key    = string<br>            values = list(string)<br>          })<br>        ))<br>      })))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_event_rules"></a> [event\_rules](#input\_event\_rules) | (Optional) Map of EventBridge rule names to config objects. | <pre>map(<br>    # map keys: event rule names<br>    object({<br>      is_enabled          = optional(bool)<br>      description         = optional(string)<br>      role_arn            = optional(string)<br>      schedule_expression = optional(string)<br>      event_pattern       = optional(string)<br>      event_bus_name      = optional(string)<br>      tags                = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_event_targets"></a> [event\_targets](#input\_event\_targets) | n/a | <pre>map(<br>    # map keys: event target IDs<br>    object({<br>      target_arn     = string<br>      rule_name      = string<br>      event_bus_name = optional(string)<br>      input          = optional(string)<br>      input_path     = optional(string)<br>      role_arn       = optional(string)<br>      retry_policy   = optional(string)<br>      # TODO finish this resource<br>    })<br>  )</pre> | n/a | yes |

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
