<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS ECR</h2>

Terraform module for managing an AWS ECR Registry and its Repositories.

</div>

<h2>Table of Contents</h2>

- [Useful Links](#useful-links)
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

## Useful Links

- [ECR Repo Image Scanning](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html)
- [ECR Enhanced Registry Scanning: Repo Filter Syntax](https://docs.aws.amazon.com/AmazonECR/latest/APIReference/API_ScanningRepositoryFilter.html)

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
| [aws_ecr_registry_policy.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_policy) | resource |
| [aws_ecr_registry_scanning_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_scanning_configuration) | resource |
| [aws_ecr_repository.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_policy_document.Repo_Policies_Map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_registry_policy_json"></a> [registry\_policy\_json](#input\_registry\_policy\_json) | (Optional) A JSON-encoded ECR Registry Policy. Registry policies set permissions<br>at the registry level for "ecr:ReplicateImage", "ecr:BatchImportUpstreamImage",<br>and "ecr:CreateRepository". | `string` | `null` | no |
| <a name="input_registry_scanning_config"></a> [registry\_scanning\_config](#input\_registry\_scanning\_config) | (Optional) Config object for Enhanced image scanning. By default, all<br>repos will be configured with Basic scanning. If "scan\_type" is set to<br>"ENHANCED", you can provide a map of "repo\_scan\_rules", in which regex<br>strings can be supplied as keys to target one or more repos with a<br>scan-frequency setting, which can be one of "MANUAL", "SCAN\_ON\_PUSH",<br>or "CONTINUOUS\_SCAN". | <pre>object({<br>    scan_type       = string<br>    repo_scan_rules = optional(map(string))<br>  })</pre> | <pre>{<br>  "repo_scan_rules": null,<br>  "scan_type": "BASIC"<br>}</pre> | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Map of ECR Repository names to config objects. For more fine-grained control<br>over a repo's SSE, an AWS KMS key can be provided - otherwise the ECR default<br>AES256 encryption will be used instead. "should\_image\_tags\_be\_immutabile"<br>defaults to false if not provided.<br>Use any of the provided "policy\_config" properties to set commonly-used sets of<br>permissions; for example, principals you provide in "allow\_push\_and\_pull\_images"<br>will be granted all the necessary Allow-permissions necessary to push and pull<br>images to and from the repo. Alternatively/additionally, any valid IAM policy<br>state can be provided as a JSON array in "custom\_statements\_json", and the<br>provided statements will be merged into any others you've configured. | <pre>map(<br>    # map keys: ECR repo names<br>    object({<br>      should_image_tags_be_immutabile = optional(bool)<br>      sse_config = optional(object({<br>        type        = string<br>        kms_key_arn = optional(string)<br>      }))<br>      tags = optional(map(string))<br>      policy_config = object({<br>        allow_push_and_pull_images = optional(object({<br>          principals = object({<br>            type        = string<br>            identifiers = list(string)<br>          })<br>          conditions = optional(map(<br>            # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")<br>            object({<br>              key    = string<br>              values = list(string)<br>            })<br>          ))<br>        }))<br>        allow_codebuild_access = optional(object({<br>          codebuild_project_source_arns = list(string)<br>          codebuild_account_ids         = list(string)<br>          custom_conditions = optional(map(<br>            # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")<br>            object({<br>              key    = string<br>              values = list(string)<br>            })<br>          ))<br>        }))<br>        custom_statements_json = optional(string)<br>      })<br>    })<br>  )</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Registry_Policy"></a> [Registry\_Policy](#output\_Registry\_Policy) | The ECR Registry Policy resource object. |
| <a name="output_Registry_Scanning_Config"></a> [Registry\_Scanning\_Config](#output\_Registry\_Scanning\_Config) | The ECR Registry Scanning Config resource object. |
| <a name="output_Repositories"></a> [Repositories](#output\_Repositories) | Map of ECR Repository resource objects. |
| <a name="output_Repository_Policies"></a> [Repository\_Policies](#output\_Repository\_Policies) | Map of ECR Repo Policy resource objects. |

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
