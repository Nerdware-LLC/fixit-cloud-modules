# Custom TFSec Checks

All custom TFSec custom rules must end in `_tfchecks.yaml/json` and be placed in this dir.

TFSec documentation for custom checks is available [here][custom_tfsec_docs_url].

**Current Custom Rules:**

- [EBS Encrypt by Default](./ebs_encrypt_by_default_tfchecks.yaml)
- [EC2 user_data Content](./ec2_user_data_content_tfchecks.yaml)

<!-- LINKS -->

[custom_tfsec_docs_url]: https://aquasecurity.github.io/tfsec/v1.23.3/guides/configuration/custom-checks/
