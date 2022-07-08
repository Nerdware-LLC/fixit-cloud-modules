<h1>Fixit Cloud ☁️ MODULE: OpenID Connect Providers</h1>

Terraform module for defining an AWS account's OpenID Connect Identity Providers.

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

### Useful Links

- [GitHub Docs: Configuring OpenID Connect in AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-permissions-settings)
- [GitHub Action: configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [AWS Docs: Creating OIDC Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-start -->

---

## ⚙️ Module Usage

### Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | 1.2.2     |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.11.0 |

### Providers

| Name                                             | Version   |
| ------------------------------------------------ | --------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 4.11.0 |

### Modules

No modules.

### Resources

| Name                                                                                                                                           | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_iam_openid_connect_provider.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.OIDC_IdP_Roles_map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                        | resource |

### Inputs

| Name                                                                                                      | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Type                                                                                                                                                                                                                                                                                                                                                                                                                         | Default | Required |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_openID_connect_providers"></a> [openID_connect_providers](#input_openID_connect_providers) | Map of OpenID Connect (OIDC) Identity Provider config objects. The top-level map keys<br>should be human-readable IdP names - they're attached to the "OpenID_Connect_Providers"<br>output object to simplify finding any resource outputs you might need. For "built-in"<br>identity providers that don't require an IdP to be created within IAM (Amazon Cognito,<br>Google, and Facebook), exclude the optional "iam_oidc_idp_config" property. Each OIDC<br>IdP must be associated with an IAM Role, which is configurable via the "iam_role"<br>property object. The "iam_role.assume_role_policy_conditions" property must be a valid<br>JSON-encoded string which yields valid AssumeRole Policy conditions when provided to<br>the jsondecode Terraform fn. For "built-in" IdP's, the AssumeRole Policy "Principal"<br>will be set to the value of the "iam_role.built_in_idp_principal_url" property, which<br>must be set to the URL the built-in IdP uses for OIDC federation. For IAM IdP's that<br>aren't "built-in", the "Principal" field will be populated with the IdP's ARN and<br>therefore should not be included in the argument. For more info on OIDC IdP's, please<br>refer to the AWS documentation regarding OpenID Connect Identity Providers:<br>https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html. | <pre>map(object({<br> iam_oidc_idp_config = optional(object({<br> url = string<br> client_id_list = list(string)<br> thumbprint_list = list(string)<br> tags = optional(map(string))<br> }))<br> iam_role = object({<br> name = string<br> description = optional(string)<br> tags = optional(map(string))<br> built_in_idp_principal_url = optional(string)<br> assume_role_policy_conditions = string<br> })<br> }))</pre> | n/a     |   yes    |

### Outputs

| Name                                                                                                                       | Description                                                           |
| -------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| <a name="output_OpenID_Connect_Provider_Roles"></a> [OpenID_Connect_Provider_Roles](#output_OpenID_Connect_Provider_Roles) | Map of OpenID Connect (OIDC) Identity Provider Role resource objects. |
| <a name="output_OpenID_Connect_Providers"></a> [OpenID_Connect_Providers](#output_OpenID_Connect_Providers)                | Map of IAM OpenID Connect (OIDC) Identity Provider resource objects.  |

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
