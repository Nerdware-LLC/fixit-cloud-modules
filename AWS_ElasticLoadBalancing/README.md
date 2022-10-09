<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS Elastic Load Balancing</h1>

Terraform module for defining AWS ALB, NLB, and/or GWLB resources.

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
| [aws_lb.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | Map of load balancer names to config objects.<br>"type" must be either "application", "network", or "gateway".<br>"is\_internal" and "is\_dualstack" both default to false if not provided.<br>"alb\_should\_enable\_http2" defaults to true, and is only applicable to Application LBs.<br>"nlb\_enable\_cross\_zone\_load\_balancing" defaults to false, and is only applicable to Network LBs.<br>"enable\_deletion\_protection" defaults to true.<br>"desync\_mitigation\_mode" can be one of "monitor", "strictest", or "defensive" (default).<br>"idle\_timeout\_seconds" defaults to 60. | <pre>map(<br>    # map keys: load balancer names<br>    object({<br>      type         = string<br>      is_internal  = optional(bool) # default: false<br>      is_dualstack = optional(bool) # default: false<br>      subnets = optional(map(<br>        # map keys: subnet names<br>        object({<br>          subnet_id                = string<br>          elastic_ip_allocation_id = optional(string)<br>          private_ipv4_address     = optional(string)<br>          ipv6_address             = optional(string)<br>        })<br>      ))<br>      alb_security_group_ids               = optional(list(string))<br>      alb_should_enable_http2              = optional(bool) # default: true<br>      nlb_enable_cross_zone_load_balancing = optional(bool)<br>      enable_deletion_protection           = optional(bool)   # default: true<br>      desync_mitigation_mode               = optional(string) # default: "defensive"<br>      idle_timeout_seconds                 = optional(number)<br>      access_logging = optional(object({<br>        s3_bucket_name = string<br>        log_prefix     = optional(string)<br>        is_enabled     = optional(bool) # default: true<br>      }))<br>      tags = optional(map(string))<br><br>      # TODO var.listeners, or "listeners" here<br>    })<br>  )</pre> | n/a | yes |

### Outputs

No outputs.

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
