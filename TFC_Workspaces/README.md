<h1>Fixit Cloud ☁️ MODULE: TFC Workspaces</h1>

Terraform module for managing Terraform Cloud Workspaces.

<h2>Table of Contents</h2>

- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [License](#license)
- [Contact](#contact)

#### Docs

[TF Cloud/Enterprise Provider](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs)
[TFC Organization Data Source](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/organization)
[TFC Workspace Resource](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace)
[TFC Workspace Variable Resource](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable)

---

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.4 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~> 0.28.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | ~> 0.28.1 |

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
| <a name="input_workspaces"></a> [workspaces](#input\_workspaces) | Map of TF Cloud Workspace names to corresponding workspace config objects.<br>The optional boolean properties all default to false. If "terraform\_version"<br>is provided, the specified semver will be used to constrain the versions of<br>TF permitted to run within the workspace. Use the "remote\_execution" property<br>to configure workspace plan/apply operations to run remotely on TFC VMs instead<br>of your local machine. With remote execution, you can also setup the VCS-driven<br>workflow via the "vcs\_config" property, which will cause apply operations to be<br>initiated by new changes to "vcs\_repo.branch" (default: "main") rather than via<br>manual CLI/API calls. Note that enabling the VCS-driven workflow will DISABLE<br>the ability to trigger runs via the CLI/API, which at this time can only be<br>reversed by manually removing the repository from the workspace via the TF<br>Cloud console. Instructions for obtaining a "vcs\_oauth\_token\_id" for GitHub<br>can be found at https://www.terraform.io/cloud-docs/vcs/github. | <pre>map(object({<br>    description             = optional(string)<br>    tag_names               = optional(list(string))<br>    working_directory       = optional(string)<br>    terraform_version       = optional(string)<br>    allow_destroy_plans     = optional(bool)<br>    allow_speculative_plans = optional(bool)<br>    should_queue_all_runs   = optional(bool)<br>    remote_execution = optional(object({<br>      variables = optional(list(object({<br>        key          = string<br>        value        = string<br>        description  = optional(string)<br>        is_env_var   = optional(bool)<br>        is_value_hcl = optional(bool)<br>        is_sensitive = optional(bool)<br>      })))<br>      vcs_config = optional(object({<br>        identifier         = string # e.g., Nerdware-LLC/fixit-cloud-modules<br>        vcs_oauth_token_id = string<br>        branch             = optional(string) # default "main"<br>        ingress_submodules = optional(bool)   # default false<br>      }))<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Organization"></a> [Organization](#output\_Organization) | The TFC Organization data-block attributes. |
| <a name="output_Workspace_Variables"></a> [Workspace\_Variables](#output\_Workspace\_Variables) | Map of TFC Workspace Variable resources (sensitive). |
| <a name="output_Workspaces"></a> [Workspaces](#output\_Workspaces) | Map of TFC Workspace resource objects. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

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
