<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS Elastic Load Balancers</h1>

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
| [aws_lb.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_listeners"></a> [listeners](#input\_listeners) | Map of arbitrary LB listener names to config objects. LB listeners do not<br>have names in AWS, but the provided names are used internally by this module<br>to properly identify listeners and their associated parameters.<br>"load\_balancer\_name" must exist as a key within var.load\_balancers.<br><br>Within "actions", "type" must be one of "forward", "redirect", or "fixed-response".<br>Each listener must have at least 1 action where "is\_default\_action" is true.<br>Support for auth-related types "authenticate-cognito" and "authenticate-oidc" will<br>be added in the future. Each default action object is configured using the property<br>which matches its type. Default actions can not have "conditions". | <pre>map(<br>    # map keys: arbitrary LB listener "names"<br>    object({<br>      load_balancer_name = string<br>      port               = optional(number)<br>      protocol           = optional(string)<br>      certificate_arn    = optional(string)<br>      ssl_policy         = optional(string) # Required for protocols HTTPS or TLS<br>      tls_alpn_policy    = optional(string)<br>      tags               = optional(map(string))<br>      actions = list(object({<br>        # TODO Add support for listeners of type "authenticate-oidc" and "authenticate-cognito"<br>        type              = string # "forward", "redirect", or "fixed-response"<br>        is_default_action = optional(bool, false)<br>        priority          = optional(number) # Required if >1 actions<br>        forward = optional(object({<br>          target_groups = list(object({<br>            name   = string           # name must match a key in var.target_groups<br>            weight = optional(number) # 0 to 999<br>          }))<br>          stickiness = optional(object({<br>            duration = number # 1 - 604800 seconds (7 days)<br>            enabled  = optional(bool, false)<br>          }))<br>        }))<br>        redirect = optional(object({<br>          status_code = string # "HTTP_301" (permanent), or "HTTP_302" (temporary)<br>          host        = optional(string)<br>          port        = optional(string)<br>          path        = optional(string)<br>          protocol    = optional(string)<br>          query       = optional(string)<br>        }))<br>        fixed_response = optional(object({<br>          content_type = string # "text/plain", "text/css", "text/html", "application/javascript", or "application/json"<br>          message_body = optional(string)<br>          status_code  = optional(string)<br>        }))<br>        # Conditions only apply to non-default actions<br>        conditions = optional(list(object({<br>          source_ips           = optional(list(string))<br>          host_header_values   = optional(list(string))<br>          http_request_methods = optional(list(string))<br>          path_patterns        = optional(list(string))<br>          http_headers = optional(list(object({<br>            http_header_name = string<br>            values           = list(string)<br>          })))<br>          query_strings = optional(list(object({<br>            key   = optional(string)<br>            value = string<br>          })))<br>        })))<br>      }))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | Map of load balancer names to config objects. "type" must be either<br>"application", "network", or "gateway". "alb\_should\_enable\_http2" is<br>only applicable to Application LBs. "nlb\_enable\_cross\_zone\_load\_balancing"<br>is only applicable to Network LBs. | <pre>map(<br>    # map keys: load balancer names<br>    object({<br>      type         = string<br>      is_internal  = optional(bool, false)<br>      is_dualstack = optional(bool, false)<br>      subnets = optional(map(<br>        # map keys: subnet names<br>        object({<br>          subnet_id                = string<br>          elastic_ip_allocation_id = optional(string)<br>          private_ipv4_address     = optional(string)<br>          ipv6_address             = optional(string)<br>        })<br>      ))<br>      alb_security_group_ids               = optional(list(string))<br>      alb_should_enable_http2              = optional(bool, true)<br>      nlb_enable_cross_zone_load_balancing = optional(bool, false)<br>      enable_deletion_protection           = optional(bool, true)<br>      desync_mitigation_mode               = optional(string, "defensive")<br>      idle_timeout_seconds                 = optional(number, 60)<br>      access_logging = optional(object({<br>        s3_bucket_name = string<br>        log_prefix     = optional(string)<br>        is_enabled     = optional(bool, true)<br>      }))<br>      tags = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | Map of ELB Target Group names to config objects. "target\_type" must be one<br>of "instance", "ip", "lambda", or "alb". For non-Lambda targets, "port" and<br>"protocol" must be provided; "protocol" must be one of GENEVE, HTTP, HTTPS,<br>TCP, TCP\_UDP, TLS, or UDP. If "protocol" is HTTP or HTTPS, you must provide<br>"protocol\_version", which must be one of HTTP1, HTTP2, or GRPC.<br><br>To register targets to a target group, specify "targets" (note: ECS Services<br>can be configured to handle registration of its containers with an ALB, don't<br>manually register such containers). | <pre>map(<br>    # map keys: target group names<br>    object({<br>      target_type                        = string           # instance/ip/lambda/alb<br>      port                               = optional(number) # not required for lambda<br>      protocol                           = optional(string) # not required for lambda<br>      protocol_version                   = optional(string) # required for HTTP/HTTPS protocols<br>      ip_address_type                    = optional(string) # required for ip types, "ipv4" or "ipv6"<br>      vpc_id                             = optional(string)<br>      slow_start_warmup_seconds          = optional(number, 0)<br>      load_balancing_algorithm_type      = optional(string, "round_robin") # can also be "least_outstanding_requests"<br>      lambda_multi_value_headers_enabled = optional(bool, false)           # applies to lambda only<br>      health_check = optional(object({<br>        is_enabled          = optional(bool, true)<br>        healthy_threshold   = optional(number, 3)<br>        unhealthy_threshold = optional(number)<br>        interval            = optional(number, 30)<br>        matcher             = optional(string)<br>        path                = optional(string)<br>        port                = optional(string, "traffic-port")<br>        protocol            = optional(string, "HTTP")<br>        timeout             = optional(number)<br>      }))<br>      targets = optional(list(object({<br>        id                = string<br>        port              = optional(number)<br>        availability_zone = optional(number)<br>      })))<br>      tags = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ELB_Listener_Rules"></a> [ELB\_Listener\_Rules](#output\_ELB\_Listener\_Rules) | Map of ELB Listener Rule resource objects (does not include default listener actions). |
| <a name="output_ELB_Listeners"></a> [ELB\_Listeners](#output\_ELB\_Listeners) | Map of ELB Listener resource objects. |
| <a name="output_ELB_Target_Group_Attachments"></a> [ELB\_Target\_Group\_Attachments](#output\_ELB\_Target\_Group\_Attachments) | Map of ELB Target Group Attachment resource objects. |
| <a name="output_ELB_Target_Groups"></a> [ELB\_Target\_Groups](#output\_ELB\_Target\_Groups) | Map of ELB Target Group resource objects. |
| <a name="output_ELBs"></a> [ELBs](#output\_ELBs) | Map of ELB resource objects. |

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
