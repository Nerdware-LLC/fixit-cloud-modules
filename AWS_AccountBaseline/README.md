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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.34.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.34.0 |
| <a name="provider_aws.ap-northeast-1"></a> [aws.ap-northeast-1](#provider\_aws.ap-northeast-1) | ~> 4.34.0 |
| <a name="provider_aws.ap-northeast-2"></a> [aws.ap-northeast-2](#provider\_aws.ap-northeast-2) | ~> 4.34.0 |
| <a name="provider_aws.ap-northeast-3"></a> [aws.ap-northeast-3](#provider\_aws.ap-northeast-3) | ~> 4.34.0 |
| <a name="provider_aws.ap-south-1"></a> [aws.ap-south-1](#provider\_aws.ap-south-1) | ~> 4.34.0 |
| <a name="provider_aws.ap-southeast-1"></a> [aws.ap-southeast-1](#provider\_aws.ap-southeast-1) | ~> 4.34.0 |
| <a name="provider_aws.ap-southeast-2"></a> [aws.ap-southeast-2](#provider\_aws.ap-southeast-2) | ~> 4.34.0 |
| <a name="provider_aws.ca-central-1"></a> [aws.ca-central-1](#provider\_aws.ca-central-1) | ~> 4.34.0 |
| <a name="provider_aws.eu-central-1"></a> [aws.eu-central-1](#provider\_aws.eu-central-1) | ~> 4.34.0 |
| <a name="provider_aws.eu-north-1"></a> [aws.eu-north-1](#provider\_aws.eu-north-1) | ~> 4.34.0 |
| <a name="provider_aws.eu-west-1"></a> [aws.eu-west-1](#provider\_aws.eu-west-1) | ~> 4.34.0 |
| <a name="provider_aws.eu-west-2"></a> [aws.eu-west-2](#provider\_aws.eu-west-2) | ~> 4.34.0 |
| <a name="provider_aws.eu-west-3"></a> [aws.eu-west-3](#provider\_aws.eu-west-3) | ~> 4.34.0 |
| <a name="provider_aws.sa-east-1"></a> [aws.sa-east-1](#provider\_aws.sa-east-1) | ~> 4.34.0 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider\_aws.us-east-1) | ~> 4.34.0 |
| <a name="provider_aws.us-west-1"></a> [aws.us-west-1](#provider\_aws.us-west-1) | ~> 4.34.0 |
| <a name="provider_aws.us-west-2"></a> [aws.us-west-2](#provider\_aws.us-west-2) | ~> 4.34.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_default_network_acl.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_network_acl.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_route_table.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_security_group.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_vpc.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_default_vpc.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_s3_account_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_vpc_component_tags"></a> [default\_vpc\_component\_tags](#input\_default\_vpc\_component\_tags) | (Optional) Map of default resource types to tags for each respective type.<br>Any provided tags are applied to default resources of that type in all regions.<br><br>In accordance with best practices, this module locks down the default VPC and all<br>its components to ensure all ingress/egress traffic only uses infrastructure with<br>purposefully-designed rules and configs. Default subnets must be deleted manually<br>- they cannot be removed via Terraform. This variable allows you to customize the<br>tags on these default network components. | <pre>object({<br>    default_vpc            = optional(map(string))<br>    default_route_table    = optional(map(string))<br>    default_network_acl    = optional(map(string))<br>    default_security_group = optional(map(string))<br>  })</pre> | `{}` | no |
| <a name="input_iam_account_password_policy"></a> [iam\_account\_password\_policy](#input\_iam\_account\_password\_policy) | (Optional) Config object for customizing an account's IAM password policy.<br>If not provided, by default this module will set each value to the minimum<br>required by CIS AWS Foundations Benchmark (v1.4.0). For "max\_password\_age",<br>this value is 90 days, "min\_password\_length" is 14, and the number of times<br>a password can be reused - "password\_reuse\_prevention" - is 24. Values which<br>are below those required by the CIS Benchmark Controls will result in a<br>validation error. | <pre>object({<br>    max_password_age          = optional(number, 90)<br>    min_password_length       = optional(number, 14)<br>    password_reuse_prevention = optional(number, 24)<br>  })</pre> | <pre>{<br>  "max_password_age": 90,<br>  "min_password_length": 14,<br>  "password_reuse_prevention": 24<br>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Account-Level_S3_Public_Access_Block"></a> [Account-Level\_S3\_Public\_Access\_Block](#output\_Account-Level\_S3\_Public\_Access\_Block) | Account-level S3 public access block resource. |
| <a name="output_Account_Password_Policy"></a> [Account\_Password\_Policy](#output\_Account\_Password\_Policy) | The account's password-policy resource object. |
| <a name="output_Default_VPC_Components_By_Region"></a> [Default\_VPC\_Components\_By\_Region](#output\_Default\_VPC\_Components\_By\_Region) | A map of default VPC resources by region. Included in each region is the<br>default VPC, default NACL, default route table, and default security group. |
| <a name="output_Global_Default_EBS_Encryption"></a> [Global\_Default\_EBS\_Encryption](#output\_Global\_Default\_EBS\_Encryption) | Resource that ensures all EBS volumes are encrypted by default. |

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

[cis-1.3]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.3
[cis-1.5]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.5
[cis-1.6]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.6
[cis-1.7]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.7
[cis-1.8]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.8
[cis-1.9]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.9
[cis-1.10]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.10
[fsbp-s3-1]: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-s3-1
