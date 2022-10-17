<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS EventBridge</h2>

Terraform module for defining AWS EventBridge resources (formerly "CloudWatch Events").

</div>

<h2>Table of Contents</h2>

- [EventBridge IAM](#eventbridge-iam)
  - [EventBridge IAM: Identity-Based Policies](#eventbridge-iam-identity-based-policies)
    - [EventBridge API Destinations](#eventbridge-api-destinations)
    - [Kinesis Streams](#kinesis-streams)
    - [Systems Manager Run Commands](#systems-manager-run-commands)
    - [Step Functions State Machines](#step-functions-state-machines)
    - [ECS Tasks](#ecs-tasks)
  - [EventBridge IAM: Resource-Based Policies](#eventbridge-iam-resource-based-policies)
    - [API Gateway Endpoints](#api-gateway-endpoints)
    - [CloudWatch Logs Resources](#cloudwatch-logs-resources)
    - [Lambda Functions](#lambda-functions)
    - [SNS Topics](#sns-topics)
    - [SQS Queues](#sqs-queues)
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

## EventBridge IAM

EventBridge, like many AWS services, uses a combination of [identity](#eventbridge-iam-identity-based-policies) and [resource-based](#eventbridge-iam-resource-based-policies) IAM policies. The type of policies required and the permissions they must provide vary depending on the nature of the event target. The table below lists EventBridge targets and the types of policies they require; each target links to a corresponding policy example below containing the minimum necessary permissions for each target type. Policy values which need to be replaced upon usage are wrapped in square brackets and capitalized (e.g., the region and account ID values in an EC2 ARN are provided as `arn:aws:ec2:[REGION]:[ACCOUNT_ID]:instance/*`.)

> Cross-account and/or cross-region EventBridge configurations require [additional permissions structures](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus-perms.html).

| Target Type                                                     | IAM Policy Type       |
| :-------------------------------------------------------------- | :-------------------- |
| [EventBridge API destinations](#eventbridge-api-destinations)   | Identity-based policy |
| [Kinesis streams](#kinesis-streams)                             | Identity-based policy |
| [Systems Manager run commands](#systems-manager-run-commands)   | Identity-based policy |
| [Step Functions state machines](#step-functions-state-machines) | Identity-based policy |
| [ECS tasks](#ecs-tasks)                                         | Identity-based policy |
| [API Gateway endpoints](#api-gateway-endpoints)                 | Resource-based policy |
| [CloudWatch Logs resources](#cloudwatch-logs-resources)         | Resource-based policy |
| [Lambda functions](#lambda-functions)                           | Resource-based policy |
| [SNS topics](#sns-topics)                                       | Resource-based policy |
| [SQS queues](#sqs-queues)                                       | Resource-based policy |

### EventBridge IAM: Identity-Based Policies

For more info, see [EventBridge identity-based policies documentation](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-identity-based.html).

<div style="margin-left: 35px;">

#### EventBridge API Destinations

If the target is an API destination, the role that you specify must include the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["events:InvokeApiDestination"],
      "Resource": ["arn:aws:events:::api-destination/*"]
    }
  ]
}
```

#### Kinesis Streams

If the target is a Kinesis stream, the role used to send event data to that target must include the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["kinesis:PutRecord"],
      "Resource": "*"
    }
  ]
}
```

#### Systems Manager Run Commands

If the target is Systems Manager run command, and you specify one or more InstanceIds values for the command, the role that you specify must include the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ssm:SendCommand",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:[REGION]:[ACCOUNT_ID]:instance/[INSTANCE_IDs]",
        "arn:aws:ssm:[REGION]:*:document/[DOCUMENT_NAME]"
      ]
    }
  ]
}
```

If the target is Systems Manager run command, and you specify one or more tags for the command, the role that you specify must include the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ssm:SendCommand",
      "Effect": "Allow",
      "Resource": ["arn:aws:ec2:[REGION]:[ACCOUNT_ID]:instance/*"],
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/*": ["[[tagValues]]"]
        }
      }
    },
    {
      "Action": "ssm:SendCommand",
      "Effect": "Allow",
      "Resource": ["arn:aws:ssm:[REGION]:*:document/[DOCUMENT_NAME]"]
    }
  ]
}
```

#### Step Functions State Machines

If the target is an AWS Step Functions state machine, the role that you specify must include the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["states:StartExecution"],
      "Resource": ["arn:aws:states:*:*:stateMachine:*"]
    }
  ]
}
```

#### ECS Tasks

If the target is an Amazon ECS task, the role that you specify must include the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ecs:RunTask"],
      "Resource": [
        "arn:aws:ecs:*:[ACCOUNT_ID]:task-definition/[TASK_DEFINITION_NAME]"
      ],
      "Condition": {
        "ArnLike": {
          "ecs:cluster": "arn:aws:ecs:*:[ACCOUNT_ID]:cluster/[CLUSTER_NAME]"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": ["*"],
      "Condition": {
        "StringLike": {
          "iam:PassedToService": "ecs-tasks.amazonaws.com"
        }
      }
    }
  ]
}
```

</div>

### EventBridge IAM: Resource-Based Policies

For more info, see [EventBridge resource-based policies documentation](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-resource-based.html).

<div style="margin-left: 35px;">

#### API Gateway Endpoints

To invoke your Amazon API Gateway endpoint by using a EventBridge rule, add the following permission to the policy of your API Gateway endpoint:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "execute-api:Invoke",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:events:[REGION]:[ACCOUNT_ID]:rule/[RULE_NAME]"
        }
      },
      "Resource": ["execute-api:/stage/GET/api"]
    }
  ]
}
```

#### CloudWatch Logs Resources

When CloudWatch Logs is the target of a rule, EventBridge creates log streams, and CloudWatch Logs stores the text from the events as log entries. To allow EventBridge to create the log stream and log the events, CloudWatch Logs must include a resource-based policy that enables EventBridge to write to CloudWatch Logs.

If you use the AWS Management Console to add CloudWatch Logs as the target of a rule, the resource-based policy is created automatically. If you use the AWS CLI to add the target, and the policy doesn't already exist, you must create it.

The following example allows EventBridge to write to all log groups that have names that start with /aws/events/. If you use a different naming policy for these types of logs, adjust the example accordingly.

```json
{
  "Statement": [
    {
      "Action": ["logs:CreateLogStream", "logs:PutLogEvents"],
      "Effect": "Allow",
      "Principal": {
        "Service": ["events.amazonaws.com", "delivery.logs.amazonaws.com"]
      },
      "Resource": "arn:aws:logs:[REGION]:[ACCOUNT_ID]:log-group:/aws/events/*:*",
      "Sid": "TrustEventsToStoreLogEvent"
    }
  ],
  "Version": "2012-10-17"
}
```

#### Lambda Functions

To invoke your AWS Lambda function by using a EventBridge rule, add the following permission to the policy of your Lambda function:

```json
{
  "Effect": "Allow",
  "Action": "lambda:InvokeFunction",
  "Resource": "arn:aws:lambda:[REGION]:[ACCOUNT_ID]:function:[FUNCTION_NAME]",
  "Principal": {
    "Service": "events.amazonaws.com"
  },
  "Condition": {
    "ArnLike": {
      "AWS:SourceArn": "arn:aws:events:[REGION]:[ACCOUNT_ID]:rule/[RULE_NAME]"
    }
  },
  "Sid": "InvokeLambdaFunction"
}
```

#### SNS Topics

```json
{
  "Sid": "PublishEventsToMyTopic",
  "Effect": "Allow",
  "Principal": {
    "Service": "events.amazonaws.com"
  },
  "Action": "sns:Publish",
  "Resource": "arn:aws:sns:[REGION]:[ACCOUNT_ID]:[TOPIC_NAME]"
}
```

#### SQS Queues

```json
{
  "Sid": "EventsToMyQueue",
  "Effect": "Allow",
  "Principal": {
    "Service": "events.amazonaws.com"
  },
  "Action": "sqs:SendMessage",
  "Resource": "arn:aws:sqs:[REGION]:[ACCOUNT_ID]:[QUEUE_NAME]",
  "Condition": {
    "ArnEquals": {
      "aws:SourceArn": "arn:aws:events:[REGION]:[ACCOUNT_ID]:rule/[RULE_NAME]"
    }
  }
}
```

</div>

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
| [aws_cloudwatch_event_bus.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_bus_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus_policy) | resource |
| [aws_cloudwatch_event_rule.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy_document.Event_Bus_Policies_Map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_event_buses"></a> [event\_buses](#input\_event\_buses) | (Optional) Map of EventBridge Event Bus names to config objects. To configure an<br>event bus policy, you can either provide a JSON-encoded string to "event\_bus\_policy\_json",<br>or a list of policy statements to "event\_bus\_policy\_statements".<br>Within policy statements, to include the ARNs of event resources which are created within<br>the same module call in your "resources" list(s), provide the event bus/target/rule NAME in<br>"resources" and the name will be replaced by the ARN in the final policy document. Note that<br>using this feature requires unique resource names; i.e., having an event BUS and event RULE<br>with the same name would result in an error. | <pre>map(<br>    # map keys: Event Bus names<br>    object({<br>      event_source_name     = optional(string)<br>      tags                  = optional(map(string))<br>      event_bus_policy_json = optional(string)<br>      event_bus_policy_statements = optional(list(object({<br>        sid    = optional(string)<br>        effect = string<br>        principals = optional(map(<br>          # map keys: "AWS", "Service", and/or "Federated"<br>          list(string)<br>        ))<br>        actions   = list(string)<br>        resources = optional(list(string))<br>        conditions = optional(map(<br>          # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")<br>          object({<br>            key    = string<br>            values = list(string)<br>          })<br>        ))<br>      })))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_event_rules"></a> [event\_rules](#input\_event\_rules) | (Optional) Map of EventBridge rule names to config objects. A "role\_arn"<br>must be provided for rules which invoke targets that are API destinations,<br>Kinesis streams, Systems Manager Run Commands, Step Functions state machines,<br>or ECS tasks. | <pre>map(<br>    # map keys: event rule names<br>    object({<br>      enabled             = optional(bool)<br>      description         = optional(string)<br>      role_arn            = optional(string)<br>      schedule_expression = optional(string)<br>      event_pattern       = optional(string)<br>      event_bus_name      = optional(string)<br>      tags                = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_event_targets"></a> [event\_targets](#input\_event\_targets) | (Optional) Map of EventBridge rule target assignment IDs to config objects.<br>Target assignment IDs can be any valid name/ID string. A "role\_arn" must be<br>provided if the target is an ECS task, EC2 instance, Kinesis data stream,<br>Step Functions state machine, or Event Bus in a different account or region.<br>Target event input can be configured with either "input", "input\_path", or<br>"input\_transformer". Note that each rule can have at most 5 event targets. | <pre>map(<br>    # map keys: event target assignment IDs<br>    object({<br>      rule_name         = string<br>      target_arn        = string<br>      event_bus_name    = optional(string)<br>      role_arn          = optional(string)<br>      retry_policy      = optional(string)<br>      input             = optional(string)<br>      input_path        = optional(string)<br>      input_transformer = optional(string)<br>    })<br>  )</pre> | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Event_Bus_Policies"></a> [Event\_Bus\_Policies](#output\_Event\_Bus\_Policies) | Map of EventBridge Event Bus Policy resource objects. |
| <a name="output_Event_Buses"></a> [Event\_Buses](#output\_Event\_Buses) | Map of EventBridge Event Bus resource objects. |
| <a name="output_Event_Rules"></a> [Event\_Rules](#output\_Event\_Rules) | Map of EventBridge Event Rule resource objects. |
| <a name="output_Event_Targets"></a> [Event\_Targets](#output\_Event\_Targets) | Map of EventBridge Event Target resource objects. |

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
