<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS VPC</h1>

Terraform module for defining secure-by-default VPC resources.

</div>

<h2>Table of Contents</h2>

- [Usage Examples](#usage-examples)
- [Subnet Types](#subnet-types)
  - [Subnet-Type Resources](#subnet-type-resources)
  - [How to Customize or Disable Subnet-Type Resources](#how-to-customize-or-disable-subnet-type-resources)
  - [Subnet-Type Network ACLs: Default Rules](#subnet-type-network-acls-default-rules)
    - [Public_Subnets_NACL](#public_subnets_nacl)
    - [Private_Subnets_NACL](#private_subnets_nacl)
    - [IntraOnly_Subnets_NACL](#intraonly_subnets_nacl)
- [Subnet Availability Zones](#subnet-availability-zones)
- [PRIVATE Subnet Route Table Associations](#private-subnet-route-table-associations)
- [NAT Gateways](#nat-gateways)
- [VPC Peering](#vpc-peering)
- [Non-Configurable VPC-Default Resources](#non-configurable-vpc-default-resources)
- [AWS Service CIDR Blocks](#aws-service-cidr-blocks)
- [⚙️ Module Usage](#️-module-usage)
  - [Usage Examples](#usage-examples-1)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)

## Usage Examples

- Terragrunt: [view Terragrunt usage exmaple](examples/terragrunt.hcl)
- Terraform: &nbsp;[view vanilla Terraform usage exmaple](examples/terraform.tf)

## Subnet Types

This module categorizes subnets into the three distinct types: **PUBLIC**, **PRIVATE**, and **INTRA-ONLY**. <br>These "**Subnet-Type**" categories are based on the target of a subnet's default route (0.0.0.0/0).

| <span style="white-space: nowrap;">Subnet `type`</span> | Default Route Target | Public Ingress | Public Egress | Use Case Examples                                                                                                     |
| :------------------------------------------------------ | :------------------- | :------------: | :-----------: | :-------------------------------------------------------------------------------------------------------------------- |
| `PUBLIC`                                                | Internet Gateway     |       ✔️       |      ✔️       | • Public-facing workloads <br> • Load balancers <br> • NAT gateways                                                   |
| `PRIVATE`                                               | NAT Gateway          |       ❌       |      ✔️       | • Non-public-facing workloads <br> • Service layer components <br> • Databases                                        |
| <span style="white-space: nowrap;">`INTRA-ONLY`</span>  | None                 |       ❌       |      ❌       | • Workloads that don't require internet access <br> • Privacy-critical workloads <br> • Peered ops-management subnets |

Every subnet must be provided with a `type` value in the [`var.subnets` input variable](#inputs). This module uses subnet `type` values to automatically generate network ACLs and route tables with common rules and routes which reflect the subnet types you provide. These resources are referred to as **Subnet-Type** resources, all of which can be flexibly customized, disabled, or replaced.

### Subnet-Type Resources

All **Subnet-Type** resources are shown below. As documented in the relevant [input variables](#inputs), network ACLs and route tables don't have names in AWS, but this module requires user-provided names for both in order to facilitate a [non-index-based](https://www.youtube.com/watch?v=B6qHPHpoVyA&t=148s) organization of resource configs which implements sensible defaults without negatively impacting flexibility. **Subnet-Type** resources are not created for any types which are not included in the user's `var.subnets` inputs.

| <span style="white-space: nowrap;">Subnet `type`</span> | Subnet-Type<br>Network ACL | Subnet-Type<br>Route Table   | Notes                                                                                                                             |
| :------------------------------------------------------ | :------------------------- | :--------------------------- | :-------------------------------------------------------------------------------------------------------------------------------- |
| `PUBLIC`                                                | Public_Subnets_NACL        | Public_Subnets_RouteTable    | <br><br><br>                                                                                                                      |
| `PRIVATE`                                               | Private_Subnets_NACL       | &emsp; _PUBLIC subnet CIDR_  | PRIVATE subnet route table names = the CIDR of the PUBLIC subnet which contains the NAT gateway used as the default route target. |
| <span style="white-space: nowrap;">`INTRA-ONLY`</span>  | IntraOnly_Subnets_NACL     | IntraOnly_Subnets_RouteTable | <br>Custom rules/routes can not be added to INTRA-ONLY resources. You can, however, add tags.<br><br>                             |

### How to Customize or Disable Subnet-Type Resources

TO CUSTOMIZE any module-provided **Subnet-Type** resource, simply use its name as a key in the relevant input variable (`var.network_acls` or `var.route_tables`), and the rules/routes you provide will be merged into its configuration. User-provided inputs are given precedence, so you can add your own configs or override existing ones.

**_Do note, however, the resource configs listed below which can not be overridden:_**

- Route table default routes (0.0.0.0/0) are always defined by the `type` of subnets associated with it and therefore can not be customized.
- INTRA-ONLY resources can not be customized, as subnets of this type are intended to be entirely closed systems which permit neither ingress nor egress traffic. If you find yourself wanting to add rules/routes to INTRA-ONLY resources, instead either switch the subnet type to PRIVATE and customize the PRIVATE resources, or create your own entirely custom NACLs/route tables.

TO DISABLE any module-provided **Subnet-Type** resource, simply create your own custom NACLs/route tables in `var.network_acls`/`var.route_tables`, and have every subnet of the relevant type configured to use your custom resource using the `network_acl`/`route_table` properties in `var.subnets` config objects.

### Subnet-Type Network ACLs: Default Rules

#### Public_Subnets_NACL

- Ingress:
  | Rule Num | Protocol | CIDR Block | From Port | To Port | Description |
  | :------: | :------: | :--------: | --------: | ------: | :------------------ |
  | 100 | tcp | 0.0.0.0/0 | 80 | 80 | HTTP from anywhere |
  | 200 | tcp | 0.0.0.0/0 | 443 | 443 | HTTPS from anywhere |
  | 500 | tcp | 0.0.0.0/0 | 1024 | 65535 | Ephemeral ports |

- Egress:
  | Rule Num | Protocol | CIDR Block | From Port | To Port | Description |
  | :------: | :------: | :--------: | --------: | ------: | :---------------- |
  | 100 | tcp | 0.0.0.0/0 | 80 | 80 | HTTP to anywhere |
  | 200 | tcp | 0.0.0.0/0 | 443 | 443 | HTTPS to anywhere |
  | 500 | tcp | 0.0.0.0/0 | 1024 | 65535 | Ephemeral ports |

#### Private_Subnets_NACL

- Ingress:
  | Rule Num | Protocol | CIDR Block | From Port | To Port | Description |
  | :------: | :------: | :--------: | --------: | ------: | :-------------- |
  | 500 | tcp | 0.0.0.0/0 | 1024 | 65535 | Ephemeral ports |

- Egress:
  | Rule Num | Protocol | CIDR Block | From Port | To Port | Description |
  | :------: | :------: | :--------: | --------: | ------: | :---------------- |
  | 100 | tcp | 0.0.0.0/0 | 80 | 80 | HTTP to anywhere |
  | 200 | tcp | 0.0.0.0/0 | 443 | 443 | HTTPS to anywhere |
  | 500 | tcp | 0.0.0.0/0 | 1024 | 65535 | Ephemeral ports |

#### IntraOnly_Subnets_NACL

- Ingress:
  | Rule Num | Protocol | CIDR Block | From Port | To Port | Description |
  | :------: | :------: | :--------: | --------: | ------: | :-------------- |
  | - | - | - | - | - | **Ingress not permitted** |

- Egress:
  | Rule Num | Protocol | CIDR Block | From Port | To Port | Description |
  | :------: | :------: | :--------: | --------: | ------: | :-------------- |
  | - | - | - | - | - | **Egress not permitted** |

## Subnet Availability Zones

For each subnet, a valid `availability_zone` must be specified.

<b style="text-decoration:underline;">PRIVATE Subnets: Same-AZ NAT Gateway Required</b>

In each availability zone used by your PRIVATE subnets, there must also be at least one PUBLIC subnet configured with `contains_nat_gateway = true`.
This module does not support the creation of PRIVATE subnets with default routes pointing to NAT gateways in different availability zones, for two reasons:

1.  Cross-AZ NAT incurs a slight latency hit
2.  Such a design undermines high-availability

## PRIVATE Subnet Route Table Associations

As described in the [NAT Gateways section](#nat-gateways), all NAT gateways have a 1:1 relationship with a corresponding route table - we'll refer to these here as "NAT route tables".

To explicitly associate a PRIVATE subnet with any particular NAT route table, simply set the PRIVATE subnet's `route_table` property in `var.subnets` to the CIDR of the PUBLIC subnet which contains the NAT gateway of your choosing.

<b style="text-decoration:underline;">Any PRIVATE subnets which are not explicitly associated with a NAT are evenly distributed among the NAT route tables within their availability zone.</b>

## NAT Gateways

This module creates one NAT gateway for each PUBLIC subnet configured with `contains_nat_gateway = true`. This module identifies NAT gateways and their associated resources (below) by the CIDR of the PUBLIC subnet in which they're placed. For each NAT gateway, the following resources are also created:

- 1x elastic IP address
- 1x route table, for which the NAT gateway is the default route

As mentioned in the [section on availability zones](#subnet-availability-zones), there must be at least one PUBLIC subnet configured with `contains_nat_gateway = true` in each AZ used by your PRIVATE subnets.

## VPC Peering

There are two input variables which can be used to configure [VPC peering connections](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html):

1. `peering_request_vpc_ids` A map of peer VPC IDs to peering connection config objects; use this variable for peering connections in which your VPC is the _requester_ VPC.
2. `peering_accept_connection_ids` A map of VPC peering connection IDs to peering connection config objects; use this property for peering connections in which your VPC is the _accepter_ VPC.

For both the **_requester_** and **_accepter_** VPCs, remote VPC DNS resolution (whereby public IPs map to private DNS hostnames) is enabled by default. Set `allow_remote_vpc_dns_resolution` to **false** in either VPC to disable this feature.

**VPC Peering: Connection Auto-Accept**

If the **_requester_** and **_accepter_** VPCs are both in the same region and owned by the same account, the peering connection will be configured to **auto-accept**, thereby streamlining the connection setup process:

- the **_requester_** VPC does not have to provide the peer VPC's region nor account ID
- the **_accepter_** VPC does not have to manually accept the connection request, unless it's desirable to disable remote VPC DNS resolution

**VPC Peering: Required Subnet-Level Configs**

Once a VPC peering connection has been established, the following subnet-level resource configs will need to be in place before peering connection traffic can proceed:

- To permit **INGRESS** traffic, a subnet within the VPC which is the target of a request must have a network ACL with at least one rule allowing the request using the sending VPC's CIDR (or a subset thereof). The NACL rule must also specify the correct protocol and port-range, which will of course depend on the nature of the request.
- To permit **EGRESS** traffic, a subnet within the VPC from which the request originates must have a route table with at least one route configured with the peering connection ID using the receiving VPC's CIDR (or a subset thereof). <br><br>
  > **_AWS does not permit transitive routing through peering connections_** <br>
  > For more info, see [Unsupported VPC Peering Configurations](https://docs.aws.amazon.com/vpc/latest/peering/invalid-peering-configurations.html).

To see how this module is used to configure VPC peering, check out [this usage example](examples/terragrunt.hcl).

<!-- TODO Add info here on VPC Endpoints -->

## Non-Configurable VPC-Default Resources

In accordance with network security best practices, this module brings each VPC's default resources (listed below) under management, and locks them down by implementing configurations that deny all traffic which may otherwise be **_implicitly_** allowed. This behavior cannot be overridden, as it ensures that the only network traffic throughout the VPC is that which has been **_explicitly_** allowed.

**🔒 Locked-Down Resources:**

- Default Route Table
- Default Network ACL
- Default Security Group

## AWS Service CIDR Blocks

For both Security Group and Network ACL rule config objects, if the CIDR target is one of the supported AWS Services listed in the table below, you can provide the service's enum value to the rule's relevant property: `aws_service` for Security Group rules, and `cidr_block` for Network ACL rules. When provided, this module will perform the CIDR lookup for you using the region of the calling AWS Provider. CloudFront also offers "global" CIDRs, which can be obtained via the **cloudfront_global** enum value.

Most of the services supported by the underlying data source return multiple CIDR block values, which is fine for Security Group rules which accept multiple CIDRs without issue, but this is problematic for NACL rules since we can only provide a single CIDR for any given NACL rule's CIDR parameter. Therefore, the list of supported services for Network ACL rules is restricted at this time to only those which return a single value.

**Supported Services:**

| Service              | Service Enum         | Supported for Security Group Rules | Supported for NACL Rules |
| :------------------- | :------------------- | :--------------------------------: | :----------------------: |
| Amazon (amazon.com)  | amazon               |                 ✔️                 |            ❌            |
| Amazon Connect       | amazon_connect       |                 ✔️                 |            ❌            |
| API Gateway          | api_gateway          |                 ✔️                 |            ❌            |
| Cloud9               | cloud9               |                 ✔️                 |            ❌            |
| CloudFront           | cloudfront           |                 ✔️                 |            ❌            |
| CloudFront (global)  | cloudfront_global    |                 ✔️                 |            ❌            |
| CodeBuild            | codebuild            |                 ✔️                 |            ❌            |
| EC2                  | ec2                  |                 ✔️                 |            ❌            |
| EC2 Instance Connect | ec2_instance_connect |                 ✔️                 |            ✔️            |
| DynamoDB             | dynamodb             |                 ✔️                 |            ❌            |
| GlobalAccelerator    | globalaccelerator    |                 ✔️                 |            ✔️            |
| Route53              | route53              |                 ✔️                 |            ❌            |
| Route53 HealthChecks | route53_healthchecks |                 ✔️                 |            ❌            |
| S3                   | s3                   |                 ✔️                 |            ❌            |
| Workspaces Gateways  | workspaces_gateways  |                 ✔️                 |            ❌            |

<br>

<details>
  <summary><b>Note: Network ACL Unsupported Services</b></summary>

<br>
<p>
To address the NACL CIDR param issues, the following approaches are under consideration:
</p>

<ul>
  <li>When multiple CIDRs are returned,
    <ul>
      <li>The module could create an allow rule for each CIDR. <br> &nbsp; &nbsp; &nbsp; &nbsp;<i>Easiest to implement, but implicit rule decision-making = less caller control.</i></li>
      <li>Or rules could be created for just a subset of the CIDRs. <br> &nbsp; &nbsp; &nbsp; &nbsp;<i>How should caller determine the subset?</i></li>
      <li>Or a rule could be created for just one CIDR. <br> &nbsp; &nbsp; &nbsp; &nbsp;<i>How should caller determine which one?</i></li>
    </ul>
  </li>
  <br />
  <li>When zero CIDRs are returned,
    <ul>
      <li>We could allow the data block to cause the plan/apply operation to error out. <br> &nbsp; &nbsp; &nbsp; &nbsp;<i>More errors, never ideal.</i></li>
      <li>Or the NACL rule could be skipped. <br> &nbsp; &nbsp; &nbsp; &nbsp;<i>Fewer errors, but again, implicit rule decision-making = less caller control.</i></li>
    </ul>
  </li>
</ul>

</details>

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
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat_gw_elastic_ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_route_table.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_peering_connection.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_options.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_ip_ranges.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ip_ranges) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_network_acl_tags"></a> [default\_network\_acl\_tags](#input\_default\_network\_acl\_tags) | Tags for the VPC's default network ACL. | `map(string)` | `null` | no |
| <a name="input_default_route_table_tags"></a> [default\_route\_table\_tags](#input\_default\_route\_table\_tags) | Tags for the VPC's default route table. | `map(string)` | `null` | no |
| <a name="input_default_security_group_tags"></a> [default\_security\_group\_tags](#input\_default\_security\_group\_tags) | Tags for the VPC's default security group. | `map(string)` | `null` | no |
| <a name="input_internet_gateway_tags"></a> [internet\_gateway\_tags](#input\_internet\_gateway\_tags) | Tags for the internet gateway. | `map(string)` | `null` | no |
| <a name="input_nat_gateway_elastic_ip_tags"></a> [nat\_gateway\_elastic\_ip\_tags](#input\_nat\_gateway\_elastic\_ip\_tags) | Map of NAT-containing public subnet CIDRs to tags for each respective<br>subnet's NAT-associated elastic IP address. | `map(map(string))` | `null` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | Map of NAT-containing public subnet CIDRs to tags for each respective<br>subnet's NAT gateway. | `map(map(string))` | `null` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Map of network ACL names to config objects. Network ACLs do not have names in AWS,<br>but the name values you provide will be used by this module to properly identify<br>network ACLs for the purposes of rule customization and subnet association.<br><br>"access.ingress" and "access.egress" map quoted rule numbers (e.g., "100") to objects<br>configuring each respective rule. For each rule, if "from\_port" and "to\_port" are the<br>same, you can simply provide just "port" which will be mapped to both. "protocol"<br>defaults to "tcp" if not provided. | <pre>map(<br>    # map keys: internal NACL "names"<br>    object({<br>      access = optional(object({<br>        ingress = optional(map(<br>          # map keys: quoted rule numbers (e.g., "100")<br>          object({<br>            cidr_block = string<br>            protocol   = optional(string, "tcp")<br>            port       = optional(number)<br>            from_port  = optional(number)<br>            to_port    = optional(number)<br>          })<br>        ), {})<br>        egress = optional(map(<br>          # map keys: quoted rule numbers (e.g., "100")<br>          object({<br>            cidr_block = string<br>            protocol   = optional(string, "tcp")<br>            port       = optional(number)<br>            from_port  = optional(number)<br>            to_port    = optional(number)<br>          })<br>        ), {})<br>      }), { access = {}, ingress = {} })<br>      tags = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_peering_accept_connection_ids"></a> [peering\_accept\_connection\_ids](#input\_peering\_accept\_connection\_ids) | (Optional) VPC Peering connection accepts config; use this variable for<br>peering connections in which your VPC is the ACCEPTER VPC. Map peering<br>connection IDs to config objects for each respective peering connection<br>to accept. If the peering connection was configured for auto-acceptance,<br>manual acceptance is not required to establish the connection.<br>"allow\_remote\_vpc\_dns\_resolution" defaults to "true". For more info, see<br>the [`VPC Peering` section of the README](#vpc-peering). | <pre>map(<br>    # map keys: peering connection IDs<br>    object({<br>      allow_remote_vpc_dns_resolution = optional(bool)<br>      tags                            = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_peering_request_vpc_ids"></a> [peering\_request\_vpc\_ids](#input\_peering\_request\_vpc\_ids) | (Optional) VPC Peering connection requests config; use this variable for<br>peering connections in which your VPC is the REQUESTER VPC. Map accepter<br>VPC IDs to config objects for each respective peering connection request.<br>"allow\_remote\_vpc\_dns\_resolution" defaults to "true". For more info, see<br>the [`VPC Peering` section of the README](#vpc-peering). | <pre>map(<br>    # map keys: peer VPC IDs<br>    object({<br>      peer_vpc_owner_account_id       = optional(string)<br>      peer_vpc_region                 = optional(string)<br>      allow_remote_vpc_dns_resolution = optional(bool)<br>      tags                            = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | Map of route table names to route table config objects. Route tables do not have names in<br>AWS, but the name values you provide will be used by this module to properly identify route<br>tables for the purposes of route customization and subnet association.<br><br>"routes" maps CIDRs of route destinations to objects configuring each respective route.<br>Custom route tables for PRIVATE subnets can set their default route ("0.0.0.0/0") using<br><br>"nat\_gateway\_subnet\_cidr", which must be set to the CIDR of a NAT-containing PUBLIC subnet.<br>Peering connection routes can be configured in one of two ways: if VPC is the peering<br>REQUESTER, use "peering\_request\_vpc\_id", otherwise if VPC is the peering ACCEPTER, use<br>"peering\_connection\_id". | <pre>map(<br>    # map keys: internal route table "names"<br>    object({<br>      routes = optional(map(<br>        # map keys: CIDRs of route destinations<br>        object({<br>          nat_gateway_subnet_cidr      = optional(string)<br>          peering_request_vpc_id       = optional(string)<br>          peering_accept_connection_id = optional(string)<br>        })<br>      ))<br>      tags = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of Security Group names to config objects. For each ingress/egress rule,<br>"protocol" defaults to "tcp" if not provided. If "from\_port" and "to\_port" are<br>the same, you can provide just "port" which will be mapped to both. If a rule<br>will use the CIDR block of an AWS service, you can provide an enum string to<br>"aws\_service" to have the lookup performed by the module; see the [AWS Service<br>CIDR Blocks section of the README](#aws-service-cidr-blocks) for a list of<br>supported services and their enum values. | <pre>map(<br>    # map keys: security group names<br>    object({<br>      description = string<br>      access = object({<br>        ingress = optional(list(<br>          object({<br>            description            = string<br>            protocol               = optional(string, "tcp")<br>            port                   = optional(number)<br>            from_port              = optional(number)<br>            to_port                = optional(number)<br>            peer_security_group_id = optional(string)<br>            peer_security_group    = optional(string)<br>            aws_service            = optional(string)<br>            cidr_blocks            = optional(list(string))<br>            self                   = optional(bool)<br>          })<br>        ))<br>        egress = optional(list(<br>          object({<br>            description            = string<br>            protocol               = optional(string, "tcp")<br>            port                   = optional(number)<br>            from_port              = optional(number)<br>            to_port                = optional(number)<br>            peer_security_group_id = optional(string)<br>            peer_security_group    = optional(string)<br>            aws_service            = optional(string)<br>            cidr_blocks            = optional(list(string))<br>            self                   = optional(bool)<br>          })<br>        ))<br>      })<br>      tags = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet CIDRs to subnet config objects. For each subnet, "type" must be either<br>"PUBLIC", "PRIVATE", or "INTRA-ONLY". The properties "map\_public\_ip\_on\_launch" and<br>"contains\_nat\_gateway" both default to false, and have no effect on non-public subnets.<br>Public and private subnets can be configured to use specific route tables and/or NACLs<br>via the "route\_table" and "network\_acl" properties respectively; these have no effect<br>on INTRA-ONLY subnets. | <pre>map(<br>    # map keys: subnet CIDRs<br>    object({<br>      availability_zone       = string<br>      type                    = string<br>      map_public_ip_on_launch = optional(bool)<br>      contains_nat_gateway    = optional(bool)<br>      route_table             = optional(string)<br>      network_acl             = optional(string)<br>      tags                    = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Config object for the VPC. The optional bools "enable\_dns\_support"<br>and "enable\_dns\_hostnames" both default to "true". | <pre>object({<br>    cidr_block           = string<br>    enable_dns_support   = optional(bool)<br>    enable_dns_hostnames = optional(bool)<br>    tags                 = optional(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_vpc_endpoints"></a> [vpc\_endpoints](#input\_vpc\_endpoints) | Map of VPC Endpoint services to endpoint config objects. Service-keys are<br>all normalized to lower-case and are therefore case-insensitive. A list of<br>valid services is available at the link below.<br>https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html<br><br>"type" can be "Interface" (default), "Gateway", or "GatewayLoadBalancer".<br>Gateway endpoints can only be created for the S3 and DynamoDB services.<br>All "Gateway" and some "Interface" endpoints can provide "policy", which if<br>provided must be a valid IAM policy formatted as a JSON string.<br>If the endpoint and service are owned by the same account, "auto-accept" can<br>be used to either enable or disable automatic acceptance of the connection.<br>"enable\_private\_dns" is only applicable to "Interface" endpoints and defaults<br>to true. "timeouts" are all optional and default to "10m" if not provided.<br><br>Endpoint Resource Associations<br>"Interface" and "GatewayLoadBalancer" endpoints must provide "subnet\_cidrs", a<br>list of subnet CIDRs in which to place the interface/GWLB. "Interface" endpoints<br>must additionally provide "security\_groups", a list of names of security groups<br>which should be associated with the endpoint's interface. "Gateway" endpoints<br>must specify "route\_tables"; AWS will automatically add/remove routes to these<br>route tables which connect the service's AWS-managed prefix-list to the gateway<br>endpoint. | <pre>map(object({<br>    # map keys: names of VPC endpoint services<br>    type               = optional(string) # Interface (default), Gateway, or GatewayLoadBalancer<br>    policy             = optional(string)<br>    auto_accept        = optional(bool)<br>    enable_private_dns = optional(bool)         # Only for types: Interface<br>    subnet_cidrs       = optional(list(string)) # Only for types: Interface, GWLB<br>    security_groups    = optional(list(string)) # Only for types: Interface<br>    route_tables       = optional(list(string)) # Only for types: Gateway<br>    timeouts = optional(object({<br>      create = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>    tags = optional(map(string))<br>  }))</pre> | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Default_NetworkACL"></a> [Default\_NetworkACL](#output\_Default\_NetworkACL) | The VPC's default network ACL resource object. |
| <a name="output_Default_RouteTable"></a> [Default\_RouteTable](#output\_Default\_RouteTable) | The VPC's default route table resource object. |
| <a name="output_Default_SecurityGroup"></a> [Default\_SecurityGroup](#output\_Default\_SecurityGroup) | The VPC's default security group resource object. |
| <a name="output_Internet_Gateway"></a> [Internet\_Gateway](#output\_Internet\_Gateway) | The internet gateway resource object. |
| <a name="output_NAT_Gateway_Elastic_IPs"></a> [NAT\_Gateway\_Elastic\_IPs](#output\_NAT\_Gateway\_Elastic\_IPs) | Map of NAT gateway elastic IP address resource objects. |
| <a name="output_NAT_Gateways"></a> [NAT\_Gateways](#output\_NAT\_Gateways) | Map of NAT gateway resource objects. |
| <a name="output_Network_ACLs"></a> [Network\_ACLs](#output\_Network\_ACLs) | Map of network ACL resource objects. |
| <a name="output_RouteTables"></a> [RouteTables](#output\_RouteTables) | Map of route table resource objects. |
| <a name="output_Security_Groups"></a> [Security\_Groups](#output\_Security\_Groups) | Map of security group resource objects. |
| <a name="output_Subnets"></a> [Subnets](#output\_Subnets) | Map of subnet resource objects merged with their respective input params. |
| <a name="output_VPC"></a> [VPC](#output\_VPC) | The VPC resource object. |
| <a name="output_VPC_Endpoints"></a> [VPC\_Endpoints](#output\_VPC\_Endpoints) | Map of VPC Endpoint resource objects. |
| <a name="output_VPC_Peering_Connection_Accepts"></a> [VPC\_Peering\_Connection\_Accepts](#output\_VPC\_Peering\_Connection\_Accepts) | Map of VPC Peering Connection Accepter resource objects. |
| <a name="output_VPC_Peering_Connection_Options"></a> [VPC\_Peering\_Connection\_Options](#output\_VPC\_Peering\_Connection\_Options) | Map of VPC Peering Connection Options resource objects. |
| <a name="output_VPC_Peering_Connection_Requests"></a> [VPC\_Peering\_Connection\_Requests](#output\_VPC\_Peering\_Connection\_Requests) | Map of VPC Peering Connection resource objects. |

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
