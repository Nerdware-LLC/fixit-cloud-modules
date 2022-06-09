<h1>Fixit Cloud ☁️ MODULE: AWS Organization</h1>

Terraform module for defining an AWS Organization and related resources.

<h2>Table of Contents</h2>

- [AWS Organization](#aws-organization)
    - [Trusted AWS Service Principals](#trusted-aws-service-principals)
    - [Policy Types](#policy-types)
    - [Service Control Policies](#service-control-policies)
    - [Management Policies](#management-policies)
- [AWS SSO](#aws-sso)
- [⚙️ Module Usage](#️-module-usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)

## AWS Organization

TODO add quick paragraph about aws orgs

<!-- Below paragraph is from main.Organizations.tf OUs locals block -->

To avoid CYCLE ERRORs in nested organizational_unit resources,
we need to have separate resource blocks - one for each nesting depth
within the organization's structure. AWS allows organizations to have a
maximum nesting depth of 5, which includes the root account as well as
account leaf-nodes within the org tree. Therefore, our implementation
can provide 3 OU nesting levels:
Level_1 --> OUs that are direct children of root
Level_2 --> OUs that are direct children of L1 OUs
Level_3 --> OUs that are direct children of L2 OUs

#### Trusted AWS Service Principals

You can use trusted access to enable a supported AWS service that you specify, called the trusted service, to perform tasks in your organization and its accounts on your behalf. This involves granting permissions to the trusted service but does not otherwise affect the permissions for IAM users or roles. When you enable access, the trusted service can create an IAM role called a service-linked role in every account in your organization whenever that role is needed. That role has a permissions policy that allows the trusted service to do the tasks that are described in that service's documentation. This enables you to specify settings and configuration details that you would like the trusted service to maintain in your organization's accounts on your behalf. The trusted service only creates service-linked roles when it needs to perform management actions on accounts, and not necessarily in all accounts of the organization.

For more info, please review the [list of AWS services][org-services] which work with AWS Organizations.

#### Policy Types

There are four values that can be included in var.organization_config.enabled_policy_types:

- AISERVICES_OPT_OUT_POLICY
- BACKUP_POLICY
- SERVICE_CONTROL_POLICY
- TAG_POLICY

TODO expand above explainer

#### Service Control Policies

TODO add info on our SCPs

#### Management Policies

TODO add info on our mgmt policies

## AWS SSO

TODO explain our sso setup

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-start -->

---

## ⚙️ Module Usage

### Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | 1.2.2     |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.11.0 |

### Providers

| Name                                             | Version   |
| ------------------------------------------------ | --------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 4.11.0 |

### Modules

No modules.

### Resources

| Name                                                                                                                                                                         | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_organizations_account.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account)                                           | resource    |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization)                                | resource    |
| [aws_organizations_organizational_unit.Level_1_OUs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit)           | resource    |
| [aws_organizations_organizational_unit.Level_2_OUs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit)           | resource    |
| [aws_organizations_organizational_unit.Level_3_OUs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit)           | resource    |
| [aws_organizations_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy)                                             | resource    |
| [aws_organizations_policy_attachment.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment)                       | resource    |
| [aws_ssoadmin_account_assignment.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment)                               | resource    |
| [aws_ssoadmin_managed_policy_attachment.AdministratorAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource    |
| [aws_ssoadmin_permission_set.AdministratorAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set)                       | resource    |
| [aws_identitystore_group.Admins_SSO_Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group)                               | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances)                                             | data source |

### Inputs

| Name                                                                                             | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Type                                                                                                                                                                                                                                                  | Default | Required |
| ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_admin_sso_config"></a> [admin_sso_config](#input_admin_sso_config)                | An object for configuring administrator access to accounts via AWS SSO.<br>Please note that SSO requires some setup in the console; for example,<br>GROUPS and USERS cannot be created via the AWS provider - they must be<br>created beforehand. For an overview of the default config values, please<br>refer to the README.                                                                                                                                                                                                                                                                                                        | <pre>object({<br> sso_group_name = optional(string)<br> permission_set_name = optional(string)<br> permission_set_description = optional(string)<br> permission_set_tags = optional(map(string))<br> session_duration = optional(number)<br> })</pre> | `{}`    |    no    |
| <a name="input_member_accounts"></a> [member_accounts](#input_member_accounts)                   | A config object for child/member accounts within an AWS Organization.<br>The keys of the object are names of child accounts, with each respective<br>value pointing to the account's config object with params identifying the<br>parent organizational unit and other attributes. Note that best practices<br>entails attaching organization policies to OUs - not accounts - so this<br>module does not permit member accounts to have a "parent" value of "root".<br>The "should_allow_iam_user_access_to_billing" property defaults to "true",<br>and "org_account_access_role_name" defaults to "OrganizationAccountAccessRole". | <pre>map(object({<br> parent = string<br> email = string<br> should_allow_iam_user_access_to_billing = optional(bool)<br> org_account_access_role_name = optional(string)<br> tags = optional(map(string))<br> }))</pre>                              | n/a     |   yes    |
| <a name="input_organization_config"></a> [organization_config](#input_organization_config)       | A config object for an AWS Organization. For more info on these<br>parameters, please refer to the documentation for AWS Organizations and<br>the relevant API/CLI commands. Note that "should_enable_all_features"<br>defaults to "true".                                                                                                                                                                                                                                                                                                                                                                                            | <pre>object({<br> org_trusted_services = list(string)<br> enabled_policy_types = list(string)<br> })</pre>                                                                                                                                            | n/a     |   yes    |
| <a name="input_organization_policies"></a> [organization_policies](#input_organization_policies) | Map policy names to organization policy config objects to provision<br>organization policies. The "target" property indicates to which<br>organization entity the policy should be attached; valid values are "root" and<br>the name of any OU. The "type" for each policy config object can be one one of<br>the following: SERVICE_CONTROL_POLICY, AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY,<br>or TAG_POLICY. "statement" must be a valid JSON string. Please refer to AWS docs<br>for info regarding how to structure each policy type.                                                                                           | <pre>map(object({<br> target = string<br> type = string<br> description = optional(string)<br> statement = string<br> tags = optional(map(string))<br> }))</pre>                                                                                      | `null`  |    no    |
| <a name="input_organizational_units"></a> [organizational_units](#input_organizational_units)    | A map of config objects for orginizational units within an AWS<br>Organization. The keys of the map are names of OU entities, with each<br>respective value pointing to the OU's config object with params identifying<br>the OU's parent entity ("root" or the name of another OU) and optional tags.                                                                                                                                                                                                                                                                                                                                | <pre>map(object({<br> parent = string<br> tags = optional(map(string))<br> }))</pre>                                                                                                                                                                  | n/a     |   yes    |

### Outputs

| Name                                                                                                                    | Description |
| ----------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_Organization"></a> [Organization](#output_Organization)                                                 | n/a         |
| <a name="output_Organization_Member_Accounts"></a> [Organization_Member_Accounts](#output_Organization_Member_Accounts) | n/a         |
| <a name="output_Organization_Policies"></a> [Organization_Policies](#output_Organization_Policies)                      | n/a         |
| <a name="output_Organizational_Units"></a> [Organizational_Units](#output_Organizational_Units)                         | n/a         |

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
