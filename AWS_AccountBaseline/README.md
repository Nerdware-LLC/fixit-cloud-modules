<div align="center">
  <h1> Fixit Cloud ☁️ Module: AWS Account Baseline</h1>

Terraform module for providing a hardened baseline security posture for AWS accounts within an AWS Organization.

</div>

<h2>Table of Contents</h2>

- [AWS Account Default Settings](#aws-account-default-settings)
- [Default VPC Resouces](#default-vpc-resouces)
- [Relevant Security Standards & Controls](#relevant-security-standards--controls)
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

## AWS Account Default Settings

| Account Setting                               | Value | Configurable? |
| :-------------------------------------------- | :---- | :-----------: |
| Password Policy: minimum length               | 14    |      ❌       |
| Password Policy: require lowercase characters | true  |      ❌       |
| Password Policy: require uppercase characters | true  |      ❌       |
| Password Policy: require numbers              | true  |      ❌       |
| Password Policy: require symbols              | true  |      ❌       |
| Password Policy: max password age             | 90    |      ❌       |
| Password Policy: password reuse prevention    | 5     |      ❌       |
| Password Policy: allow users to change pw     | true  |      ❌       |
| Password Policy: hard expiry                  | false |      ❌       |
| EBS Encryption by Default                     | true  |      ❌       |
| S3 Public Access: block public ACLs           | true  |      ✅       |
| S3 Public Access: block public policy         | true  |      ✅       |
| S3 Public Access: ignore public ACLs          | true  |      ✅       |
| S3 Public Access: restrict public buckets     | true  |      ✅       |

## Default VPC Resouces

In accordance with best practices, this module locks down default VPC components to ensure all ingress/egress traffic only uses infrastructure with purposefully-designed rules and configurations.

## Relevant Security Standards & Controls

| Source                                   | Control                                                                            | Config Rule                                    | Pass/Fail |
| :--------------------------------------- | :--------------------------------------------------------------------------------- | :--------------------------------------------- | :-------: |
| CIS AWS Foundations Benchmark v1.4       | [[1.3]][cis-1.3] Ensure credentials unused for 90 days or greater are disabled     | iam-user-unused-credentials-check              |    ✅     |
| CIS AWS Foundations Benchmark v1.4       | [[1.5]][cis-1.5] Ensure IAM password policy requires at least one uppercase letter | iam-password-policy                            |    ✅     |
| CIS AWS Foundations Benchmark v1.4       | [[1.6]][cis-1.6] Ensure IAM password policy requires at least one lowercase letter | iam-password-policy                            |    ✅     |
| CIS AWS Foundations Benchmark v1.4       | [[1.7]][cis-1.7] Ensure IAM password policy requires at least one symbol           | iam-password-policy                            |    ✅     |
| CIS AWS Foundations Benchmark v1.4       | [[1.8]][cis-1.8] Ensure IAM password policy requires at least one number           | iam-password-policy                            |    ✅     |
| CIS AWS Foundations Benchmark v1.4       | [[1.9]][cis-1.9] Ensure IAM password policy requires a min length of 14 or greater | iam-password-policy                            |    ✅     |
| CIS AWS Foundations Benchmark v1.4       | [[1.10]][cis-1.10] Ensure IAM password policy prevents password reuse              | iam-password-policy                            |    ✅     |
| AWS Foundational Security Best Practices | [[S3.1]][fsbp-s3-1] S3 Block Public Access setting should be enabled               | s3-account-level-public-access-blocks-periodic |    ✅     |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-start -->

---

## ⚙️ Module Usage

### Usage Examples

- Terragrunt: [view Terragrunt usage exmaple](examples/terragrunt.hcl)
- Terraform: &nbsp;[view vanilla Terraform usage exmaple](examples/terraform.tf)

### Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | 1.2.7     |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.11.0 |

### Providers

| Name                                             | Version   |
| ------------------------------------------------ | --------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 4.11.0 |

### Modules

No modules.

### Resources

| Name                                                                                                                                                  | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl)                       | resource |
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table)                       | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group)                 | resource |
| [aws_default_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc)                                       | resource |
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default)           | resource |
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy)       | resource |
| [aws_s3_account_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |

### Inputs

| Name                                                                                                               | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Type                                                                                                                                                                                                                  | Default                                                                                                                                         | Required |
| ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_default_vpc_component_tags"></a> [default_vpc_component_tags](#input_default_vpc_component_tags)    | In accordance with best practices, this module locks down the default VPC and all<br>its components to ensure all ingress/egress traffic only uses infrastructure with<br>purposefully-designed rules and configs. Default subnets must be deleted manually<br>- they cannot be removed via Terraform. This variable allows you to customize the<br>tags on these "default" network components; defaults will be used if not provided.                                                      | <pre>object({<br> default_vpc = optional(map(string))<br> default_route_table = optional(map(string))<br> default_network_acl = optional(map(string))<br> default_security_group = optional(map(string))<br> })</pre> | <pre>{<br> "default_network_acl": null,<br> "default_route_table": null,<br> "default_security_group": null,<br> "default_vpc": null<br>}</pre> |    no    |
| <a name="input_iam_account_password_policy"></a> [iam_account_password_policy](#input_iam_account_password_policy) | Config object for customizing an account's IAM password policy. If not<br>provided, by default this module will set each value to the minimum<br>required by CIS AWS Foundations Benchmark (v1.4.0). For "max_password_age",<br>this value is 90 days, "min_password_length" is 14, and the number of times<br>a password can be reused - "password_reuse_prevention" - is 24. Values which<br>are below those required by the CIS Benchmark Controls will result in a<br>validation error. | <pre>object({<br> max_password_age = optional(number)<br> min_password_length = optional(number)<br> password_reuse_prevention = optional(number)<br> })</pre>                                                        | <pre>{<br> "max_password_age": 90,<br> "min_password_length": 14,<br> "password_reuse_prevention": 24<br>}</pre>                                |    no    |

### Outputs

| Name                                                                                                                                            | Description                                                     |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| <a name="output_Account-Level_S3_Public_Access_Block"></a> [Account-Level_S3_Public_Access_Block](#output_Account-Level_S3_Public_Access_Block) | Account-level S3 public access block resource.                  |
| <a name="output_Account_Password_Policy"></a> [Account_Password_Policy](#output_Account_Password_Policy)                                        | The account's password-policy resource object.                  |
| <a name="output_Default_Network_ACL"></a> [Default_Network_ACL](#output_Default_Network_ACL)                                                    | The default VPC's default network ACL.                          |
| <a name="output_Default_RouteTable"></a> [Default_RouteTable](#output_Default_RouteTable)                                                       | The default VPC's default route table.                          |
| <a name="output_Default_SecurityGroup"></a> [Default_SecurityGroup](#output_Default_SecurityGroup)                                              | The default VPC's default security group.                       |
| <a name="output_Default_VPC"></a> [Default_VPC](#output_Default_VPC)                                                                            | The account's default VPC resource.                             |
| <a name="output_Global_Default_EBS_Encryption"></a> [Global_Default_EBS_Encryption](#output_Global_Default_EBS_Encryption)                      | Resource that ensures all EBS volumes are encrypted by default. |

---

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center" style="margin-top:30px;">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [Trevor@Nerdware.cloud](mailto:trevor@nerdware.cloud)

  <a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
    <img src="../.github/assets/YouTube\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/meet-trevor-anderson/">
    <img src="../.github/assets/LinkedIn\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://twitter.com/TeeRevTweets">
    <img src="../.github/assets/Twitter\_icon\_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="mailto:trevor@nerdware.cloud">
    <img src="../.github/assets/email\_icon\_circle.svg" height="40" />
  </a>
  <br><br>

  <a href="https://daremightythings.co/">
    <strong><i>Dare Mighty Things.</i></strong>
  </a>

</div>
<!-- prettier-ignore-end -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- LINKS -->

[cis-1.3]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.3
[cis-1.5]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.5
[cis-1.6]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.6
[cis-1.7]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.7
[cis-1.8]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.8
[cis-1.9]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.9
[cis-1.10]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.10
[fsbp-s3-1]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-s3-1
