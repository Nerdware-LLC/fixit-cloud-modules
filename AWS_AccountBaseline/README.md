<h1> Fixit Cloud ☁️ MODULE: AWS Account Baseline</h1>

Terraform module for providing a hardened baseline security posture for AWS accounts within an AWS Organization.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.11.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.11.0 |
| <a name="provider_aws.ap-northeast-1"></a> [aws.ap-northeast-1](#provider\_aws.ap-northeast-1) | ~> 4.11.0 |
| <a name="provider_aws.ap-northeast-2"></a> [aws.ap-northeast-2](#provider\_aws.ap-northeast-2) | ~> 4.11.0 |
| <a name="provider_aws.ap-northeast-3"></a> [aws.ap-northeast-3](#provider\_aws.ap-northeast-3) | ~> 4.11.0 |
| <a name="provider_aws.ap-south-1"></a> [aws.ap-south-1](#provider\_aws.ap-south-1) | ~> 4.11.0 |
| <a name="provider_aws.ap-southeast-1"></a> [aws.ap-southeast-1](#provider\_aws.ap-southeast-1) | ~> 4.11.0 |
| <a name="provider_aws.ap-southeast-2"></a> [aws.ap-southeast-2](#provider\_aws.ap-southeast-2) | ~> 4.11.0 |
| <a name="provider_aws.ca-central-1"></a> [aws.ca-central-1](#provider\_aws.ca-central-1) | ~> 4.11.0 |
| <a name="provider_aws.eu-central-1"></a> [aws.eu-central-1](#provider\_aws.eu-central-1) | ~> 4.11.0 |
| <a name="provider_aws.eu-north-1"></a> [aws.eu-north-1](#provider\_aws.eu-north-1) | ~> 4.11.0 |
| <a name="provider_aws.eu-west-1"></a> [aws.eu-west-1](#provider\_aws.eu-west-1) | ~> 4.11.0 |
| <a name="provider_aws.eu-west-2"></a> [aws.eu-west-2](#provider\_aws.eu-west-2) | ~> 4.11.0 |
| <a name="provider_aws.eu-west-3"></a> [aws.eu-west-3](#provider\_aws.eu-west-3) | ~> 4.11.0 |
| <a name="provider_aws.sa-east-1"></a> [aws.sa-east-1](#provider\_aws.sa-east-1) | ~> 4.11.0 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider\_aws.us-east-1) | ~> 4.11.0 |
| <a name="provider_aws.us-west-1"></a> [aws.us-west-1](#provider\_aws.us-west-1) | ~> 4.11.0 |
| <a name="provider_aws.us-west-2"></a> [aws.us-west-2](#provider\_aws.us-west-2) | ~> 4.11.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_accessanalyzer_analyzer.Org_AccessAnalyzer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_cloudtrail.Org_CloudTrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.CloudTrail_Events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_config_configuration_aggregator.Org_Config_Aggregator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_aggregator) | resource |
| [aws_config_configuration_recorder.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_configuration_recorder_status.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_delivery_channel.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_delivery_channel.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_policy.CloudWatch-CrossAccountSharing-ListAccounts-Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.CloudWatch-Delivery_Role_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.Org_Config_Role_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.CloudWatch-CrossAccountSharing-ListAccountsRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.CloudWatch-CrossAccountSharingRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.CloudWatch-Delivery_Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.Org_Config_Aggregator_Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.Org_Config_Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.OrganizationAccountAccessRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.CloudWatch-CrossAccountSharing-ListAccounts-Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.CloudWatch-Delivery_Role_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.Org_Config_Aggregator_Role_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.Org_Config_Role_Policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_service_linked_role.AWSServiceRoleForCloudWatchCrossAccount](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_kms_alias.Org_KMS_Key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.Org_KMS_Key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_replica_key.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_s3_account_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [aws_s3_bucket.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_sns_topic.CloudWatch_CIS_Alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.CloudWatch_CIS_Alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | n/a | <pre>map(object({<br>    id                                                = string<br>    email                                             = string<br>    is_log_archive_account                            = optional(bool)<br>    should_enable_cross_account_cloudwatch_sharing    = optional(bool)<br>    should_enable_cross_account_cloudwatch_monitoring = optional(bool)<br>  }))</pre> | n/a | yes |
| <a name="input_administrators"></a> [administrators](#input\_administrators) | List of administrator IAM User names to include in IAM Policy allow-lists.<br>These values are used to harden and restrict usage of admin-related resources. | `list(string)` | n/a | yes |
| <a name="input_cloudwatch_alarms"></a> [cloudwatch\_alarms](#input\_cloudwatch\_alarms) | Config object for CIS-Benchmark CloudWatch Alarms. | <pre>object({<br>    namespace = string<br>    sns_topic = object({<br>      name         = string<br>      display_name = optional(string)<br>      tags         = optional(map(string))<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_config_aggregator"></a> [config\_aggregator](#input\_config\_aggregator) | Config object for the AWS-Config Aggregator resource and its associated IAM<br>service role, the lone policy for which is "AWSConfigRoleForOrganizations",<br>an AWS-managed policy. | <pre>object({<br>    name = string<br>    tags = optional(map(string))<br>    iam_service_role = object({<br>      name        = string<br>      description = optional(string)<br>      tags        = optional(map(string))<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_config_delivery_channel"></a> [config\_delivery\_channel](#input\_config\_delivery\_channel) | Config object for AWS-Config Delivery Channel resource. Allowed values<br>for "snapshot\_frequency" are "One\_Hour", "Three\_Hours", "Six\_Hours",<br>"Twelve\_Hours", or "TwentyFour\_Hours" (default). | <pre>object({<br>    name               = string<br>    snapshot_frequency = optional(string)<br>    s3_bucket = object({<br>      name       = string<br>      key_prefix = optional(string)<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_config_iam_service_role"></a> [config\_iam\_service\_role](#input\_config\_iam\_service\_role) | Config object for IAM Service Role resource which allows the AWS-Config<br>service to write findings/logs to the Organization's log-archive S3,<br>use the Org's KMS key, and publish to the Config SNS Topic. | <pre>object({<br>    name        = string<br>    description = optional(string)<br>    tags        = optional(map(string))<br>    policy = object({<br>      name        = string<br>      description = optional(string)<br>      path        = optional(string)<br>      tags        = optional(map(string))<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_config_recorder_name"></a> [config\_recorder\_name](#input\_config\_recorder\_name) | The name to assign to the AWS-Config Recorder in each region. | `string` | `"Org_Config_Recorder"` | no |
| <a name="input_config_sns_topic"></a> [config\_sns\_topic](#input\_config\_sns\_topic) | Config object for the AWS-Config SNS Topic resource. | <pre>object({<br>    name         = string<br>    display_name = optional(string)<br>    tags         = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_default_vpc_component_tags"></a> [default\_vpc\_component\_tags](#input\_default\_vpc\_component\_tags) | In accordance with best practices, this module locks down the default VPC and all<br>its components to ensure all ingress/egress traffic only uses infrastructure with<br>purposefully-designed rules and configs. Default subnets must be deleted manually<br>- they cannot be removed via Terraform. This variable allows you to customize the<br>tags on these "default" network components; defaults will be used if not provided. | <pre>object({<br>    default_vpc            = optional(map(string))<br>    default_route_table    = optional(map(string))<br>    default_network_acl    = optional(map(string))<br>    default_security_group = optional(map(string))<br>  })</pre> | <pre>{<br>  "default_network_acl": null,<br>  "default_route_table": null,<br>  "default_security_group": null,<br>  "default_vpc": null<br>}</pre> | no |
| <a name="input_org_access_analyzer"></a> [org\_access\_analyzer](#input\_org\_access\_analyzer) | Config object for the Organization's Access Analyzer. | <pre>object({<br>    name = string<br>    tags = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_org_cloudtrail"></a> [org\_cloudtrail](#input\_org\_cloudtrail) | Config object for the Organization CloudTrail in the root account. | <pre>object({<br>    name = string<br>    tags = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_org_cloudtrail_cloudwatch_logs_group"></a> [org\_cloudtrail\_cloudwatch\_logs\_group](#input\_org\_cloudtrail\_cloudwatch\_logs\_group) | Config object for the CloudWatch Logs log group and its associated IAM<br>service role used to receive logs from the Organization's CloudTrail. | <pre>object({<br>    name              = string<br>    retention_in_days = optional(number)<br>    tags              = optional(map(string))<br>    iam_service_role = object({<br>      name = string<br>      tags = optional(map(string))<br>      policy = object({<br>        name        = string<br>        description = optional(string)<br>        path        = optional(string)<br>        tags        = optional(map(string))<br>      })<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_org_kms_key"></a> [org\_kms\_key](#input\_org\_kms\_key) | Config object for the KMS key used to encrypt Log-Archive files, as well as<br>data streams from CloudTrail, CloudWatch, SNS, etc. The "replica\_key\_tags"<br>property will be added to the "tags" field of all replica keys. | <pre>object({<br>    alias_name       = string<br>    description      = optional(string)<br>    key_policy_id    = optional(string)<br>    tags             = optional(map(string))<br>    replica_key_tags = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_org_log_archive_s3_bucket"></a> [org\_log\_archive\_s3\_bucket](#input\_org\_log\_archive\_s3\_bucket) | Config object for the Log-Archive account's titular S3 bucket used as<br>the Organization's log archive. | <pre>object({<br>    name = string<br>    tags = optional(map(string))<br>    access_logs_s3 = object({<br>      name = string<br>      tags = optional(map(string))<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_s3_public_access_blocks"></a> [s3\_public\_access\_blocks](#input\_s3\_public\_access\_blocks) | Config object for account-level rules regarding S3 public access.<br>By default, all S3 buckets/objects should be strictly PRIVATE. Only<br>provide this variable with an override set to "false" if you know<br>what you're doing and it's absolutely necessary. | <pre>object({<br>    block_public_acls       = optional(bool)<br>    block_public_policy     = optional(bool)<br>    ignore_public_acls      = optional(bool)<br>    restrict_public_buckets = optional(bool)<br>  })</pre> | <pre>{<br>  "block_public_acls": true,<br>  "block_public_policy": true,<br>  "ignore_public_acls": true,<br>  "restrict_public_buckets": true<br>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_AWSServiceRoleForCloudWatchCrossAccount"></a> [AWSServiceRoleForCloudWatchCrossAccount](#output\_AWSServiceRoleForCloudWatchCrossAccount) | The CloudWatch service-linked Role that allows monitoring accounts to view CloudWatch data from sharing accounts. |
| <a name="output_Account-Level_S3_Public_Access_Block"></a> [Account-Level\_S3\_Public\_Access\_Block](#output\_Account-Level\_S3\_Public\_Access\_Block) | Account-level S3 public access block resource. |
| <a name="output_Account_Password_Policy"></a> [Account\_Password\_Policy](#output\_Account\_Password\_Policy) | The account's password-policy resource object. |
| <a name="output_CloudWatch-CrossAccountSharingRole"></a> [CloudWatch-CrossAccountSharingRole](#output\_CloudWatch-CrossAccountSharingRole) | The CloudWatch Role that allows CloudWatch data to be shared with monitoring accounts. |
| <a name="output_CloudWatch-Delivery_Role"></a> [CloudWatch-Delivery\_Role](#output\_CloudWatch-Delivery\_Role) | The IAM Service Role that permits delivery of Organization CloudTrail events<br>to the CloudWatch\_LogGroup (will be "null" for all accounts except Log-Archive). |
| <a name="output_CloudWatch-Delivery_Role_Policy"></a> [CloudWatch-Delivery\_Role\_Policy](#output\_CloudWatch-Delivery\_Role\_Policy) | The IAM policy for "CloudWatch-Delivery\_Role" that permits delivery of the Organization's<br>CloudTrail events to the CloudWatch Logs log group (will be "null" for all accounts except Log-Archive). |
| <a name="output_CloudWatch_CIS_Alarms_SNS_Topic"></a> [CloudWatch\_CIS\_Alarms\_SNS\_Topic](#output\_CloudWatch\_CIS\_Alarms\_SNS\_Topic) | The SNS Topic associated with the CloudWatch Metric Alarms defined in CIS Benchmarks. |
| <a name="output_CloudWatch_CIS_Alarms_SNS_Topic_Policy"></a> [CloudWatch\_CIS\_Alarms\_SNS\_Topic\_Policy](#output\_CloudWatch\_CIS\_Alarms\_SNS\_Topic\_Policy) | The SNS Topic Policy associated with the CloudWatch Metric Alarms defined in CIS Benchmarks. |
| <a name="output_CloudWatch_LogGroup"></a> [CloudWatch\_LogGroup](#output\_CloudWatch\_LogGroup) | The CloudWatch Logs log group resource which receives an event stream from the<br>Organization's CloudTrail (will be "null" for all accounts except Log-Archive). |
| <a name="output_CloudWatch_Metric_Alarms"></a> [CloudWatch\_Metric\_Alarms](#output\_CloudWatch\_Metric\_Alarms) | A map of CloudWatch Metric Alarm resources. |
| <a name="output_CloudWatch_Metric_Filters"></a> [CloudWatch\_Metric\_Filters](#output\_CloudWatch\_Metric\_Filters) | A map of CloudWatch Metric Filter resources. |
| <a name="output_Config_Delivery_Channels"></a> [Config\_Delivery\_Channels](#output\_Config\_Delivery\_Channels) | A map of AWS-Config Delivery Channels by region. |
| <a name="output_Config_Recorders"></a> [Config\_Recorders](#output\_Config\_Recorders) | A map of AWS-Config Recorders by region. |
| <a name="output_Default_Network_ACL"></a> [Default\_Network\_ACL](#output\_Default\_Network\_ACL) | The default VPC's default network ACL. |
| <a name="output_Default_RouteTable"></a> [Default\_RouteTable](#output\_Default\_RouteTable) | The default VPC's default route table. |
| <a name="output_Default_SecurityGroup"></a> [Default\_SecurityGroup](#output\_Default\_SecurityGroup) | The default VPC's default security group. |
| <a name="output_Default_VPC"></a> [Default\_VPC](#output\_Default\_VPC) | The account's default VPC resource. |
| <a name="output_Global_Default_EBS_Encryption"></a> [Global\_Default\_EBS\_Encryption](#output\_Global\_Default\_EBS\_Encryption) | Resource that ensures all EBS volumes are encrypted by default. |
| <a name="output_Org_Access_Analyzer"></a> [Org\_Access\_Analyzer](#output\_Org\_Access\_Analyzer) | The Organization's Access Analyzer resource object (will be "null" for non-root<br>accounts). |
| <a name="output_Org_CloudTrail"></a> [Org\_CloudTrail](#output\_Org\_CloudTrail) | The Organization CloudTrail (will be "null" for non-root accounts). |
| <a name="output_Org_Config_Aggregator"></a> [Org\_Config\_Aggregator](#output\_Org\_Config\_Aggregator) | The Config Aggregator resource (will be "null" for non-root accounts). |
| <a name="output_Org_Config_Aggregator_Role"></a> [Org\_Config\_Aggregator\_Role](#output\_Org\_Config\_Aggregator\_Role) | The Config Aggregator Role resource (will be "null" for non-root accounts). |
| <a name="output_Org_Config_Role"></a> [Org\_Config\_Role](#output\_Org\_Config\_Role) | The AWS-Config IAM service role. |
| <a name="output_Org_Config_Role_Policy"></a> [Org\_Config\_Role\_Policy](#output\_Org\_Config\_Role\_Policy) | The IAM policy for "Org\_Config\_Role". |
| <a name="output_Org_Config_SNS_Topics"></a> [Org\_Config\_SNS\_Topics](#output\_Org\_Config\_SNS\_Topics) | A map of AWS-Config SNS Topics by region (will be "null" for non-root accounts). |
| <a name="output_Org_Log_Archive_S3_Access_Logs_Bucket"></a> [Org\_Log\_Archive\_S3\_Access\_Logs\_Bucket](#output\_Org\_Log\_Archive\_S3\_Access\_Logs\_Bucket) | The S3 bucket resource used to store access logs for the Organization's<br>Log-Archive S3 bucket (will be "null" for all accounts except Log-Archive). |
| <a name="output_Org_Log_Archive_S3_Bucket"></a> [Org\_Log\_Archive\_S3\_Bucket](#output\_Org\_Log\_Archive\_S3\_Bucket) | The S3 bucket used to store logs from the Organization's Config and CloudTrail<br>services (will be "null" for all accounts except Log-Archive). |
| <a name="output_Org_Services_KMS_Key"></a> [Org\_Services\_KMS\_Key](#output\_Org\_Services\_KMS\_Key) | The KMS key resource used to encrypt Log-Archive files, as well as data streams<br>related to Organization-wide services like CloudTrail and CloudWatch. |
| <a name="output_OrganizationAccountAccessRole"></a> [OrganizationAccountAccessRole](#output\_OrganizationAccountAccessRole) | The hardened role used by Administrators to manage AWS resources in Terraform/Terragrunt configs. |

---

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center" style="margin-top:30px;">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [T.AndersonProperty@gmail.com](mailto:T.AndersonProperty@gmail.com)

  <a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/YouTube_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/trevor-anderson-3a3b0392/">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/LinkedIn_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://twitter.com/TeeRevTweets">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/Twitter_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="mailto:T.AndersonProperty@gmail.com">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/email_icon_circle.svg" height="40" />
  </a>
  <br><br>

  <a href="https://daremightythings.co/">
    <strong><i>Dare Mighty Things.</i></strong>
  </a>

</div>
<!-- prettier-ignore-end -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
