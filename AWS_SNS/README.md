<h1>Fixit Cloud ☁️ MODULE: AWS SNS</h2>

Terraform module for defining AWS SNS resources.

<h2>Table of Contents</h2>

- [SNS Topic Subscription Protocols](#sns-topic-subscription-protocols)
  - [Partially-Supported Protocols](#partially-supported-protocols)
- [Useful Links:](#useful-links)
- [⚙️ Module Usage](#️-module-usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)

## SNS Topic Subscription Protocols

The table below provides pertinent information about SNS topic subscription protocols. The "Protocol Enum" column lists valid values for the `"protocol"` property in `var.sns_topic_subscriptions` config objects. Each subscription's `"protocol"` value determines the type of value that must be provided to the `"endpoint"` property for each respective subscription config object. [Please note the limitations of the four protocols which can only be partially supported by Terraform](#partially-supported-protocols).

| Protocol Enum | Endpoint Type                                          | Data Delivery                        | Fully-Supported (see below) | Notes                                                   |
| :------------ | :----------------------------------------------------- | :----------------------------------- | :-------------------------: | :------------------------------------------------------ |
| sqs           | ARN of an Amazon SQS queue                             | JSON-encoded messages                |             ✅              |                                                         |
| sms           | Phone number of an SMS-enabled device                  | Text messages via SMS                |             ✅              |                                                         |
| lambda        | ARN of an AWS Lambda function                          | JSON-encoded messages                |             ✅              |                                                         |
| firehose      | ARN of an Amazon Kinesis Data Firehose delivery stream | JSON-encoded messages                |             ✅              | Requires IAM role to publish to Kinesis delivery stream |
| application   | ARN of a mobile app and device                         | JSON-encoded messages                |             ✅              |                                                         |
| email         | Email address                                          | SMTP                                 |             ❌              |                                                         |
| email-json    | Email address                                          | JSON-encoded messages via SMTP       |             ❌              |                                                         |
| http          | URL beginning with "http://"                           | JSON-encoded messages via HTTP POST  |             ❌              |                                                         |
| https         | URL beginning with "https://"                          | JSON-encoded messages via HTTPS POST |             ❌              |                                                         |

### Partially-Supported Protocols

Please note that subscriptions which use the "email", "email-json", "http", or "https" protocols CAN NOT be deleted/unsubscribed by Terraform if the subscription is not yet confirmed at the time when a destroy operation is initiated. Attempting to destroy an unconfirmed subscription which uses one of these protocols WILL remove the aws_sns_topic_subscription from TF's state but WILL NOT remove the subscription from AWS. The "pending_confirmation" bool attribute provides confirmation status.

## Useful Links:

- [AWS Docs: SNS Delivery Policies](https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html)
- [Terraform Registry: aws_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)
- [Terraform Registry: aws_sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#attributes-reference)

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
| [aws_sns_topic.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_iam_policy_document.SNS_Topic_Policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sns_topic_subscriptions"></a> [sns\_topic\_subscriptions](#input\_sns\_topic\_subscriptions) | List of SNS Topic Subscription config objects. "endpoint" describes<br>where to send topic data, the format of which is determined by the<br>"protocol" a subscription uses. "protocol" must be either "sqs", "sms",<br>"lambda", "firehose", "application", "email", "email-json", "http", or<br>"https". Please refer to the [SNS Topic Subscription Protocols](#sns-topic-subscription-protocols)<br>section in the README for details regarding each type of "protocol".<br>"topic" can either be a topic "name", if the Topic is being managed<br>within the same module call, or a topic ARN if the Topic is managed<br>externally. For more info, please refer to the links provided in the<br>[Useful Links](#useful-links) section of the README. | <pre>list(<br>    object({<br>      endpoint                        = string<br>      protocol                        = string<br>      topic                           = string<br>      kinesis_delivery_iam_role_arn   = optional(string)<br>      confirmation_timeout_in_minutes = optional(number)<br>      delivery_policy_json            = optional(string)<br>      filter_policy_json              = optional(string)<br>      redrive_policy_json             = optional(string)<br>      endpoint_auto_confirms          = optional(bool) # Default: false<br>      enable_raw_message_delivery     = optional(bool) # Default: false<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_sns_topics"></a> [sns\_topics](#input\_sns\_topics) | Map of SNS Topic names to config objects. "policy\_statements" must map<br>SNS Topic Policy statement SIDs to statement config objects. Common<br>policy\_statements inputs are available in the [Usage Examples](#usage-examples)<br>section of the README.<br><br>Use "kms\_master\_key\_id" to enable topic SSE. "is\_fifo\_topic" and<br>"enable\_content\_based\_deduplication" both default to "false".<br><br>Use "message\_delivery\_reporting" to configure Topics to send message delivery<br>success/failure info to CloudWatch Logs for the five supported types of SNS<br>endpoints: HTTP, SQS, Kinesis Firehose, Lambda, and Application. The IAM<br>service roles specified in the "\_role\_arn" properties must provide the SNS<br>service principal ("sns.amazonaws.com") with the permission necessary to write<br>the logs to the desired CloudWatch Logs log group. A custom sampling rate can<br>also be specified as an integer representing the percentage of successful<br>messages for which CloudWatch Logs will be provided; this defaults to "100"<br>if not provided. | <pre>map(<br>    # map keys: SNS Topic names<br>    object({<br>      policy_statements = map(<br>        # map keys: policy statement SIDs<br>        object({<br>          effect = string<br>          principals = object({<br>            type        = string<br>            identifiers = list(string)<br>          })<br>          actions = list(string)<br>          conditions = optional(map(<br>            # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")<br>            object({<br>              key    = string<br>              values = list(string)<br>            })<br>          ))<br>        })<br>      )<br><br>      delivery_policy_json               = optional(string)<br>      display_name                       = optional(string)<br>      kms_master_key_id                  = optional(string)<br>      is_fifo_topic                      = optional(bool) # Default: false<br>      enable_content_based_deduplication = optional(bool) # Default: false<br>      tags                               = optional(map(string))<br><br>      message_delivery_reporting = optional(object({<br>        application = optional(object({<br>          success_role_arn = optional(string)<br>          failure_role_arn = optional(string)<br>          sample_rate      = optional(number)<br>        }))<br>        http = optional(object({<br>          success_role_arn = optional(string)<br>          failure_role_arn = optional(string)<br>          sample_rate      = optional(number)<br>        }))<br>        sqs = optional(object({<br>          success_role_arn = optional(string)<br>          failure_role_arn = optional(string)<br>          sample_rate      = optional(number)<br>        }))<br>        kinesis_firehose = optional(object({<br>          success_role_arn = optional(string)<br>          failure_role_arn = optional(string)<br>          sample_rate      = optional(number)<br>        }))<br>        lambda = optional(object({<br>          success_role_arn = optional(string)<br>          failure_role_arn = optional(string)<br>          sample_rate      = optional(number)<br>        }))<br>      }))<br>    })<br>  )</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_SNS_Topic_Policies"></a> [SNS\_Topic\_Policies](#output\_SNS\_Topic\_Policies) | Map of SNS Topic Policy resource objects. |
| <a name="output_SNS_Topic_Subscriptions"></a> [SNS\_Topic\_Subscriptions](#output\_SNS\_Topic\_Subscriptions) | Map of SNS Topic Subscription resource objects. |
| <a name="output_SNS_Topics"></a> [SNS\_Topics](#output\_SNS\_Topics) | Map of SNS Topic resource objects. |

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
