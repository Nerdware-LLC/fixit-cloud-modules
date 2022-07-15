<h1>Fixit Cloud ☁️ MODULE: AWS KMS Key</h1>

Terraform module for defining an AWS KMS Key and related resources.

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

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.5 |
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
| [aws_kms_alias.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_multi_region_key"></a> [is\_multi\_region\_key](#input\_is\_multi\_region\_key) | Boolean indicating whether the key is a multi-region key; defaults to<br>false if not provided. | `bool` | `false` | no |
| <a name="input_key_alias"></a> [key\_alias](#input\_key\_alias) | An alias to apply to the KMS key. | `string` | `null` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | A description of the KMS key and/or its purpose. | `string` | `null` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | A JSON-encoded KMS key policy. | `string` | n/a | yes |
| <a name="input_key_tags"></a> [key\_tags](#input\_key\_tags) | Map of tags to apply to the KMS key. | `map(any)` | `null` | no |
| <a name="input_should_enable_key_rotation"></a> [should\_enable\_key\_rotation](#input\_should\_enable\_key\_rotation) | Boolean indicating whether the key has the auto-rotation feature enabled;<br>defaults to true if not provided. | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_KMS_Key"></a> [KMS\_Key](#output\_KMS\_Key) | The KMS Key resource object. |
| <a name="output_KMS_Key_Alias"></a> [KMS\_Key\_Alias](#output\_KMS\_Key\_Alias) | The KMS Key Alias resource object. |

---

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center" style="margin-top:30px;">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [trevor@nerdware.cloud](mailto:trevor@nerdware.cloud)

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
  <a href="mailto:trevor@nerdware.cloud">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/email_icon_circle.svg" height="40" />
  </a>
  <br><br>

  <a href="https://daremightythings.co/">
    <strong><i>Dare Mighty Things.</i></strong>
  </a>

</div>
<!-- prettier-ignore-end -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
