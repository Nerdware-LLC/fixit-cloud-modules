<h1>Fixit Cloud ☁️ MODULE: AWS VPC</h1>

Terraform module for defining secure-by-default VPC resources.

<h2>Table of Contents</h2>

- [VPC Configs](#vpc-configs)
  - [VPC DNS](#vpc-dns)
  - [VPC Peering](#vpc-peering)
- [Subnet Configs](#subnet-configs)
  - [Subnet Types](#subnet-types)
  - [Subnet Availability Zones](#subnet-availability-zones)
  - [Public IP Auto-Assignment](#public-ip-auto-assignment)
  - [NAT Gateway Placement](#nat-gateway-placement)
  - [NAT Gateway Assignment](#nat-gateway-assignment)
  - [Subnets: `route_table` and `network_acl`](#subnets-route_table-and-network_acl)
- [Route Tables](#route-tables)
  - [Subnet-Type Route Tables](#subnet-type-route-tables)
  - [Custom Route Tables](#custom-route-tables)
- [Network ACLs](#network-acls)
  - [NACL Rules](#nacl-rules)
  - [Subnet-Type Network ACLs](#subnet-type-network-acls)
  - [Custom Network ACLs](#custom-network-acls)
- [Non-Configurable VPC-Default Resources](#non-configurable-vpc-default-resources)
- [AWS Service CIDR Blocks](#aws-service-cidr-blocks)
- [Module Usage](#module-usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [License](#license)
- [Contact](#contact)

## VPC Configs

VPC configs are provided using the [`var.vpc` input variable](#inputs).

### VPC DNS

AWS DNS features are enabled by default. Set `enable_dns_support` and/or `enable_dns_hostnames` to **false** to disable these features.

### VPC Peering

There are two properties which can be used to configure [VPC peering connections](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html):

1. `peering_request_vpc_ids` A map of peer VPC IDs to peering connection config objects; use this property for peering connections in which your VPC is the _requester_ VPC.
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

## Subnet Configs

Subnet configs are provided using the [`var.subnets` input variable](#inputs), which maps subnet CIDRs to config objects.

### Subnet Types

Each subnet must have a specified `type`, the value of which is an enum which reflects the subnet's default route ("0.0.0.0/0"). This module uses subnet `type` values to automatically generate network ACLs and route tables with common rules and routes which reflect the subnet types you provide. These resources are referred to as [**Subnet-Type** resources](#subnet-type-resources), all of which can be flexibly customized, disabled, or replaced. Valid `type` values:

| Subnet `type` | Default Route Target | Public Ingress | Public Egress | Use Case Examples                                                                                                     |
| :------------ | :------------------- | :------------: | :-----------: | :-------------------------------------------------------------------------------------------------------------------- |
| `PUBLIC`      | Internet Gateway     |       ✔️       |      ✔️       | • Public-facing workloads <br> • Load balancers <br> • NAT gateways                                                   |
| `PRIVATE`     | NAT Gateway          |       ❌       |      ✔️       | • Non-public-facing workloads <br> • Service layer components <br> • Databases                                        |
| `INTRA-ONLY`  | None                 |       ❌       |      ❌       | • Workloads that don't require internet access <br> • Privacy-critical workloads <br> • Peered ops-management subnets |

### Subnet Availability Zones

For each subnet, a valid `availability_zone` must be specified.

> <b style="text-decoration:underline;">PRIVATE Subnets: Same-AZ NAT Gateway Required</b>
>
> In each availability zone used by your PRIVATE subnets, there must also be at least one PUBLIC subnet configured with `"contains_nat_gateway" = true`.
> This module does not support the creation of PRIVATE subnets with default routes pointing to NAT gateways in different availability zones, for two reasons:
>
> 1.  Cross-AZ NAT incurs a slight latency hit
> 2.  Such a design undermines high-availability

### Public IP Auto-Assignment

By default, the AWS public IP auto-assignment feature is disabled in all subnets. Set `map_public_ip_on_launch` to **true** to enable this feature in any PUBLIC subnet (no effect on non-public subnet configs).

### NAT Gateway Placement

By default, no subnets will contain a NAT gateway. Set `contains_nat_gateway` to **true** to create a NAT gateway in any PUBLIC subnet (no effect on non-public subnet configs). As mentioned in the [section on availability zones](#subnet-availability-zones), there must be at least one PUBLIC subnet configured with `"contains_nat_gateway" = true` in each AZ used by your PRIVATE subnets.

### NAT Gateway Assignment

<!--
TODO explain PRIVATE subnet NAT gateway assignment !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  - NATs are IDd by CIDR
  - Each NAT gets a RT, 1:1
  - can be explicit via `route_table`

-->

### Subnets: `route_table` and `network_acl`

<!--
FIXME update this section:
    - private subnets can specify a SPECIFIC RT without adding routes/tags w the CIDR of the NAT
    - else they can do a custom NAME, like PUBLIC subnets can
      - this is necessary to allow 2 RTs with same Default Route, but only 1 has peering
-->

Subnets can be associated with a specific route table or network ACL via the `route_table` and `network_acl` subnet properties. These resources must be configured in their respective input variables: [`var.route_tables`](#route-tables) and [`var.network_acls`](#network-acls) (click links for more info).

<!-- TODO Below comment is from other section, fold it in here.

To assign a PRIVATE subnet to a particular route table, set its "route_table" property in var.subnets to the CIDR of the PUBLIC subnet which contains the desired NAT gateway; unless that route table will also contain custom routes (e.g., a VPC peering connection), it need not be provided in this variable. -->

## Route Tables

Route table configs are provided using the [`var.route_tables` input variable](#inputs), which maps arbitrary route table _"names"_ to config objects. Route tables do not have names in AWS, but the name values you provide will be used by this module to properly identify route tables for the purposes of route customization and subnet association. Use the **route_table** subnet config property to explicitly associate a subnet with a specific route table.

> For PRIVATE subnet route tables, the name of the route table must be the CIDR of a PUBLIC subnet within the same AZ which contains a NAT gateway.

The route table config objects can contain custom `routes` and/or `tags`. "routes" maps CIDRs of route destinations to objects configuring each respective route. Any valid CIDR block can used except for the default route CIDR ("0.0.0.0/0"), which is automatically configured for each subnet based on its `type` and cannot be overridden.

**Route Configs:**

- VPC peering connections can be configured in one of two ways:
  1. If VPC is the peering REQUESTER, use "peering_request_vpc_id"
  2. If VPC is the peering ACCEPTER, use "peering_connection_id"

### Subnet-Type Route Tables

By default, route tables will be created which reflect the "type" of subnets included in your `var.subnets` input, which this module refers to as **Subnet-Type** route tables.

- For PUBLIC subnets, one route table is created named **Public_Subnets_RouteTable** which routes egress traffic to the VPC's internet gateway.
- For INTRA-ONLY subnets, one route table is created named **IntraOnly_Subnets_RouteTable** which does not contain any routes, thereby disabling both ingress and egress traffic for associated subnets.
- For PRIVATE subnets, one route table is created for each NAT gateway included in your `var.subnets` config; like the NAT gateways themselves, this module identifies NAT-connected route tables by the CIDR of the PUBLIC subnet which contains the NAT gateway. To add routes and/or tags to any of the Subnet-Type route tables, simply use their identifier (route table name, or for private subnets the CIDR of the subnet which contains the NAT) as a key in `var.route_tables`, with the value set to an object with your desired configs.

<!--
FIXME update this section:
    - private subnets can specify a SPECIFIC RT without adding routes/tags w the CIDR of the NAT
    - else they can do a custom NAME, like PUBLIC subnets can
      - this is necessary to allow 2 RTs with same Default Route, but only 1 has peering
-->

- PUBLIC Subnet-Type route table:
  - A single route table named **Public_Subnets_RouteTable** which routes egress traffic to the VPC's internet gateway.
  - By default all PUBLIC subnets are associated with it.
  - To override the default Subnet-Type route table for PUBLIC subnets, set `route_table` to any custom route table named in `var.route_tables`.
- PRIVATE Subnet-Type route tables:
  - One route table is created per NAT gateway; like the NAT gateways themselves, this module identifies NAT-connected route tables by the CIDR of the public subnet which contains the NAT gateway.
  - By default PRIVATE subnets are evenly distributed among route tables within the same AZ to spread out the load.
  - To explicitly set a specific route table for PRIVATE subnets, set `route_table` to the CIDR of any PUBLIC subnet within the same AZ which contains a NAT gateway. Unless the desired route table will also contain custom non-default routes (e.g., a VPC peering connection) or tags, it need not be provided in `var.route_tables` since it will already exist.
- INTRA-ONLY Subnet-Type route table:
  - A single route table named **IntraOnly_Subnets_RouteTable** which does not contain any routes, thereby disabling egress traffic.
  - All INTRA-ONLY subnets are associated with it.
  - The default Subnet-Type route table for INTRA-ONLY subnets cannot be overridden (use a different subnet type instead). Only tags can be added, using the RT's name.

### Custom Route Tables

To create your own route table, simply use your own custom route table name as a key in `var.route_tables`, and then associate subnets with the route table via the `route_table` property in your `var.subnets` input. If all subnets of any given type are assigned to custom route tables, then the module-provided route table for that Subnet-Type will not be created.

<!-- TODO explain that all RT egress routes can NOT be overridden

  PUBLIC subnet RTs cannot customize egress "0.0.0.0/0" route, MUST be IGW
  PRIVATE subnet RTs are defined by the CIDR of the NAT's public subnet;
      by definition, that NAT-RT's egress MUST go to its NAT GW.

      TODO explain that any "route_table" or "network_acl" values
      for INTRA-ONLY subnets will simply be ignored (no error - should we error?)


    TODO go thru docs, ensure refs to "0.0.0.0/0" refer to it as the "zero"/"quad-zero"/"default" route,
          NOT "the egress route"
-->

## Network ACLs

Network ACL configs are provided using the [`var.network_acls` input variable](#inputs), which maps arbitrary NACL _"names"_ to config objects. NACLs do not have names in AWS, but the name values you provide will be used by this module to properly identify NACLs for the purposes of rule customization and subnet assignment.

### NACL Rules

Both the `ingress` and `egress` properties map quoted rule numbers (e.g., "100") to rule config objects. If not provided, `protocol` defaults to **"tcp"**. If `from_port` and `to_port` are the same, you can simply provide just `port`, which will map to both. If you need the CIDR of a particular AWS service, like EC2 Instance Connect, you can pass values like **"ec2_instance_connect"** to the `cidr_block` property.

[Click to view the list of supported AWS service values](#cidr-blocks-aws-services).

### Subnet-Type Network ACLs

By default, a network ACL will be created for each subnet type included in your `var.subnets` input, which this module refers to as **Subnet-Type** NACLs. The default rules for each are provided in the tables below; to add or modify rules or tags for any of the Subnet-Type NACLs, simply use the NACL's name as a key, and any rules/tags you include will be merged in. User input is given merge precedence, so using any module-provided rule numbers like "100" will result in the rule being overwritten.

**Default Rules: Public_Subnets_NACL**

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

**Default Rules: Private_Subnets_NACL**

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

**Default Rules: IntraOnly_Subnets_NACL**

- Ingress:
  | Rule Num | Protocol | CIDR Block | From Port | To Port | Description |
  | :------: | :------: | :--------: | --------: | ------: | :-------------- |
  | - | - | - | - | - | **Ingress not permitted** |

- Egress:
  | Rule Num | Protocol | CIDR Block | From Port | To Port | Description |
  | :------: | :------: | :--------: | --------: | ------: | :-------------- |
  | - | - | - | - | - | **Egress not permitted** |

### Custom Network ACLs

To create your own NACL, simply use your own custom NACL name as a key in this variable, and then associate subnets with the NACL via the `network_acl` property in your `var.subnets` configs. If all subnets of any given type are assigned to custom NACLs, then the **Subnet-Type** NACL for that type will not be created.

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

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
---

##  Module Usage

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
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
| [aws_security_group_rule.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
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
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Map of network ACL names to config objects. For more info:<br>  - [`Network ACLs` README](#network-acls)<br>  - [Usage example](examples/terragrunt.hcl) | <pre>map(<br>    # map keys: internal NACL "names"<br>    object({<br>      access = optional(object({<br>        ingress = optional(map(<br>          # map keys: quoted rule numbers (e.g., "100")<br>          object({<br>            cidr_block = string<br>            protocol   = optional(string)<br>            port       = optional(number)<br>            from_port  = optional(number)<br>            to_port    = optional(number)<br>          })<br>        ))<br>        egress = optional(map(<br>          # map keys: quoted rule numbers (e.g., "100")<br>          object({<br>            cidr_block = string<br>            protocol   = optional(string)<br>            port       = optional(number)<br>            from_port  = optional(number)<br>            to_port    = optional(number)<br>          })<br>        ))<br>      }))<br>      tags = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | Map of route table names to route table config objects. Peering connection<br>routes can be configured in one of two ways: if VPC is the peering REQUESTER,<br>use "peering\_request\_vpc\_id", otherwise if VPC is the peering ACCEPTER, use<br>"peering\_connection\_id". Custom route tables for PRIVATE subnets can set their<br>default route ("0.0.0.0/0") using "nat\_gateway\_subnet\_cidr", which must be set<br>to the CIDR of a NAT-containing PUBLIC subnet. For more info:<br>  - [`Route Tables` README](#route-tables)<br>  - [Usage example](examples/terragrunt.hcl) | <pre>map(<br>    # map keys: internal route table "names"<br>    object({<br>      routes = optional(map(<br>        # map keys: CIDRs of route destinations<br>        object({<br>          nat_gateway_subnet_cidr      = optional(string)<br>          peering_request_vpc_id       = optional(string)<br>          peering_accept_connection_id = optional(string)<br>        })<br>      ))<br>      tags = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of Security Group names to config objects. For more info:<br>  - [`Security Groups` README](#security\_groups)<br>  - [Usage example](examples/terragrunt.hcl) | <pre>map(<br>    # map keys: security group names<br>    object({<br>      description = string<br>      access = object({<br>        ingress = optional(list(<br>          object({<br>            description            = string<br>            protocol               = optional(string)<br>            port                   = optional(number)<br>            from_port              = optional(number)<br>            to_port                = optional(number)<br>            peer_security_group_id = optional(string)<br>            peer_security_group    = optional(string)<br>            aws_service            = optional(string)<br>            cidr_blocks            = optional(list(string))<br>            self                   = optional(bool)<br>          })<br>        ))<br>        egress = optional(list(<br>          object({<br>            description            = string<br>            protocol               = optional(string)<br>            port                   = optional(number)<br>            from_port              = optional(number)<br>            to_port                = optional(number)<br>            peer_security_group_id = optional(string)<br>            peer_security_group    = optional(string)<br>            aws_service            = optional(string)<br>            cidr_blocks            = optional(list(string))<br>            self                   = optional(bool)<br>          })<br>        ))<br>      })<br>      tags = optional(map(string))<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet CIDRs to subnet config objects. For each subnet, "type"<br>must be either "PUBLIC", "PRIVATE", or "INTRA-ONLY". The properties<br>"map\_public\_ip\_on\_launch" and "contains\_nat\_gateway" both default to<br>false, and have no effect on non-public subnets. Public and private<br>subnets can be configured to use specific route tables and/or NACLs<br>via the "route\_table" and "network\_acl" properties respectively;<br>these have no effect on intra-only subnets. For more info:<br>  - [`Subnets` README](#subnets)<br>  - [Usage example](examples/terragrunt.hcl) | <pre>map(<br>    # map keys: subnet CIDRs<br>    object({<br>      availability_zone       = string<br>      type                    = string<br>      map_public_ip_on_launch = optional(bool)<br>      contains_nat_gateway    = optional(bool)<br>      route_table             = optional(string)<br>      network_acl             = optional(string)<br>      tags                    = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Config object for the VPC. All optional bools default to "true".<br>For more info:<br>  - [`VPC` README](#vpc)<br>  - [Usage example](examples/terragrunt.hcl) | <pre>object({<br>    cidr_block = string<br>    peering_request_vpc_ids = optional(map(<br>      # map keys: peer VPC IDs<br>      object({<br>        peer_vpc_owner_account_id       = optional(string)<br>        peer_vpc_region                 = optional(string)<br>        allow_remote_vpc_dns_resolution = optional(bool)<br>        tags                            = optional(map(string))<br>      })<br>    ))<br>    peering_accept_connection_ids = optional(map(<br>      # map keys: peering connection IDs<br>      object({<br>        allow_remote_vpc_dns_resolution = optional(bool)<br>        tags                            = optional(map(string))<br>      })<br>    ))<br>    enable_dns_support   = optional(bool)<br>    enable_dns_hostnames = optional(bool)<br>    tags                 = optional(map(string))<br>  })</pre> | n/a | yes |

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
| <a name="output_Subnets"></a> [Subnets](#output\_Subnets) | Map of subnet resource objects. |
| <a name="output_VPC"></a> [VPC](#output\_VPC) | The VPC resource object. |
| <a name="output_VPC_Peering_Connection_Accepts"></a> [VPC\_Peering\_Connection\_Accepts](#output\_VPC\_Peering\_Connection\_Accepts) | Map of VPC Peering Connection Accepter resource objects. |
| <a name="output_VPC_Peering_Connection_Options"></a> [VPC\_Peering\_Connection\_Options](#output\_VPC\_Peering\_Connection\_Options) | Map of VPC Peering Connection Options resource objects. |
| <a name="output_VPC_Peering_Connection_Requests"></a> [VPC\_Peering\_Connection\_Requests](#output\_VPC\_Peering\_Connection\_Requests) | Map of VPC Peering Connection resource objects. |

---

## License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

## Contact

<div style="width:75%; display:flex; flex-direction:row; align-items:center; justify-content:space-between;">
  <img src="https://avatars.githubusercontent.com/u/43518091?v=4" style="height:50px; width:50px; border-radius:50% 50% 50% 50%;" alt="avatar" />
  <span>
    <span>Trevor Anderson</span>
    <span> - </span>
    <a href="https://twitter.com/teerevtweets">@TeeRevTweets</a>
    <span> - </span>
    <span>T.AndersonProperty@gmail.com</span>
  </span>
  <div style="height:auto;">
    <br> <!-- bump the LinkedIn btn down to be centered inline -->

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/trevor-anderson-3a3b0392/)

  </div>
</div>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
