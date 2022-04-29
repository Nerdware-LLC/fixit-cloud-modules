# Fixit Cloud ☁️ MODULE: AWS IAM Instance Profile

Terraform module for defining an EC2 instance profile.

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
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2_key_pair"></a> [ec2\_key\_pair](#input\_ec2\_key\_pair) | Config object for an optional EC2 key\_pair resource. Public keys can be created<br>from existing private keys via the following command (use your local file names):<br>`ssh-keygen -y -f ~/.ssh/my_private_key.pem > ~/.ssh/new_public_key.pub`. | <pre>object({<br>    key_name   = string<br>    public_key = string<br>    tags       = optional(map(string))<br>  })</pre> | `null` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | Config object for the Instance Profile's associated IAM Role. As a matter of<br>best practice, the "AmazonSSMManagedInstanceCore" and "CloudWatchAgentServerPolicy"<br>policies are automatically attached to the Role. Other existing IAM policies can<br>be attached via the "policy\_arns" key; alternatively, one-off policies unique to<br>this Instance Profile can be provided via the "custom\_iam\_policies" key. Either<br>way, all policies are attached via the "aws\_iam\_role\_policy\_attachment" resource. | <pre>object({<br>    name        = string<br>    description = optional(string)<br>    path        = optional(string)<br>    tags        = optional(map(string))<br>    policy_arns = optional(list(string))<br>    custom_iam_policies = optional(list(object({<br>      policy_name = string<br>      policy_json = string<br>      description = optional(string)<br>      path        = optional(string)<br>      tags        = optional(map(string))<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Instance Profile. | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path to the instance profile; defaults to "/". | `string` | `"/"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of resource tags for the IAM Instance Profile. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Custom_IAM_Policies"></a> [Custom\_IAM\_Policies](#output\_Custom\_IAM\_Policies) | Map of custom IAM Policy resources by policy\_name. |
| <a name="output_EC2_Key_Pair"></a> [EC2\_Key\_Pair](#output\_EC2\_Key\_Pair) | The EC2 Key Pair resource object. |
| <a name="output_IAM_Instance_Profile"></a> [IAM\_Instance\_Profile](#output\_IAM\_Instance\_Profile) | Instance Profile resource object. |
| <a name="output_IAM_Role"></a> [IAM\_Role](#output\_IAM\_Role) | IAM Role resource object. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
