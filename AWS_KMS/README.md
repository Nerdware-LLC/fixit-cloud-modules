<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS KMS Key</h1>

Terraform module for defining an AWS KMS Key and related resources.

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
| [aws_kms_alias.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_replica_key.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_kms_replica_key.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_multi_region_key"></a> [is\_multi\_region\_key](#input\_is\_multi\_region\_key) | Boolean indicating whether the key is a multi-region key; defaults to<br>false if not provided. | `bool` | `false` | no |
| <a name="input_key_alias"></a> [key\_alias](#input\_key\_alias) | An alias to apply to the KMS key. | `string` | `null` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | A description of the KMS key and/or its purpose. | `string` | `null` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | A JSON-encoded KMS key policy. | `string` | n/a | yes |
| <a name="input_key_tags"></a> [key\_tags](#input\_key\_tags) | Map of tags to apply to the KMS key. | `map(any)` | `null` | no |
| <a name="input_regional_replicas"></a> [regional\_replicas](#input\_regional\_replicas) | Map of regions in which to replicate the KMS key; each region defaults to "false". | <pre>object({<br>    ap-northeast-1 = optional(bool) # Asia Pacific (Tokyo)<br>    ap-northeast-2 = optional(bool) # Asia Pacific (Seoul)<br>    ap-northeast-3 = optional(bool) # Asia Pacific (Osaka)<br>    ap-south-1     = optional(bool) # Asia Pacific (Mumbai)<br>    ap-southeast-1 = optional(bool) # Asia Pacific (Singapore)<br>    ap-southeast-2 = optional(bool) # Asia Pacific (Sydney)<br>    ca-central-1   = optional(bool) # Canada (Central)<br>    eu-north-1     = optional(bool) # Europe (Stockholm)<br>    eu-central-1   = optional(bool) # Europe (Frankfurt)<br>    eu-west-1      = optional(bool) # Europe (Ireland)<br>    eu-west-2      = optional(bool) # Europe (London)<br>    eu-west-3      = optional(bool) # Europe (Paris)<br>    sa-east-1      = optional(bool) # South America (São Paulo)<br>    us-east-1      = optional(bool) # US East (N. Virginia)<br>    us-west-1      = optional(bool) # US West (N. California)<br>    us-west-2      = optional(bool) # US West (Oregon)<br>  })</pre> | `{}` | no |
| <a name="input_should_enable_key_rotation"></a> [should\_enable\_key\_rotation](#input\_should\_enable\_key\_rotation) | Boolean indicating whether the key has the auto-rotation feature enabled;<br>defaults to true if not provided. | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_KMS_Key"></a> [KMS\_Key](#output\_KMS\_Key) | The KMS Key resource object. |
| <a name="output_KMS_Key_Alias"></a> [KMS\_Key\_Alias](#output\_KMS\_Key\_Alias) | The KMS Key Alias resource object. |
| <a name="output_Regional_Replicas"></a> [Regional\_Replicas](#output\_Regional\_Replicas) | Map of regions to KMS Key Replicas resource objects. |

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
