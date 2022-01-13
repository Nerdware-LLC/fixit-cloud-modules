# Fixit Cloud ☁️ MODULE: AWS VPC

Terraform module for defining a hardened VPC and related resources.

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.NAT_GW_EIP](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.nacl_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.internet_gateway_egress_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_gateway_egress_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_ip_ranges.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ip_ranges) | data source |
| [aws_ip_ranges.ec2_instance_connect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ip_ranges) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_resource_tags"></a> [default\_resource\_tags](#input\_default\_resource\_tags) | In accordance with best practices, this module locks down the VPC's default<br>components to ensure all ingress/egress traffic only uses infrastructure with<br>purposefully-designed rules and configs. Default subnets must be deleted manually<br>- they cannot be removed via Terraform. This variable allows you to customize the<br>tags on these "default" network components. | <pre>object({<br>    default_route_table    = optional(map(string))<br>    default_network_acl    = optional(map(string))<br>    default_security_group = optional(map(string))<br>  })</pre> | <pre>{<br>  "default_network_acl": null,<br>  "default_route_table": null,<br>  "default_security_group": null<br>}</pre> | no |
| <a name="input_gateway_tags"></a> [gateway\_tags](#input\_gateway\_tags) | Config object for VPC gateway resource tags. | <pre>object({<br>    internet_gateway       = optional(map(string))<br>    nat_gateway            = optional(map(string))<br>    nat_gateway_elastic_ip = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_network_acl_configs"></a> [network\_acl\_configs](#input\_network\_acl\_configs) | List of config objects for Network ACL resources. For ingress/egress rule config objects,<br>instead of providing separate "from\_port" and "to\_port" args, you can alternatively provide<br>just "port" which will map to both. You can also pass a string value like "HTTPS" or "Redis"<br>(case-insensitive) to the "default\_port" arg to have the default port of the protocol/service<br>mapped to both. Refer to the README for a list of supported arguments for "default\_port". If<br>you need the cidr\_block of a particular AWS service, like EC2 Instance Connect, you can pass<br>cidr\_block = "EC2\_INSTANCE\_CONNECT". Please refer to the README to for a list of supported<br>AWS services for "cidr\_block". | <pre>list(object({<br>    subnet_cidrs = list(string)<br>    access = optional(object({<br>      ingress = optional(list(object({<br>        rule_number  = number<br>        cidr_block   = string<br>        protocol     = optional(string)<br>        default_port = optional(string)<br>        port         = optional(number)<br>        from_port    = optional(number)<br>        to_port      = optional(number)<br>      })))<br>      egress = optional(list(object({<br>        rule_number  = number<br>        cidr_block   = string<br>        protocol     = optional(string)<br>        default_port = optional(string)<br>        port         = optional(number)<br>        from_port    = optional(number)<br>        to_port      = optional(number)<br>      })))<br>    }))<br>    tags = optional(map(string))<br>  }))</pre> | n/a | yes |
| <a name="input_route_table_tags"></a> [route\_table\_tags](#input\_route\_table\_tags) | Map of route table resource tags, with subnet egress destinations as keys<br>(see the description for "var.subnets" for more info). The keys must either<br>be "INTERNET\_GATEWAY", "NAT\_GATEWAY", or a valid CIDR block quoted string<br>pointing to another VPC. Support for other destination types, such as<br>"VIRTUAL\_PRIVATE\_GATEWAY", will be added in the future. | `map(map(string))` | <pre>{<br>  "INTERNET_GATEWAY": {},<br>  "NAT_GATEWAY": {}<br>}</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of Security Group name keys pointing to config object values. For ingress/egress rule<br>config objects, instead of providing separate "from\_port" and "to\_port" arguments, you can<br>alternatively just provide "port" which will map to both. For SecGrp ingress/egress rules<br>which need to point to another Security Group, use the "peer\_security\_group" key with the<br>value set to the name of the target SecGrp. If you need the cidr\_blocks of a particular AWS<br>service, like EC2 Instance Connect, you can set "aws\_service" = "EC2\_INSTANCE\_CONNECT".<br>Please refer to the README for a list of supported arguments for "aws\_service". | <pre>list(object({<br>    name        = string<br>    description = string<br>    tags        = optional(map(string))<br>    access = object({<br>      ingress = optional(list(object({<br>        description            = string<br>        protocol               = optional(string)<br>        port                   = optional(number)<br>        from_port              = optional(number)<br>        to_port                = optional(number)<br>        peer_security_group_id = optional(string)<br>        peer_security_group    = optional(string)<br>        aws_service            = optional(string)<br>        cidr_blocks            = optional(list(string))<br>        self                   = optional(bool)<br>      })))<br>      egress = optional(list(object({<br>        description            = string<br>        protocol               = optional(string)<br>        port                   = optional(number)<br>        from_port              = optional(number)<br>        to_port                = optional(number)<br>        peer_security_group_id = optional(string)<br>        peer_security_group    = optional(string)<br>        aws_service            = optional(string)<br>        cidr_blocks            = optional(list(string))<br>        self                   = optional(bool)<br>      })))<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet config objects with quoted CIDR strings as keys (e.g., "127.1.0.0/24").<br>All CIDR blocks must fit within the given VPC, and must not overlap with one another.<br>The "egress\_destination" property can be "INTERNET\_GATEWAY", "NAT\_GATEWAY", a valid<br>CIDR block string pointing to another VPC, or "NONE". Support for other destination<br>types, such as "VIRTUAL\_PRIVATE\_GATEWAY", will be added in the future. If set to "NONE",<br>egress traffic will not be able to leave the subnet. Aside from determining which route<br>table each subnet is associated with, the values of this property across all subnets<br>collectively determine which gateways and route tables get created within the VPC.<br>The property "contains\_nat\_gateway" is optional (with a default value of "false"), and<br>determines in which subnet - if any - the NAT gateway should be placed. Only one subnet<br>can have this property set to "true"; if no subnets have "contains\_nat\_gateway" set to<br>"true", the NAT gateway and its associated elastic IP address shall be skipped. | <pre>map(object({<br>    availability_zone    = string<br>    egress_destination   = string<br>    contains_nat_gateway = optional(bool)<br>    tags                 = optional(map(string))<br>  }))</pre> | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Config object for the VPC; all optional bools default to "true". | <pre>object({<br>    cidr_block           = string<br>    enable_dns_support   = optional(bool)<br>    enable_dns_hostnames = optional(bool)<br>    tags                 = optional(map(string))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Default_NetworkACL"></a> [Default\_NetworkACL](#output\_Default\_NetworkACL) | The VPC's default network ACL resource object. |
| <a name="output_Default_RouteTable"></a> [Default\_RouteTable](#output\_Default\_RouteTable) | The VPC's default route table resource object. |
| <a name="output_Default_SecurityGroup"></a> [Default\_SecurityGroup](#output\_Default\_SecurityGroup) | The VPC's default security group resource object. |
| <a name="output_Internet_GW"></a> [Internet\_GW](#output\_Internet\_GW) | The internet gateway resource object. |
| <a name="output_NAT_GW"></a> [NAT\_GW](#output\_NAT\_GW) | The NAT gateway resource object. |
| <a name="output_NAT_GW_EIP"></a> [NAT\_GW\_EIP](#output\_NAT\_GW\_EIP) | The NAT gateway's elastic IP address resource object. |
| <a name="output_Network_ACLs"></a> [Network\_ACLs](#output\_Network\_ACLs) | A list of network ACL resource objects with their respective RULES merged in. |
| <a name="output_RouteTables"></a> [RouteTables](#output\_RouteTables) | Map of route table resource objects, with "egress\_destination" values as keys. |
| <a name="output_Security_Groups"></a> [Security\_Groups](#output\_Security\_Groups) | A map of security group resource objects with their respective RULES merged in. |
| <a name="output_Subnets"></a> [Subnets](#output\_Subnets) | Map of subnet resource objects, with CIDR blocks as keys. User-provided values<br>"egress\_destination" and "contains\_nat\_gateway" are merged into the resource objects.<br>To facilitate easier filtering of subnet outputs, the boolean "is\_public\_subnet" is<br>also added, with the value being "true" for subnets where "egress\_destination" is<br>set to "INTERNET\_GATEWAY". |
| <a name="output_VPC"></a> [VPC](#output\_VPC) | The VPC resource object. |
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

[pre-commit-shield]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
[fixit-cloud-live]: https://github.com/Nerdware-LLC/fixit-cloud-live
[pets-meme]: https://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/
[linkedin-url]: https://www.linkedin.com/in/trevor-anderson-3a3b0392/
[linkedin-shield]: https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white
