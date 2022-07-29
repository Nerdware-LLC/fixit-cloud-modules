<h1>Fixit Cloud ☁️ MODULE: OpenID Connect Providers</h1>

Terraform module for defining an AWS account's OpenID Connect Identity Providers for enabling key-less authentication.

The utility of OIDC IdP's is perhaps best explained with an example: adding GitHub as an OIDC IdP permits access to AWS resources within GitHub Actions without having to store long-term credentials as GitHub Secrets. In order to add an AWS OIDC Identity Provider, we need the provider's "thumbprint", as explained by [AWS docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html):

> When you create an OpenID Connect (OIDC) identity provider in IAM, you must supply a thumbprint. IAM requires the thumbprint for the top intermediate certificate authority (CA) that signed the cert used by the external identity provider (IdP). The thumbprint is a signature for the CA's certificate that was used to issue the cert for the OIDC-compatible IdP. When you create an IAM OIDC identity provider, you are trusting identities authenticated by that IdP to have access to your AWS account. By supplying the CA's certificate thumbprint, you trust any certificate issued by that CA with the same DNS name as the one registered. This eliminates the need to update trusts in each account when you renew the IdP's signing cert.

<h2>Table of Contents</h2>

- [Known Thumbprints](#known-thumbprints)
- [Script: Obtain OIDC Provider Thumbprint](#script-obtain-oidc-provider-thumbprint)
- [Useful Links](#useful-links)
- [⚙️ Module Usage](#️-module-usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)

## Known Thumbprints

| OIDC IdP | OIDC IdP URL                                | Thumbprint                               | As of          |
| :------- | :------------------------------------------ | :--------------------------------------- | :------------- |
| GitHub   | https://token.actions.githubusercontent.com | 6938FD4D98BAB03FAADB97B34396831E3780AEA1 | March 31, 2022 |

## Script: Obtain OIDC Provider Thumbprint

If you'd like to use an OIDC Identity Provider not included in the table above, this section provides you with everything you need to acquire the necessary "thumbprint" value.

1. Make an executable shell script file: `touch get_thumbprint.sh && chmod 700 get_thumbprint.sh`
2. Copy the script below into **get_thumbprint.sh**, then run it.
3. Enter the OpenID Connect Identity Provider URL when prompted. Once script execution is complete, the thumbprint will be echo'd to the console.

```bash
#!/bin/bash

# Prompt user for OIDC IdP URL
read -r -p "URL of OpenID Connect Identity Provider: " oidc_idp_url

# Append '/.well-known/openid-configuration', and rm any trailing slash.
oidc_idp_config_doc_url="${oidc_idp_url%/}/.well-known/openid-configuration"

# To obtain the IdP's CA cert info for OIDC, we need the relevant "servername" value for openssl.
# Example "jwks_uri": https://token.actions.githubusercontent.com/.well-known/jwks
cert_fqdn="$( \
	curl -s "$oidc_idp_config_doc_url" 	`# the config doc url (above) returns a json object` | \
	jq '.jwks_uri' 						`# here we extract the "jwks_uri" property` | \
	awk -F/ '{ print $3 }' 				`# the value we need is the FQDN of the "jwks_uri"` )"

# We obtain the CA certificate info via openssl, and then pass the entire output to sed to
# extract the actual cert(s) between the "BEGIN/END CERTIFICATE" indicators (inclusive).
# Note that depending on the certificate chain, 1 or more certificates may be included.
one_or_more_certs="$( \
	echo `# this echo is necessary bc otherwise openssl will wait for user to hit enter` | \
	openssl s_client -servername "$cert_fqdn" -showcerts -connect "${cert_fqdn}:443" 2>/dev/null | \
	sed -n '/BEGIN CERTIFICATE/, /END CERTIFICATE/p' )"

# We only want the cert for the top intermediate CA in the cert chain, which will always be the
# LAST one in the openssl output. To ensure we only have the one we want, we'll reverse the lines
# in the one_or_more_certs string with "tac", and break after reaching 'BEGIN CERTIFICATE'.
cert=

while IFS= read -r line; do
	cert="$( printf '%s\n%s' "$line" "$cert" )"
	[[ "$line" =~ 'BEGIN CERTIFICATE' ]] && break
done < <( tac <<< "$one_or_more_certs" )

# Now pass the certificate string to openssl to obtain the cert's fingerprint info.
# Example openssl output: "SHA1 Fingerprint=99:0F:41:93:97:2F:2B:EC:F1:2D:DE:DA:52:37:F9:C9:52:F2:0D:9E"
# Lastly, we grep the info to get just the actual fingerprint, then rm the colons and print to stdout.
echo "$cert" | openssl x509 -fingerprint -noout | grep -oP "(?<=Fingerprint=).*$" | tr -d ':'
```

## Useful Links

- [AWS Docs: Creating OIDC Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub Docs: Configuring OpenID Connect in AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-permissions-settings)
- [GitHub Action: configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-start -->

---

## ⚙️ Module Usage

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
| [aws_iam_openid_connect_provider.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.OIDC_IdP_Roles_map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_openID_connect_providers"></a> [openID\_connect\_providers](#input\_openID\_connect\_providers) | Map of OpenID Connect (OIDC) Identity Provider config objects. The top-level map keys<br>should be human-readable IdP names - they're attached to the "OpenID\_Connect\_Providers"<br>output object to simplify finding any resource outputs you might need. For "built-in"<br>identity providers that don't require an IdP to be created within IAM (Amazon Cognito,<br>Google, and Facebook), exclude the optional "iam\_oidc\_idp\_config" property. Each OIDC<br>IdP must be associated with an IAM Role, which is configurable via the "iam\_role"<br>property object. The "iam\_role.assume\_role\_policy\_conditions" property must be a valid<br>JSON-encoded string which yields valid AssumeRole Policy conditions when provided to<br>the jsondecode Terraform fn. For "built-in" IdP's, the AssumeRole Policy "Principal"<br>will be set to the value of the "iam\_role.built\_in\_idp\_principal\_url" property, which<br>must be set to the URL the built-in IdP uses for OIDC federation. For IAM IdP's that<br>aren't "built-in", the "Principal" field will be populated with the IdP's ARN and<br>therefore should not be included in the argument. For more info on OIDC IdP's, please<br>refer to the AWS documentation regarding OpenID Connect Identity Providers:<br>https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html. | <pre>map(object({<br>    iam_oidc_idp_config = optional(object({<br>      url             = string<br>      client_id_list  = list(string)<br>      thumbprint_list = list(string)<br>      tags            = optional(map(string))<br>    }))<br>    iam_role = object({<br>      name                          = string<br>      description                   = optional(string)<br>      tags                          = optional(map(string))<br>      built_in_idp_principal_url    = optional(string)<br>      assume_role_policy_conditions = string<br>    })<br>  }))</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_OpenID_Connect_Provider_Roles"></a> [OpenID\_Connect\_Provider\_Roles](#output\_OpenID\_Connect\_Provider\_Roles) | Map of OpenID Connect (OIDC) Identity Provider Role resource objects. |
| <a name="output_OpenID_Connect_Providers"></a> [OpenID\_Connect\_Providers](#output\_OpenID\_Connect\_Providers) | Map of IAM OpenID Connect (OIDC) Identity Provider resource objects. |

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
