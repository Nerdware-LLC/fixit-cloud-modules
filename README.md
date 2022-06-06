# Fixit Cloud ☁️ MODULES

Terraform modules for defining Fixit Cloud architecture.

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

**Check out the [fixit-cloud-live][fixit-cloud-live] repo to view the Terragrunt files which implement these modules.**

--

### Available Modules:

- AWS
  - [Account Baseline](AWS_AccountBaseline/README.md)
  - [CloudFront](AWS_CloudFront/README.md)
  - [EC2](AWS_EC2/README.md)
  - [ECS Cluster](AWS_ECS_Cluster/README.md)
  - [GuardDuty](AWS_GuardDuty/README.md)
  - [IAM](AWS_IAM/README.md)
  - [KMS](AWS_KMS/README.md)
  - [Lambda](AWS_Lambda/README.md)
  - [OpenID Connect Providers](AWS_OpenID_Connect_Providers/README.md)
  - [Organization](AWS_Organization/README.md)
  - [S3](AWS_S3/README.md)
  - [SecurityHub](AWS_SecurityHub/README.md)
  - [SSO](AWS_SSO/README.md)
  - [VPC](AWS_VPC/README.md)
- Terraform Cloud
  - [Workspaces](TFC_Workspaces/README.md)

## Developer Setup

<!-- TODO replace below w something like that in FCL. Also don't forget to add 'tfsec-checkgen' and 'terraform-docs' installs (see dev-env-repo). -->

1. Clone the project into your local filesystem:
   ```shell
   git clone git@github.com:Nerdware-LLC/fixit-cloud-modules.git
   ```
2. Ensure [**pre-commit**](https://pre-commit.com/#install) is installed locally.
3. Run `pre-commit install` to ensure local .git hooks are present.
4. If developing alongside the **fixit-cloud-live** companion repo (recommended), install relevant binaries:
   - TFLint:
   ```shell
   curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
   ```
   - TFSec:
   ```shell
   wget https://github.com/aquasecurity/tfsec/releases/download/v0.63.1/tfsec-linux-amd64
   ```
5. Profit 💰💰💰

TFLint Rules Docs
https://github.com/terraform-linters/tflint/tree/master/docs/rules

TFSec Docs
https://github.com/aquasecurity/tfsec

Note: All custom TFSec custom rules must end in `_tfchecks.yaml/json`

## License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [T.AndersonProperty@gmail.com](mailto:T.AndersonProperty@gmail.com)

  <a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/YouTube_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/trevor-anderson-3a3b0392/">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/LinkedIn_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="https://twitter.com/TeeRevTweets">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/Twitter_icon_circle.svg" height="40" />
  </a>
  &nbsp;
  <a href="mailto:T.AndersonProperty@gmail.com">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/email_icon_circle.svg" height="40" />
  </a>
  <br><br>

  <a href="https://daremightythings.co/">
    <strong><i>Dare Mighty Things.</i></strong>
  </a>

</div>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[fixit-cloud-live]: https://github.com/Nerdware-LLC/fixit-cloud-live
