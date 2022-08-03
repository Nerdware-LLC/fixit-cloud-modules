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

### Usage Examples

- Terragrunt: [view Terragrunt usage exmaple](examples/terragrunt.hcl)
- Terraform: &nbsp;[view vanilla Terraform usage exmaple](examples/terraform.tf)

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.6 |
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
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_s3_account_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_vpc_component_tags"></a> [default\_vpc\_component\_tags](#input\_default\_vpc\_component\_tags) | In accordance with best practices, this module locks down the default VPC and all<br>its components to ensure all ingress/egress traffic only uses infrastructure with<br>purposefully-designed rules and configs. Default subnets must be deleted manually<br>- they cannot be removed via Terraform. This variable allows you to customize the<br>tags on these "default" network components; defaults will be used if not provided. | <pre>object({<br>    default_vpc            = optional(map(string))<br>    default_route_table    = optional(map(string))<br>    default_network_acl    = optional(map(string))<br>    default_security_group = optional(map(string))<br>  })</pre> | <pre>{<br>  "default_network_acl": null,<br>  "default_route_table": null,<br>  "default_security_group": null,<br>  "default_vpc": null<br>}</pre> | no |
| <a name="input_s3_public_access_blocks"></a> [s3\_public\_access\_blocks](#input\_s3\_public\_access\_blocks) | Config object for account-level rules regarding S3 public access.<br>By default, all S3 buckets/objects should be strictly PRIVATE. Only<br>provide this variable with an override set to "false" if you know<br>what you're doing and it's absolutely necessary. | <pre>object({<br>    block_public_acls       = optional(bool)<br>    block_public_policy     = optional(bool)<br>    ignore_public_acls      = optional(bool)<br>    restrict_public_buckets = optional(bool)<br>  })</pre> | <pre>{<br>  "block_public_acls": true,<br>  "block_public_policy": true,<br>  "ignore_public_acls": true,<br>  "restrict_public_buckets": true<br>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Account-Level_S3_Public_Access_Block"></a> [Account-Level\_S3\_Public\_Access\_Block](#output\_Account-Level\_S3\_Public\_Access\_Block) | Account-level S3 public access block resource. |
| <a name="output_Account_Password_Policy"></a> [Account\_Password\_Policy](#output\_Account\_Password\_Policy) | The account's password-policy resource object. |
| <a name="output_Default_Network_ACL"></a> [Default\_Network\_ACL](#output\_Default\_Network\_ACL) | The default VPC's default network ACL. |
| <a name="output_Default_RouteTable"></a> [Default\_RouteTable](#output\_Default\_RouteTable) | The default VPC's default route table. |
| <a name="output_Default_SecurityGroup"></a> [Default\_SecurityGroup](#output\_Default\_SecurityGroup) | The default VPC's default security group. |
| <a name="output_Default_VPC"></a> [Default\_VPC](#output\_Default\_VPC) | The account's default VPC resource. |
| <a name="output_Global_Default_EBS_Encryption"></a> [Global\_Default\_EBS\_Encryption](#output\_Global\_Default\_EBS\_Encryption) | Resource that ensures all EBS volumes are encrypted by default. |

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
