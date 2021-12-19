# Fixit Cloud ☁️ MODULE: AWS Account Baseline

TODO add AccountBaseline module info here

### Enabling REGIONAL Services in All Regions

AWS-Config, GuardDuty, and Security Hub are all REGIONAL services that need to be enabled globally in all available AWS regions. To do this, there are broadly-speaking two options: we can handle the regional separation in the LIVE repo, or the MODULES repo.

1. **IN THE LIVE REPO**, we'd create a region-dir for every region in every account, each with a Config/GuardDuty/SecHub "leaf-node" resource dir. The downside is that this would bloat the size of the LIVE repo which contains the Terragrunt configs, AND since each resource "leaf-node" in the LIVE repo gets its own TF-Cloud workspace, this would also greatly increase the number of workspaces (7 accounts × 17 regions × 3 targeted-services = 357 workspaces!).

2. **IN THE MODULES REPO**, we'd use provider config aliases, 1 per region. This would allow us to keep the LIVE repo in a shape that more closely reflects our operating infrastructure and keeps us from having to generate 119 workspaces each just for Config/GuardDuty/SecHub. However, since a resource "provider" meta-argument MUST be a literal value - not an expression nor interpolated value - this necessitates a lot of copy+paste for certain resources related to [AWS Config](/AWS_AccountBaseline/main.AWS_Config.tf), [GuardDuty](/AWS_AccountBaseline/main.GuardDuty.tf), and [Security Hub](/AWS_AccountBaseline/main.SecurityHub.tf).

At this time, we're going to opt for option 2 until a DRYer alternative solution can be implemented.

### Default Network Resources

TODO expand explanations in this section

##### Default VPC

Each account gets 1 default VPC. If the default VPC is deleted, it cannot be re-created.

##### Default Subnets

Each default VPC comes with 1 default subnet per availability zone in the region. In accordance with best practices, these default subnets should all be deleted. Unfortunately, this cannot be done via Terraform, so the deletion of default subnets must be done manually via the console.

##### Default Route Table

The "Main" route table can't be deleted.

##### Default Network ACL

Every VPC has 1 default network ACL which cannot be deleted. All ingress/egress rules should be stripped from it to prevent unintentional network access.

##### Default Security Group

Can't be deleted.

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
