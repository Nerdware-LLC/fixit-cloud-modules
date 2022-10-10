<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS DynamoDB</h1>

Terraform module for defining a performant DynamoDB table with **point-in-time recovery** enabled by default. In accordance with [security and performance best practices](#relevant-security-standards--controls), all DynamoDB tables with "Provisioned" read/write capacity are provided with AutoScaling resources.

</div>

<h2>Table of Contents</h2>

- [DynamoDB Server-Side Encryption](#dynamodb-server-side-encryption)
- [Restoring a DynamoDB Table Using Point-In-Time Recovery](#restoring-a-dynamodb-table-using-point-in-time-recovery)
  - [Recovery Time](#recovery-time)
- [DynamoDB Security Standards & Controls](#dynamodb-security-standards--controls)
- [Useful Links](#useful-links)
- [Usage Examples](#usage-examples)
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

<!-- TODO Finish this list: Top 10 NoSQL Database Design Principles

## Top 10 NoSQL Database Design Principles

In the interest of preventing this README from becoming a bloated, unwieldy compendium of everything one should know/do when planning the design of a NoSQL database, I've curated the following list of just 10 design principles, the goal of which is to offer actionable guidance which hopefully will aid your quest in building a database that's performant, cost-efficient, and free of throttling pitfalls.

1. **Aim to build your NoSQL database using as few tables as possible - for many applications, a single table is all you need.**
   This is typically one of the most challenging conceptual changes for folks like myself who come from an RDBMS background. From AWS docs:
   > You should maintain as few tables as possible in a DynamoDB application. Having fewer tables keeps things more scalable, requires less permissions management, and reduces overhead for your DynamoDB application. It can also help keep backup costs lower overall.
2.

-->

## DynamoDB Server-Side Encryption

All DynamoDB tables are encrypted using either an AWS-owned key, AWS-managed key, or CMK (customer-managed key). By default, all tables are encrypted using an AWS-owned key in the DynamoDB service account. The AWS-owned key is free of charge and its use does not count against AWS KMS resource or request quotas. CMKs and AWS-managed keys incur a charge for each API call and AWS KMS quotas apply to these KMS keys.

**Use the AWS managed key if you need any of the following features:**

- You can view the KMS key and view its key policy. (You cannot change the key policy.)
- You can audit the encryption and decryption of your DynamoDB table by examining the DynamoDB API calls to AWS KMS in AWS CloudTrail logs.

**Use a CMK to get the following features:**

- You create and manage the KMS key, including setting the key policies, IAM policies, and grants to control access to the KMS key. You can enable and disable the KMS key, enable and disable automatic key rotation, and delete the KMS key when it is no longer in use.
- You can use a customer-managed key with imported key material or a customer-managed key in a custom key store that you own and manage.
- You can audit the encryption and decryption of your DynamoDB table by examining the DynamoDB API calls to AWS KMS in AWS CloudTrail logs.

## Restoring a DynamoDB Table Using Point-In-Time Recovery

When you restore a DynamoDB table using point-in-time recovery, the settings listed below can be manually overridden for the restore-table, and if not provided will instead be copied over from _current settings of the source table at the time of the restore_.

- Global secondary indexes (GSIs)
- Local secondary indexes (LSIs)
- Billing mode
- Provisioned read and write capacity
- Encryption settings
- Region

To better illustrate the source of these settings, here's an example from [AWS docs](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery_Howitworks.html#howitworks_restoring):

> For example, suppose that a table's provisioned throughput was recently lowered to 50 read capacity units and 50 write capacity units. You then restore the table's state to three weeks ago, at which time its provisioned throughput was set to 100 read capacity units and 100 write capacity units. In this case, DynamoDB restores your table data to that point in time, but uses the current provisioned throughput (50 read capacity units and 50 write capacity units).

In contrast, the settings listed below _must be provided for the restore table_, as they do not carry over from the source table:

- Auto scaling policies
- AWS Identity and Access Management (IAM) policies
- Amazon CloudWatch metrics and alarms
- Tags
- Stream settings
- Time to Live (TTL) settings
- Point-in-time recovery settings

### Recovery Time

Service metrics show that 95 percent of table restores complete in less than one hour. However, restore times are directly related to a table's configurations, such as the size of the table, the number of underlying partitions, and other related variables. A best practice when planning for disaster recovery is to regularly document average restore completion times and establish how these times affect your overall **Recovery Time Objective**.

## DynamoDB Security Standards & Controls

| Source                                   | Control                                                                                    | Pass/Fail | Notes                            |
| :--------------------------------------- | :----------------------------------------------------------------------------------------- | :-------: | :------------------------------- |
| AWS Foundational Security Best Practices | [[DynamoDB.1]][dynamodb-1] DynamoDB tables should automatically scale capacity with demand |    ✅     |                                  |
| AWS Foundational Security Best Practices | [[DynamoDB.2]][dynamodb-2] DynamoDB tables should have point-in-time recovery enabled      |    ✅     |                                  |
| AWS Foundational Security Best Practices | [[DynamoDB.3]][dynamodb-3] DynamoDB Accelerator (DAX) clusters should be encrypted at rest |    N/A    | DAX resources not yet supported. |

## Useful Links

- **AWS Documentation:**
  - [NoSQL Database Design Best Practices](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
  - [How Amazon DynamoDB uses AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/services-dynamodb.html)

## Usage Examples

- Terragrunt: [view Terragrunt usage exmaple](examples/terragrunt.hcl)
- Terraform: &nbsp;[view vanilla Terraform usage exmaple](examples/terraform.tf)

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
| [aws_appautoscaling_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_dynamodb_kinesis_streaming_destination.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_kinesis_streaming_destination) | resource |
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table_item.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table_item) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | List of DynamoDB table attribute config objects. Attribute "type" values<br>must be either "S", "N", or "B" (for String, Number, or Binary). All table<br>and index keys must be defined here, along with any attributes included in<br>index "non\_key\_attributes" lists. | <pre>list(object({<br>    name = string<br>    type = string # "S", "N", or "B"<br>  }))</pre> | n/a | yes |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | (Optional) The DynamoDB table's billing mode. This can either be "PROVISIONED"<br>or "PAY\_PER\_REQUEST"; if no value is provided, this defaults to "PROVISIONED".<br>A table with "PROVISIONED" billing must define a "capacity" config; see the<br>var.capacity description for more information. | `string` | `"PROVISIONED"` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | (Optional if var.billing\_mode is PAY\_PER\_REQUEST) Autoscaling configs for a<br>DynamoDB table with "PROVISIONED" throughput. "var.capacity" must specify "min",<br>"max", and "target\_percentage" values for both "read" and "write".<br>"target\_percentage" reflects the desired utilization of provisioned capacity. | <pre>object({<br>    read = object({<br>      max               = number<br>      target_percentage = number<br>      min               = number<br>    })<br>    write = object({<br>      max               = number<br>      target_percentage = number<br>      min               = number<br>    })<br>  })</pre> | `null` | no |
| <a name="input_dynamodb_table_items"></a> [dynamodb\_table\_items](#input\_dynamodb\_table\_items) | (Optional) A list of JSON-encoded DynamoDB table items. | `list(string)` | `null` | no |
| <a name="input_enable_point_in_time_recovery"></a> [enable\_point\_in\_time\_recovery](#input\_enable\_point\_in\_time\_recovery) | (Optional) Point in time recovery is enabled by default; set to false to<br>override this behavior. | `bool` | `true` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | (Optional) Map of GSI names to config objects for each respective GSI. Note<br>that the maximum number of GSIs a DynamoDB table can have is 20. Each GSI must<br>have a "hash\_key", and can optionally define a "range\_key", both of which must<br>be included in var.attributes. "projection\_type" defines which table attributes<br>to include (or "project") in the index - it must be either "KEYS\_ONLY", "ALL",<br>or "INCLUDE". "KEYS\_ONLY" will result in just the table's hash\_key and range\_key<br>being included in the index, "ALL" will result in every table attribute being<br>included in the index, and "INCLUDE" will result in the table's hash\_key,<br>range\_key, and attributes defined in the "non\_key\_attributes" list being included<br>in the index. Note that any attributes listed in "non\_key\_attributes" must be<br>defined in var.attributes. If the base table uses "PROVISIONED" throughput, all<br>GSI configs must specify autoscaling configs via the "capacity" property with<br>"min", "max", and "target\_percentage" values for both "read" and "write".<br>"target\_percentage" reflects the desired utilization of provisioned capacity. | <pre>map(<br>    # map keys: GSI names<br>    object({<br>      hash_key           = string<br>      range_key          = optional(string)<br>      projection_type    = string<br>      non_key_attributes = optional(list(string))<br>      capacity = optional(object({<br>        read = object({<br>          max               = number<br>          target_percentage = number<br>          min               = number<br>        })<br>        write = object({<br>          max               = number<br>          target_percentage = number<br>          min               = number<br>        })<br>      }))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The DynamoDB table's hash key (also called a "partition" or "primary" key). | `string` | n/a | yes |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | (Optional) Map of LSI names to config objects for each respective LSI. Note<br>that the maximum number of LSIs a DynamoDB table can have is 5. All LSIs use<br>the table's "hash\_key" as their own, and must define a "range\_key". | <pre>map(<br>    # map keys: LSI names<br>    object({<br>      range_key          = string<br>      projection_type    = string<br>      non_key_attributes = optional(list(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | (Optional) The DynamoDB table's range key (also called a "sort" key). | `string` | `null` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | (Optional) Map for configuring table replicas. For map keys, use AWS region<br>names for regions in which a replica table is desired; map region names to<br>regional replica config objects. A "kms\_key\_arn" must be provided for each<br>replica; this can be an alias given the proper key/alias/permissions configs.<br>If not provided, "enable\_point\_in\_time\_recovery" defaults to true. | <pre>map(<br>    # map keys: AWS regions in which to create table replicas<br>    object({<br>      propagate_tags                = bool<br>      kms_key_arn                   = string<br>      enable_point_in_time_recovery = optional(bool) # default: false, make TRUE DEFAULT<br>    })<br>  )</pre> | `null` | no |
| <a name="input_restore_table_from"></a> [restore\_table\_from](#input\_restore\_table\_from) | (Optional) Use this variable to create a restore-table from a source table<br>with point-in-time recovery enabled. To create a restore-table, you must<br>provide a "source\_table\_name", and a time indicator. The time indicator<br>can be specified using either "use\_latest\_recovery\_point" (default: false),<br>of an explicit date-time string can be supplied to "restore\_date\_time".<br>Please see the README and AWS docs for more info on the necessary inputs. | <pre>object({<br>    source_table_name         = string<br>    use_latest_recovery_point = optional(bool)<br>    restore_date_time         = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_server_side_encryption"></a> [server\_side\_encryption](#input\_server\_side\_encryption) | Config object for the DynamoDB table's server side encryption. "key\_type" must<br>be either "AWS-OWNED", "AWS-MANAGED", or "CMK" (customer-managed key). For "CMK",<br>a "kms\_key\_arn" must be provided (this can also be an alias). For more information,<br>see [DynamoDB Server-Side Encryption](#dynamodb-server-side-encryption). | <pre>object({<br>    key_type    = string<br>    kms_key_arn = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_streams"></a> [streams](#input\_streams) | (Optional) Object for enabling a DynamoDB table stream and/or a Kinesis<br>data stream.<br><br>For a DynamoDB table stream, "dynamodb\_stream\_view\_type" must be one of<br>"KEYS\_ONLY", "NEW\_IMAGE", "OLD\_IMAGE", or "NEW\_AND\_OLD\_IMAGES", which<br>defines what table-modification info is added to each stream window. With<br>"KEYS\_ONLY", only the key attributes of the modified item are added; with<br>"NEW\_IMAGE", the entire item is added as it appears AFTER it was modified;<br>with "OLD\_IMAGE", the entire item is added as it appeared BEFORE it was<br>modified; with "NEW\_AND\_OLD\_IMAGES", both the new and old images are added<br>to each stream window.<br><br>For a Kinesis data stream, this module will associate a DynamoDB table with<br>an existing Kinesis stream using the value provided to "kinesis\_stream\_arn",<br>but does not create any Kinesis resources. | <pre>object({<br>    dynamodb_stream_view_type = optional(string)<br>    kinesis_stream_arn        = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | The name of the DynamoDB table. | `string` | n/a | yes |
| <a name="input_table_storage_class"></a> [table\_storage\_class](#input\_table\_storage\_class) | (Optional) The storage class for the DynamoDB table. Can be either "STANDARD"<br>or "STANDARD\_INFREQUENT\_ACCESS"; default: "STANDARD". | `string` | `"STANDARD"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of tags for the DynamoDB table. | `map(string)` | `null` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | (Optional) Object for configuring TTL; "enabled" defaults to true if not provided. | <pre>object({<br>    enabled        = optional(bool)<br>    attribute_name = string<br>  })</pre> | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_DynamoDB_AutoScaling_Policies"></a> [DynamoDB\_AutoScaling\_Policies](#output\_DynamoDB\_AutoScaling\_Policies) | Map of DynamoDB autoscaling policy resource objects, the keys of which<br>are in the format "(table\|gsi)/NAME/(reads\|writes)". So a table with<br>PROVISIONED capacity named "Foo\_Table" with global indexes "Foo\_GSI\_1"<br>and "Foo\_GSI\_2" would have the following six keys: "table/Foo\_Table/reads",<br>"table/Foo\_Table/writes", "gsi/Foo\_GSI\_1/reads", "gsi/Foo\_GSI\_1/writes",<br>"gsi/Foo\_GSI\_2/reads", and "gsi/Foo\_GSI\_2/writes". |
| <a name="output_DynamoDB_AutoScaling_Targets"></a> [DynamoDB\_AutoScaling\_Targets](#output\_DynamoDB\_AutoScaling\_Targets) | Map of DynamoDB autoscaling policy resource objects, the keys of which<br>are in the format "(table\|gsi)/NAME/(reads\|writes)". So a table with<br>PROVISIONED capacity named "Foo\_Table" with global indexes "Foo\_GSI\_1"<br>and "Foo\_GSI\_2" would have the following six keys: "table/Foo\_Table/reads",<br>"table/Foo\_Table/writes", "gsi/Foo\_GSI\_1/reads", "gsi/Foo\_GSI\_1/writes",<br>"gsi/Foo\_GSI\_2/reads", and "gsi/Foo\_GSI\_2/writes". |
| <a name="output_DynamoDB_Kinesis_Stream_Destination"></a> [DynamoDB\_Kinesis\_Stream\_Destination](#output\_DynamoDB\_Kinesis\_Stream\_Destination) | The DynamoDB Kinesis data stream destination resource object. |
| <a name="output_DynamoDB_Table"></a> [DynamoDB\_Table](#output\_DynamoDB\_Table) | The DynamoDB table resource object. |
| <a name="output_DynamoDB_Table_Items"></a> [DynamoDB\_Table\_Items](#output\_DynamoDB\_Table\_Items) | List of DynamoDB table item resource objects. |

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

[dynamodb-1]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-dynamodb-1
[dynamodb-2]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-dynamodb-2
[dynamodb-3]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-dynamodb-3
