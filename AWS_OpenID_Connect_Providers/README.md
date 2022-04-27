# Fixit Cloud ☁️ MODULE: OpenID Connect Providers

Terraform module for defining an AWS account's OpenID Connect Identity Providers.

### Useful Links

- [GitHub Docs: Configuring OpenID Connect in AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-permissions-settings)
- [GitHub Action: configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [AWS Docs: Creating OIDC Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

---

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
| [aws_iam_openid_connect_provider.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.OIDC_IdP_Roles_map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_openID_connect_providers"></a> [openID\_connect\_providers](#input\_openID\_connect\_providers) | Map of OpenID Connect (OIDC) Identity Provider config objects. The top-level map keys<br>should be human-readable IdP names - they're attached to the "OpenID\_Connect\_Providers"<br>output object to simplify finding any resource outputs you might need. For "built-in"<br>identity providers that don't require an IdP to be created within IAM (Amazon Cognito,<br>Google, and Facebook), exclude the optional "iam\_oidc\_idp\_config" property. Each OIDC<br>IdP must be associated with an IAM Role, which is configurable via the "iam\_role"<br>property object. The "iam\_role.assume\_role\_policy\_conditions" property must be a valid<br>JSON-encoded string which yields valid AssumeRole Policy conditions when provided to<br>the jsondecode Terraform fn. For "built-in" IdP's, the AssumeRole Policy "Principal"<br>will be set to the value of the "iam\_role.built\_in\_idp\_principal\_url" property, which<br>must be set to the URL the built-in IdP uses for OIDC federation. For IAM IdP's that<br>aren't "built-in", the "Principal" field will be populated with the IdP's ARN and<br>therefore should not be included in the argument. For more info on OIDC IdP's, please<br>refer to the AWS documentation regarding OpenID Connect Identity Providers:<br>https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html. | <pre>map(object({<br>    iam_oidc_idp_config = optional(object({<br>      url             = string<br>      client_id_list  = list(string)<br>      thumbprint_list = list(string)<br>      tags            = optional(map(string))<br>    }))<br>    iam_role = object({<br>      name                          = string<br>      description                   = optional(string)<br>      tags                          = optional(map(string))<br>      built_in_idp_principal_url    = optional(string)<br>      assume_role_policy_conditions = string<br>    })<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_OpenID_Connect_Provider_Roles"></a> [OpenID\_Connect\_Provider\_Roles](#output\_OpenID\_Connect\_Provider\_Roles) | Map of OpenID Connect (OIDC) Identity Provider Role resource objects. |
| <a name="output_OpenID_Connect_Providers"></a> [OpenID\_Connect\_Providers](#output\_OpenID\_Connect\_Providers) | Map of IAM OpenID Connect (OIDC) Identity Provider resource objects. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->