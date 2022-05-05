# Fixit Cloud ☁️ MODULES

Terraform modules for defining Fixit Cloud architecture.

[![pre-commit][pre-commit-shield]](https://github.com/pre-commit/pre-commit)

**Check out the [fixit-cloud-live][fixit-cloud-live] repo to view the Terragrunt files which implement these modules.**

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
