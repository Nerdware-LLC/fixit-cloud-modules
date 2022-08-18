<h1>Fixit Cloud ☁️ MODULE: AWS IAM</h2>

Terraform module for defining IAM resources.

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
| [aws_iam_instance_profile.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_service_linked_role.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_iam_policies"></a> [custom\_iam\_policies](#input\_custom\_iam\_policies) | Map of custom IAM Policy names to policy config objects. For each policy,<br>the "policy\_json" property must be a JSON-encoded string. IAM Roles included<br>in var.iam\_roles may reference these policies by name in their "policies"<br>property. | <pre>map(<br>    # map keys: IAM Policy names<br>    object({<br>      policy_json = string<br>      description = optional(string)<br>      path        = optional(string)<br>      tags        = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | Map of IAM Role names to role config objects. The role's AssumeRole<br>policy may be configured in one of two ways: you can either provide a<br>complete AssumeRole policy document as a JSON-encoded string via the<br>"assume\_role\_policy\_json" property, or you can simply provide the<br>fully-qualified domain name of an AWS service (e.g., "ec2.amazonaws.com")<br>via the "service\_assume\_role" property, and a basic condition-less<br>AssumeRole policy will be created for you using that service.<br>To attach policies to your roles, you can include ARNs of existing<br>policies (custom or AWS-managed) in the "policies" list property. To<br>attach policies you've defined in var.custom\_iam\_policies, you can simply<br>include the names of those policies in this list as well. | <pre>map(<br>    # map keys: IAM Role names<br>    object({<br>      description             = optional(string)<br>      path                    = optional(string)<br>      assume_role_policy_json = optional(string)<br>      service_assume_role     = optional(string)<br>      oidc_assume_role        = optional(string)<br>      policies                = optional(list(string))<br>      tags                    = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_iam_service_linked_roles"></a> [iam\_service\_linked\_roles](#input\_iam\_service\_linked\_roles) | Map of IAM Service-Linked Role URLs (e.g., "elasticbeanstalk.amazonaws.com") to<br>config objects for each respective service-linked role. | <pre>map(<br>    # map keys: AWS service URL<br>    object({<br>      description = optional(string)<br>      tags        = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_instance_profiles"></a> [instance\_profiles](#input\_instance\_profiles) | Map of Instance Profile names to config objects. To associate an instance<br>profile with an existing role (one not created in the same module call),<br>use "role\_arn". To associate a role included in var.iam\_roles, provide<br>the name of the desired role to "role\_name". | <pre>map(<br>    # map keys: Instance Profile names<br>    object({<br>      path      = optional(string)<br>      role_arn  = optional(string)<br>      role_name = optional(string)<br>      tags      = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_openID_connect_providers"></a> [openID\_connect\_providers](#input\_openID\_connect\_providers) | (Optional) Map of OpenID Connect (OIDC) Identity Provider names to config objects.<br>"Built-in" identity providers which don't require an IdP to be created within IAM<br>(Amazon Cognito, Google, and Facebook), don't require explicit creation within AWS.<br>To associate an OIDC IdP with an existing role (one not created in the same module<br>call), use "role\_arn". To associate a role included in var.iam\_roles, provide the<br>name of the desired role to "role\_name". | <pre>map(<br>    # map keys: OIDC IdP names<br>    object({<br>      url                    = string<br>      client_id_list         = list(string)<br>      thumbprint_list        = list(string)<br>      assume_role_conditions = map(any)<br>      tags                   = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Custom_IAM_Policies"></a> [Custom\_IAM\_Policies](#output\_Custom\_IAM\_Policies) | Map of custom IAM Policy resources by policy name. |
| <a name="output_IAM_Instance_Profile"></a> [IAM\_Instance\_Profile](#output\_IAM\_Instance\_Profile) | Map of Instance Profile resource objects. |
| <a name="output_IAM_Role_Policy_Attachments"></a> [IAM\_Role\_Policy\_Attachments](#output\_IAM\_Role\_Policy\_Attachments) | Map of IAM Role Policy Attachment resource objects, the keys of which<br>are JSON-encoded objects with keys "role" and "policy\_arn". |
| <a name="output_IAM_Roles"></a> [IAM\_Roles](#output\_IAM\_Roles) | Map of IAM Role resource objects. |
| <a name="output_IAM_Service_Linked_Roles"></a> [IAM\_Service\_Linked\_Roles](#output\_IAM\_Service\_Linked\_Roles) | Map of IAM Service-Linked Role resource objects. |
| <a name="output_OpenID_Connect_Providers"></a> [OpenID\_Connect\_Providers](#output\_OpenID\_Connect\_Providers) | Map of IAM OpenID Connect (OIDC) Identity Provider resource objects. |

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
