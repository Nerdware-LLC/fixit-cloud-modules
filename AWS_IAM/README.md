<h1>Fixit Cloud ☁️ MODULE: AWS IAM</h2>

Terraform module for defining IAM resources.

<h2>Table of Contents</h2>

- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [License](#license)
- [Contact](#contact)

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_iam_policies"></a> [custom\_iam\_policies](#input\_custom\_iam\_policies) | Map of custom IAM Policy names to policy config objects. For each policy,<br>the "policy\_json" property must be a JSON-encoded string. IAM Roles included<br>in var.iam\_roles may reference these policies by name in their "policies"<br>property. | <pre>map(object({<br>    policy_json = string<br>    description = optional(string)<br>    path        = optional(string)<br>    tags        = optional(map(string))<br>  }))</pre> | `{}` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | Map of IAM Role names to role config objects. The role's AssumeRole<br>policy may be configured in one of two ways: you can either provide a<br>complete AssumeRole policy document as a JSON-encoded string via the<br>"assume\_role\_policy\_json" property, or you can simply provide the<br>fully-qualified domain name of an AWS service (e.g., "ec2.amazonaws.com")<br>via the "service\_assume\_role" property, and a basic condition-less<br>AssumeRole policy will be created for you using that service.<br>To attach policies to your roles, you can include ARNs of existing<br>policies (custom or AWS-managed) in the "policies" list property. To<br>attach policies you've defined in var.custom\_iam\_policies, you can simply<br>include the names of those policies in this list as well. | <pre>map(object({<br>    description             = optional(string)<br>    path                    = optional(string)<br>    assume_role_policy_json = optional(string)<br>    service_assume_role     = optional(string)<br>    policies                = optional(list(string))<br>    tags                    = optional(map(string))<br>  }))</pre> | `{}` | no |
| <a name="input_instance_profiles"></a> [instance\_profiles](#input\_instance\_profiles) | Map of Instance Profile names to config objects. To associate an instance<br>profile with an existing role (one not created in the same module call),<br>use "role\_arn". To associate a role included in var.iam\_roles, provide<br>the name of the desired role to "role\_name". | <pre>map(object({<br>    path      = optional(string)<br>    role_arn  = optional(string)<br>    role_name = optional(string)<br>    tags      = optional(map(string))<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Custom_IAM_Policies"></a> [Custom\_IAM\_Policies](#output\_Custom\_IAM\_Policies) | Map of custom IAM Policy resources by policy name. |
| <a name="output_IAM_Instance_Profile"></a> [IAM\_Instance\_Profile](#output\_IAM\_Instance\_Profile) | Map of Instance Profile resource objects. |
| <a name="output_IAM_Roles"></a> [IAM\_Roles](#output\_IAM\_Roles) | Map of IAM Role resource objects. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

---

## License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

## Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - T.AndersonProperty@gmail.com

[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[pre-commit-shield]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
[fixit-cloud-live]: https://github.com/Nerdware-LLC/fixit-cloud-live
[linkedin-url]: https://www.linkedin.com/in/trevor-anderson-3a3b0392/
[linkedin-shield]: https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white
