# AWS Landing Zone

Terraform module for defining a multi-account AWS Landing Zone.

---

## AWS Organization

TODO add quick paragraph about aws orgs

<!-- Below paragraph is from main.Organizations.tf OUs locals block -->

To avoid CYCLE ERRORs in nested organizational_unit resources,
we need to have separate resource blocks - one for each nesting depth
within the organization's structure. AWS allows organizations to have a
maximum nesting depth of 5, which includes the root account as well as
account leaf-nodes within the org tree. Therefore, our implementation
can provide 3 OU nesting levels:
Level_1 --> OUs that are direct children of root
Level_2 --> OUs that are direct children of L1 OUs
Level_3 --> OUs that are direct children of L2 OUs

#### Trusted AWS Service Principals

You can use trusted access to enable a supported AWS service that you specify, called the trusted service, to perform tasks in your organization and its accounts on your behalf. This involves granting permissions to the trusted service but does not otherwise affect the permissions for IAM users or roles. When you enable access, the trusted service can create an IAM role called a service-linked role in every account in your organization whenever that role is needed. That role has a permissions policy that allows the trusted service to do the tasks that are described in that service's documentation. This enables you to specify settings and configuration details that you would like the trusted service to maintain in your organization's accounts on your behalf. The trusted service only creates service-linked roles when it needs to perform management actions on accounts, and not necessarily in all accounts of the organization.

For more info, please review the [list of AWS services][org-services] which work with AWS Organizations.

#### Policy Types

There are four values that can be included in var.organization_config.enabled_policy_types:

- AISERVICES_OPT_OUT_POLICY
- BACKUP_POLICY
- SERVICE_CONTROL_POLICY
- TAG_POLICY

TODO expand above explainer

#### Service Control Policies

TODO add info on our SCPs

#### Management Policies

TODO add info on our mgmt policies

## AWS SSO

TODO explain our sso setup

---

## License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

## Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - T.AndersonProperty@gmail.com

[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[org-services]: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
[linkedin-url]: https://www.linkedin.com/in/trevor-anderson-3a3b0392/
[linkedin-shield]: https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white
