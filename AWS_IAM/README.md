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
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | Config object for the Instance Profile's associated IAM Role. As a matter of<br>best practice, the "AmazonSSMManagedInstanceCore" and "CloudWatchAgentServerPolicy"<br>policies are automatically attached to the Role. Other existing IAM policies can<br>be attached via the "policy\_arns" key; alternatively, one-off policies unique to<br>this Instance Profile can be provided via the "custom\_iam\_policies" key. Either<br>way, all policies are attached via the "aws\_iam\_role\_policy\_attachment" resource. | <pre>object({<br>    name        = string<br>    description = optional(string)<br>    path        = optional(string)<br>    tags        = optional(map(string))<br>    policy_arns = optional(list(string))<br>    custom_iam_policies = optional(list(object({<br>      policy_name = string<br>      policy_json = string<br>      description = optional(string)<br>      path        = optional(string)<br>      tags        = optional(map(string))<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Instance Profile. | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path to the instance profile; defaults to "/". | `string` | `"/"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of resource tags for the IAM Instance Profile. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Custom_IAM_Policies"></a> [Custom\_IAM\_Policies](#output\_Custom\_IAM\_Policies) | Map of custom IAM Policy resources by policy\_name. |
| <a name="output_IAM_Instance_Profile"></a> [IAM\_Instance\_Profile](#output\_IAM\_Instance\_Profile) | Instance Profile resource object. |
| <a name="output_IAM_Role"></a> [IAM\_Role](#output\_IAM\_Role) | IAM Role resource object. |
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
