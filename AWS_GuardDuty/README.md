<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS GuardDuty</h1>

Terraform module for managing GuardDuty resources.

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

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | 1.2.7     |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.11.0 |

### Providers

| Name                                                                                          | Version   |
| --------------------------------------------------------------------------------------------- | --------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                                              | ~> 4.11.0 |
| <a name="provider_aws.ap-northeast-1"></a> [aws.ap-northeast-1](#provider_aws.ap-northeast-1) | ~> 4.11.0 |
| <a name="provider_aws.ap-northeast-2"></a> [aws.ap-northeast-2](#provider_aws.ap-northeast-2) | ~> 4.11.0 |
| <a name="provider_aws.ap-northeast-3"></a> [aws.ap-northeast-3](#provider_aws.ap-northeast-3) | ~> 4.11.0 |
| <a name="provider_aws.ap-south-1"></a> [aws.ap-south-1](#provider_aws.ap-south-1)             | ~> 4.11.0 |
| <a name="provider_aws.ap-southeast-1"></a> [aws.ap-southeast-1](#provider_aws.ap-southeast-1) | ~> 4.11.0 |
| <a name="provider_aws.ap-southeast-2"></a> [aws.ap-southeast-2](#provider_aws.ap-southeast-2) | ~> 4.11.0 |
| <a name="provider_aws.ca-central-1"></a> [aws.ca-central-1](#provider_aws.ca-central-1)       | ~> 4.11.0 |
| <a name="provider_aws.eu-central-1"></a> [aws.eu-central-1](#provider_aws.eu-central-1)       | ~> 4.11.0 |
| <a name="provider_aws.eu-north-1"></a> [aws.eu-north-1](#provider_aws.eu-north-1)             | ~> 4.11.0 |
| <a name="provider_aws.eu-west-1"></a> [aws.eu-west-1](#provider_aws.eu-west-1)                | ~> 4.11.0 |
| <a name="provider_aws.eu-west-2"></a> [aws.eu-west-2](#provider_aws.eu-west-2)                | ~> 4.11.0 |
| <a name="provider_aws.eu-west-3"></a> [aws.eu-west-3](#provider_aws.eu-west-3)                | ~> 4.11.0 |
| <a name="provider_aws.sa-east-1"></a> [aws.sa-east-1](#provider_aws.sa-east-1)                | ~> 4.11.0 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider_aws.us-east-1)                | ~> 4.11.0 |
| <a name="provider_aws.us-west-1"></a> [aws.us-west-1](#provider_aws.us-west-1)                | ~> 4.11.0 |
| <a name="provider_aws.us-west-2"></a> [aws.us-west-2](#provider_aws.us-west-2)                | ~> 4.11.0 |

### Modules

No modules.

### Resources

| Name                                                                                                                                                                        | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_guardduty_detector.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                     | resource    |
| [aws_guardduty_detector.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                     | resource    |
| [aws_guardduty_detector.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                     | resource    |
| [aws_guardduty_detector.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                         | resource    |
| [aws_guardduty_detector.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                     | resource    |
| [aws_guardduty_detector.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                     | resource    |
| [aws_guardduty_detector.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                       | resource    |
| [aws_guardduty_detector.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                       | resource    |
| [aws_guardduty_detector.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                         | resource    |
| [aws_guardduty_detector.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                          | resource    |
| [aws_guardduty_detector.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                          | resource    |
| [aws_guardduty_detector.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                          | resource    |
| [aws_guardduty_detector.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                          | resource    |
| [aws_guardduty_detector.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                          | resource    |
| [aws_guardduty_detector.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                          | resource    |
| [aws_guardduty_detector.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                          | resource    |
| [aws_guardduty_detector.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                          | resource    |
| [aws_guardduty_organization_admin_account.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource    |
| [aws_guardduty_organization_admin_account.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource    |
| [aws_guardduty_organization_admin_account.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource    |
| [aws_guardduty_organization_admin_account.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)     | resource    |
| [aws_guardduty_organization_admin_account.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource    |
| [aws_guardduty_organization_admin_account.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource    |
| [aws_guardduty_organization_admin_account.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)   | resource    |
| [aws_guardduty_organization_admin_account.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)   | resource    |
| [aws_guardduty_organization_admin_account.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)     | resource    |
| [aws_guardduty_organization_admin_account.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)      | resource    |
| [aws_guardduty_organization_admin_account.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)      | resource    |
| [aws_guardduty_organization_admin_account.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)      | resource    |
| [aws_guardduty_organization_admin_account.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)      | resource    |
| [aws_guardduty_organization_admin_account.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)      | resource    |
| [aws_guardduty_organization_admin_account.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)      | resource    |
| [aws_guardduty_organization_admin_account.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)      | resource    |
| [aws_guardduty_organization_admin_account.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account)      | resource    |
| [aws_guardduty_organization_configuration.ap-northeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource    |
| [aws_guardduty_organization_configuration.ap-northeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource    |
| [aws_guardduty_organization_configuration.ap-northeast-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource    |
| [aws_guardduty_organization_configuration.ap-south-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)     | resource    |
| [aws_guardduty_organization_configuration.ap-southeast-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource    |
| [aws_guardduty_organization_configuration.ap-southeast-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource    |
| [aws_guardduty_organization_configuration.ca-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)   | resource    |
| [aws_guardduty_organization_configuration.eu-central-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)   | resource    |
| [aws_guardduty_organization_configuration.eu-north-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)     | resource    |
| [aws_guardduty_organization_configuration.eu-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)      | resource    |
| [aws_guardduty_organization_configuration.eu-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)      | resource    |
| [aws_guardduty_organization_configuration.eu-west-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)      | resource    |
| [aws_guardduty_organization_configuration.sa-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)      | resource    |
| [aws_guardduty_organization_configuration.us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)      | resource    |
| [aws_guardduty_organization_configuration.us-east-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)      | resource    |
| [aws_guardduty_organization_configuration.us-west-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)      | resource    |
| [aws_guardduty_organization_configuration.us-west-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration)      | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                               | data source |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization)                            | data source |

### Inputs

| Name                                                                                                                  | Description                                                                                                                              | Type          | Default       | Required |
| --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ------------- | :------: |
| <a name="input_detector_tags"></a> [detector_tags](#input_detector_tags)                                              | The tags of the GuardDuty Detector.                                                                                                      | `map(string)` | `null`        |    no    |
| <a name="input_finding_publishing_frequency"></a> [finding_publishing_frequency](#input_finding_publishing_frequency) | How often the GuardDuty Detector should publish findings. Allowed<br>values are "FIFTEEN_MINUTES", "ONE_HOUR", or "SIX_HOURS" (default). | `string`      | `"SIX_HOURS"` |    no    |
| <a name="input_guardduty_admin_account_id"></a> [guardduty_admin_account_id](#input_guardduty_admin_account_id)       | The ID of the account designated as the delegated administrator for<br>the GuardDuty service in all regions.                             | `string`      | n/a           |   yes    |

### Outputs

| Name                                                                                                                                               | Description                                                            |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| <a name="output_GuardDuty_Detectors_BY_REGION"></a> [GuardDuty_Detectors_BY_REGION](#output_GuardDuty_Detectors_BY_REGION)                         | A map of GuardDuty Detector resources, organized by region.            |
| <a name="output_GuardDuty_Org_Admin_Account_BY_REGION"></a> [GuardDuty_Org_Admin_Account_BY_REGION](#output_GuardDuty_Org_Admin_Account_BY_REGION) | A map of GuardDuty Delegated Admin resources, organized by region.     |
| <a name="output_GuardDuty_Org_Config_BY_REGION"></a> [GuardDuty_Org_Config_BY_REGION](#output_GuardDuty_Org_Config_BY_REGION)                      | A map of GuardDuty Organization Config resources, organized by region. |

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
