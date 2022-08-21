<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS Organization</h1>

Terraform module for defining an AWS Organization and related resources.

</div>

<h2>Table of Contents</h2>

- [Usage Examples](#usage-examples)
- [Trusted AWS Service Principals](#trusted-aws-service-principals)
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

<!-- TODO Add info here, explainer re: AWS Orgs, relevant AWS CIS Benchmarks & SecHub Standards on Org resources -->

## Usage Examples

- Terragrunt: [view Terragrunt usage exmaple](examples/terragrunt.hcl)
- Terraform: &nbsp;[view vanilla Terraform usage exmaple](examples/terraform.tf)

## Trusted AWS Service Principals

You can use trusted access to enable supported AWS services to perform tasks in your Organization and its accounts on your behalf. This involves granting permissions to the trusted service but does not otherwise affect the permissions for IAM Users or Roles. When you enable access, the trusted service can create an IAM Service-Linked Role in every account in your Organization whenever that Role is needed. That Role has a permissions policy that allows the trusted service to do the tasks that are described in that service's documentation. This enables you to specify settings and configuration details that you would like the trusted service to maintain in your Organization's Accounts on your behalf. The trusted service only creates Service-Linked Roles when it needs to perform management actions on Accounts, and not necessarily in all Accounts of the Organization.

For more info, please review the [list of AWS services](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html) which work with AWS Organizations.

## Useful Links

- [AWS Docs: Organization Service Control Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
- [AWS Docs: Organization Management Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies.html)
- [AWS Docs: Organization IAM Identity Center (formerly SSO)](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)

<!-- TODO Add more info here explaining the following AWS Org concepts: SCPs, Mgmt Policies, SSO -->

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
| [aws_accessanalyzer_analyzer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_organizations_account.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_delegated_administrator.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.Level_1_OUs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.Level_2_OUs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.Level_3_OUs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.Level_4_OUs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.Level_5_OUs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_ssoadmin_account_assignment.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_managed_policy_attachment.AdministratorAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.AdministratorAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_identitystore_group.Admins_SSO_Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_sso_config"></a> [admin\_sso\_config](#input\_admin\_sso\_config) | Map of SSO Administrator Object for configuring administrator access to accounts via AWS SSO. | <pre>object({<br>    sso_group_name             = string<br>    permission_set_name        = optional(string)<br>    permission_set_description = optional(string)<br>    permission_set_tags        = optional(map(string))<br>    session_duration           = optional(number)<br>  })</pre> | n/a | yes |
| <a name="input_delegated_administrators"></a> [delegated\_administrators](#input\_delegated\_administrators) | Map of AWS service principals to delegated administrator account names. Delegated<br>admin accounts must already be members of the root account's Organization. | `map(string)` | `{}` | no |
| <a name="input_member_accounts"></a> [member\_accounts](#input\_member\_accounts) | Map of Organization Account names to config objects. Note that AWS Organization<br>best practices entails attaching organization policies to OUs - not accounts - so<br>this module does not permit member accounts to have a "parent" value of "root".<br>The "should\_allow\_iam\_user\_access\_to\_billing" property defaults to "true",<br>and "org\_account\_access\_role\_name" defaults to "OrganizationAccountAccessRole". | <pre>map(<br>    # map keys: account names<br>    object({<br>      parent                                  = string<br>      email                                   = string<br>      should_allow_iam_user_access_to_billing = optional(bool)<br>      org_account_access_role_name            = optional(string)<br>      tags                                    = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_org_access_analyzer"></a> [org\_access\_analyzer](#input\_org\_access\_analyzer) | Config object for the Organization's Access Analyzer. | <pre>object({<br>    name = string<br>    tags = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_organization_config"></a> [organization\_config](#input\_organization\_config) | Config object for an AWS Organization. "enabled\_policy\_types" must be one<br>of "AISERVICES\_OPT\_OUT\_POLICY", "BACKUP\_POLICY", "SERVICE\_CONTROL\_POLICY",<br>or "TAG\_POLICY". | <pre>object({<br>    org_trusted_services = list(string)<br>    enabled_policy_types = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_organization_policies"></a> [organization\_policies](#input\_organization\_policies) | Map organization policy names to config objects. The "target" property indicates<br>to which organization entity the policy should be attached; valid values are "root"<br>and the name of any OU. The "type" for each policy config object can be one one of<br>the following: SERVICE\_CONTROL\_POLICY, AISERVICES\_OPT\_OUT\_POLICY, BACKUP\_POLICY,<br>or TAG\_POLICY. "statement" must be a valid JSON string. Please refer to AWS docs<br>for info regarding how to structure each policy type. | <pre>map(<br>    # map keys: organization policy names<br>    object({<br>      target      = string<br>      type        = string<br>      description = optional(string)<br>      statement   = string<br>      tags        = optional(map(string))<br>    })<br>  )</pre> | `null` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | Map of Organizational Unit names to config objects. "parent" must be<br>"root" or the name of another OU within var.organizational\_units. | <pre>map(<br>    # map keys: OU names<br>    object({<br>      parent = string<br>      tags   = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Delegated_Administrators"></a> [Delegated\_Administrators](#output\_Delegated\_Administrators) | Map of Delegated Admin resource objects. |
| <a name="output_Org_Access_Analyzer"></a> [Org\_Access\_Analyzer](#output\_Org\_Access\_Analyzer) | The Organization's Access Analyzer resource object. |
| <a name="output_Organization"></a> [Organization](#output\_Organization) | The AWS Organization resource object. |
| <a name="output_Organization_Member_Accounts"></a> [Organization\_Member\_Accounts](#output\_Organization\_Member\_Accounts) | Map of Organization Member Account resource objects. |
| <a name="output_Organization_Policies"></a> [Organization\_Policies](#output\_Organization\_Policies) | Map of Organization Policy resource objects. |
| <a name="output_Organizational_Units"></a> [Organizational\_Units](#output\_Organizational\_Units) | Map of Organizational Unit resource objects. |
| <a name="output_SSO_Admin_Account_Assignments"></a> [SSO\_Admin\_Account\_Assignments](#output\_SSO\_Admin\_Account\_Assignments) | Map of SSO Admin Account Assignment resource objects. |
| <a name="output_SSO_Admin_Managed_Policy_Attachment"></a> [SSO\_Admin\_Managed\_Policy\_Attachment](#output\_SSO\_Admin\_Managed\_Policy\_Attachment) | The SSO Admin Permission Set resource object. |
| <a name="output_SSO_Admin_Permission_Set"></a> [SSO\_Admin\_Permission\_Set](#output\_SSO\_Admin\_Permission\_Set) | The SSO Admin Permission Set resource object for "AdministratorAccess". |

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
