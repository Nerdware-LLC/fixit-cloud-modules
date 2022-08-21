<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS SecurityHub</h1>

Terraform module for SecurityHub resource management.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.7 |
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
| [aws_securityhub_account.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_finding_aggregator.All_Regions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_finding_aggregator) | resource |
| [aws_securityhub_member.Member_Accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_member) | resource |
| [aws_securityhub_organization_admin_account.Org_Admin_Account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account) | resource |
| [aws_securityhub_organization_configuration.Org_Config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_configuration) | resource |
| [aws_securityhub_standards_subscription.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_securityhub_standards_subscription.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_securityhub_member_accounts"></a> [securityhub\_member\_accounts](#input\_securityhub\_member\_accounts) | List of account param objects for all accounts within the<br>Organization. The Delegated Admin account needs this list to add<br>each account to the Org's SecurityHub service - all other accounts<br>should NOT provide a value for this variable. | <pre>map(object({<br>    id    = string<br>    email = string<br>  }))</pre> | `null` | no |
| <a name="input_securityhub_organization_admin_account_id"></a> [securityhub\_organization\_admin\_account\_id](#input\_securityhub\_organization\_admin\_account\_id) | The ID of the account designated as the delegated administrator<br>for the SecurityHub service. Must be applied by the Organization<br>root account before any other resources can be applied. | `string` | `null` | no |
| <a name="input_standards_arns_by_region"></a> [standards\_arns\_by\_region](#input\_standards\_arns\_by\_region) | Config object for enabling SecurityHub Standards by region. | <pre>object({<br>    ap-northeast-1 = optional(list(string)) # Asia Pacific (Tokyo)<br>    ap-northeast-2 = optional(list(string)) # Asia Pacific (Seoul)<br>    ap-northeast-3 = optional(list(string)) # Asia Pacific (Osaka)<br>    ap-south-1     = optional(list(string)) # Asia Pacific (Mumbai)<br>    ap-southeast-1 = optional(list(string)) # Asia Pacific (Singapore)<br>    ap-southeast-2 = optional(list(string)) # Asia Pacific (Sydney)<br>    ca-central-1   = optional(list(string)) # Canada (Central)<br>    eu-north-1     = optional(list(string)) # Europe (Stockholm)<br>    eu-central-1   = optional(list(string)) # Europe (Frankfurt)<br>    eu-west-1      = optional(list(string)) # Europe (Ireland)<br>    eu-west-2      = optional(list(string)) # Europe (London)<br>    eu-west-3      = optional(list(string)) # Europe (Paris)<br>    sa-east-1      = optional(list(string)) # South America (São Paulo)<br>    us-east-1      = optional(list(string)) # US East (N. Virginia)<br>    us-east-2      = optional(list(string)) # US East (Ohio)<br>    us-west-1      = optional(list(string)) # US West (N. California)<br>    us-west-2      = optional(list(string)) # US West (Oregon)<br>  })</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_SecurityHub_Finding_Aggregator"></a> [SecurityHub\_Finding\_Aggregator](#output\_SecurityHub\_Finding\_Aggregator) | The SecurityHub Finding Aggregator resource. |
| <a name="output_SecurityHub_Member_Account"></a> [SecurityHub\_Member\_Account](#output\_SecurityHub\_Member\_Account) | A SecurityHub Member Account resource (will be "null" for non-Security accounts). |
| <a name="output_SecurityHub_Org_Admin_Account"></a> [SecurityHub\_Org\_Admin\_Account](#output\_SecurityHub\_Org\_Admin\_Account) | The SecurityHub Org Admin Account resource. |
| <a name="output_SecurityHub_Org_Config"></a> [SecurityHub\_Org\_Config](#output\_SecurityHub\_Org\_Config) | The SecurityHub Organization configuration resource. |
| <a name="output_SecurityHub_Subscriptions_BY_REGION"></a> [SecurityHub\_Subscriptions\_BY\_REGION](#output\_SecurityHub\_Subscriptions\_BY\_REGION) | A map of SecurityHub Standards subscription resources, organized by region. |

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
