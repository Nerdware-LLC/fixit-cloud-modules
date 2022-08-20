<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS EventBridge</h2>

Terraform module for defining AWS EventBridge resources.

</div>

> AWS EventBridge was formerly called "CloudWatch Events".

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

- [AWS Docs: EventBridge Events](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)

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

| Name                                                                                                                                                 | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_event_bus.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus)                     | resource    |
| [aws_cloudwatch_event_bus_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus_policy)       | resource    |
| [aws_cloudwatch_event_rule.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                   | resource    |
| [aws_cloudwatch_event_target.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)               | resource    |
| [aws_iam_policy_document.Event_Bus_Policies_Map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name                                                                     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Default | Required |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- | :------: |
| <a name="input_event_buses"></a> [event_buses](#input_event_buses)       | (Optional) Map of EventBridge Event Bus names to config objects. To configure an<br>event bus policy, you can either provide a JSON-encoded string to "event_bus_policy_json",<br>or a list of policy statements to "event_bus_policy_statements".<br>Within policy statements, to include the ARNs of event resources which are created within<br>the same module call in your "resources" list(s), provide the event bus/target/rule NAME in<br>"resources" and the name will be replaced by the ARN in the final policy document. Note that<br>using this feature requires unique resource names; i.e., having an event BUS and event RULE<br>with the same name would result in an error. | <pre>map(<br> # map keys: Event Bus names<br> object({<br> event_source_name = optional(string)<br> tags = optional(map(string))<br> event_bus_policy_json = optional(string)<br> event_bus_policy_statements = optional(list(object({<br> sid = optional(string)<br> effect = string<br> principals = optional(map(<br> # map keys: "AWS", "Service", and/or "Federated"<br> list(string)<br> ))<br> actions = list(string)<br> resources = optional(list(string))<br> conditions = optional(map(<br> # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")<br> object({<br> key = string<br> values = list(string)<br> })<br> ))<br> })))<br> })<br> )</pre> | n/a     |   yes    |
| <a name="input_event_rules"></a> [event_rules](#input_event_rules)       | (Optional) Map of EventBridge rule names to config objects.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | <pre>map(<br> # map keys: event rule names<br> object({<br> enabled = optional(bool)<br> description = optional(string)<br> role_arn = optional(string)<br> schedule_expression = optional(string)<br> event_pattern = optional(string)<br> event_bus_name = optional(string)<br> tags = optional(map(string))<br> })<br> )</pre>                                                                                                                                                                                                                                                                                                                                              | `{}`    |    no    |
| <a name="input_event_targets"></a> [event_targets](#input_event_targets) | (Optional) Map of EventBridge event target IDs to config objects. Target event<br>input can be configured with either "input", "input_path", or "input_transformer".                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | <pre>map(<br> # map keys: event target IDs<br> object({<br> target_arn = string<br> rule_name = string<br> event_bus_name = optional(string)<br> input = optional(string)<br> input_path = optional(string)<br> input_transformer = optional(string)<br> role_arn = optional(string)<br> retry_policy = optional(string)<br> })<br> )</pre>                                                                                                                                                                                                                                                                                                                                    | n/a     |   yes    |

### Outputs

| Name                                                                                      | Description                                           |
| ----------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| <a name="output_Event_Bus_Policies"></a> [Event_Bus_Policies](#output_Event_Bus_Policies) | Map of EventBridge Event Bus Policy resource objects. |
| <a name="output_Event_Buses"></a> [Event_Buses](#output_Event_Buses)                      | Map of EventBridge Event Bus resource objects.        |
| <a name="output_Event_Rules"></a> [Event_Rules](#output_Event_Rules)                      | Map of EventBridge Event Rule resource objects.       |
| <a name="output_Event_Targets"></a> [Event_Targets](#output_Event_Targets)                | Map of EventBridge Event Target resource objects.     |

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
