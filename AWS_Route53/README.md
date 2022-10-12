<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS Route53</h2>

Terraform module for defining AWS Route53 resources.

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

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_route53_delegation_set.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_delegation_set) | resource |
| [aws_route53_record.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delegation_sets"></a> [delegation\_sets](#input\_delegation\_sets) | (Optional) List of delegation set names. | `list(string)` | `[]` | no |
| <a name="input_hosted_zones"></a> [hosted\_zones](#input\_hosted\_zones) | Map of domain names to Route53 hosted zone config objects. To create<br>a private hosted zone, you must provide one of either "vpc\_association"<br>or "delegation\_set". Unless "should\_setup\_ns\_records" is set to false,<br>each hosted zones name servers will be setup as NS record resources. | <pre>map(<br>    # map keys: domain names<br>    object({<br>      description       = optional(string, "Managed by Terraform")<br>      delegation_set_id = optional(string)<br>      vpc_association = optional(object({<br>        vpc_id     = string<br>        vpc_region = optional(string)<br>      }))<br>      should_force_destroy    = optional(bool, false)<br>      should_setup_ns_records = optional(bool, true)<br>      tags                    = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_records"></a> [records](#input\_records) | (Optional) List of DNS resource record config objects. "hosted\_zone\_domain"<br>values must be present as keys in the `var.hosted_zones` input object. "type"<br>must be one of A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV or<br>TXT. One of either "non\_alias\_records" or "alias\_record" must be provided.<br>Only 1 type of routing policy may be provided. | <pre>list(<br>    object({<br>      hosted_zone_domain = string # must be a key in var.hosted_zones<br>      name               = string # e.g., "foo.example.com"<br>      type               = string<br>      allow_overwrite    = optional(bool, true)<br>      set_identifier     = optional(string)<br>      health_check_id    = optional(string)<br>      non_alias_records = optional(object({<br>        ttl    = number<br>        values = list(string)<br>      }))<br>      alias_record = optional(object({<br>        dns_domain_name        = string<br>        zone_id                = string<br>        evaluate_target_health = optional(bool, true)<br>      }))<br>      failover_routing_policy = optional(object({<br>        type = string # PRIMARY or SECONDARY<br>      }))<br>      geolocation_routing_policy = optional(object({<br>        continent   = optional(string)<br>        country     = optional(string)<br>        subdivision = optional(string)<br>      }))<br>      latency_routing_policy = optional(object({<br>        aws_region = string<br>      }))<br>      weighted_routing_policy = optional(object({<br>        weight = number<br>      }))<br>      multivalue_routing_policy = optional(bool, false)<br>    })<br>  )</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_DelegationSets"></a> [DelegationSets](#output\_DelegationSets) | Map of Route53 delegation set resource objects. |
| <a name="output_HostedZones"></a> [HostedZones](#output\_HostedZones) | Map of Route53 hosted zone resource objects. |
| <a name="output_Records"></a> [Records](#output\_Records) | Map of Route53 record resource objects. |

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
