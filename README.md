<div align="center">

  <a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
    <img src="/.github/assets/FCM_repo_banner.png" height="200" />
  </a>
  <br><br>

Terraform modules for defining opinionated AWS and Terraform Cloud architecture.

[![pre-commit][pre-commit-shield]](https://github.com/pre-commit/pre-commit)
[![semantic-release][semantic-shield]](https://github.com/semantic-release/semantic-release)
[![license][license-shield]](/LICENSE)

</div>

---

### 🧱 Available Modules

- AWS
  - [Account Baseline](AWS_AccountBaseline/README.md)
  - [AWS Config](AWS_Config/README.md)
  - [ECS Cluster](AWS_ECS_Cluster/README.md)
  - [GuardDuty](AWS_GuardDuty/README.md)
  - [IAM](AWS_IAM/README.md)
  - [KMS](AWS_KMS/README.md)
  - [Lambda](AWS_Lambda/README.md)
  - [OpenID Connect Providers](AWS_OpenID_Connect_Providers/README.md)
  - [Organization](AWS_Organization/README.md)
  - [S3](AWS_S3/README.md)
  - [SecurityHub](AWS_SecurityHub/README.md)
  - [VPC](AWS_VPC/README.md)
- Terraform Cloud
  - [Workspaces](TFC_Workspaces/README.md)

### 🚧 Modules in the Pipeline

The following modules have WIP feature branches which will be merged into the **main** branch upon PR review and acceptance. Resources contained in these modules reflect either a refactoring of existing modules, whereby resources commonly used by several modules are extracted and isolated into their own separate module, or resources which are entirely new to the FCM collection.

| **Module**     | **Branch**          | **Description**                                                        |
| :------------- | :------------------ | :--------------------------------------------------------------------- |
| AWS CloudFront | feat/AWS_CloudFront | AWS CloudFront resources; currently CloudFront resources are embedded. |
| AWS SNS        | feat/AWS_SNS        | AWS SNS resources isolated in their own separate module.               |

## ⚙️ Developer Setup

```bash
# Clone the project into your local filesystem
git clone git@github.com:Nerdware-LLC/fixit-cloud-modules.git

# Ensure pre-commit is installed (more info: https://pre-commit.com/#install)
pip3 install pre-commit

# Ensure pre-commit git hooks are in place
pre-commit install

# Ensure TFLint is installed (more info: https://github.com/terraform-linters/tflint#readme)
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Ensure TFSec is installed.
go install github.com/aquasecurity/tfsec/cmd/tfsec@latest
# Here we use go, but other methods are available at the link below.
# https://aquasecurity.github.io/tfsec/v1.23.3/guides/installation/
```

## 🛡️ Custom TFSec Checks

All custom TFSec custom rules must end in `_tfchecks.yaml/json` and be placed in [the /.tfsec dir](/.tfsec/README.md).

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [Trevor@Nerdware.cloud](mailto:trevor@nerdware.cloud)

  <a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
    <img src="/.github/assets/YouTube_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/meet-trevor-anderson/">
    <img src="/.github/assets/LinkedIn_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://twitter.com/TeeRevTweets">
    <img src="/.github/assets/Twitter_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="mailto:trevor@nerdware.cloud">
    <img src="/.github/assets/email_icon_circle.svg" height="40" />
  </a>
  <br><br>

  <a href="https://daremightythings.co/">
    <strong><i>Dare Mighty Things.</i></strong>
  </a>

</div>

<!-- LINKS -->

[pre-commit-shield]: https://img.shields.io/badge/pre--commit-33A532.svg?logo=pre-commit&logoColor=F8B424&labelColor=gray
[semantic-shield]: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-E10079.svg
[license-shield]: https://img.shields.io/badge/license-Proprietary-000080.svg?labelColor=gray
[fixit-cloud-live]: https://github.com/Nerdware-LLC/fixit-cloud-live
