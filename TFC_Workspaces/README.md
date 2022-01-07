# Fixit Cloud ☁️ MODULE: TFC Workspaces

Terraform module for managing Terraform Cloud workspaces and variables.

#### Docs

[TF Cloud/Enterprise Provider](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs)
[TFC Organization Data Source](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/organization)
[TFC Workspace Resource](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace)
[TFC Workspace Variable Resource](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable)

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~> 0.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | ~> 0.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tfe_variable.map](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_workspace.map](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) | resource |
| [tfe_organization.Nerdware](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_fixit-cloud-modules-repo_github-oauth-token-id"></a> [fixit-cloud-modules-repo\_github-oauth-token-id](#input\_fixit-cloud-modules-repo\_github-oauth-token-id) | This variable value is stored in and provided by TF Cloud, and<br>should *NOT* be provided as an input variable. This declaration<br>exists solely to silence CLI warnings/errors. | `string` | n/a | yes |
| <a name="input_variables_for_all_workspaces"></a> [variables\_for\_all\_workspaces](#input\_variables\_for\_all\_workspaces) | If some variables need to be included in ALL workspaces, you can<br>list them here just once instead of repeating them throughout the<br>"workspaces" variable. | <pre>list(object({<br>    key          = string<br>    value        = string<br>    description  = optional(string)<br>    is_env_var   = optional(bool)<br>    is_value_hcl = optional(bool)<br>    is_sensitive = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_workspaces"></a> [workspaces](#input\_workspaces) | A map of TF Cloud Workspace config objects. The "is\_vcs\_connected"<br>param, if "true", will connect the workspace to the fixit-cloud-modules<br>repo. Note that enabling the VCS-driven workflow will DISABLE the<br>ability to trigger runs via the CLI/API, which at this time can only be<br>reversed by manually removing the repository from the workspace via the<br>Terraform Cloud console. The "modules\_repo\_dir" param should be the name<br>of a dir in the Nerdware fixit-cloud-modules repository (e.g.,<br>"Terraform\_Cloud"). All optional boolean values default to "false". | <pre>map(object({<br>    description                 = optional(string)<br>    modules_repo_dir            = optional(string)<br>    is_vcs_connected            = optional(bool)<br>    is_destroyable              = optional(bool)<br>    is_speculative_plan_enabled = optional(bool)<br>    variables = optional(list(object({<br>      key          = string<br>      value        = string<br>      description  = optional(string)<br>      is_env_var   = optional(bool)<br>      is_value_hcl = optional(bool)<br>      is_sensitive = optional(bool)<br>    })))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Organization"></a> [Organization](#output\_Organization) | n/a |
| <a name="output_Workspaces"></a> [Workspaces](#output\_Workspaces) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

---

## License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

## Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - T.AndersonProperty@gmail.com

[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[linkedin-url]: https://www.linkedin.com/in/trevor-anderson-3a3b0392/
[linkedin-shield]: https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white
