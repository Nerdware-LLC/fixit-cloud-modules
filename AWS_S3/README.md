<h1>Fixit Cloud ☁️ MODULE: AWS S3</h1><!-- html h1, to exclude from auto-ToC -->

Terraform module for defining an S3 Bucket with [opinionated configurations](#opinionated-security-configurations) that reflect security best-practices as well as sensible cost-reduction strategies.

<h2>Table of Contents</h2>

- [Lifecycle Rules vs MFA-Delete](#lifecycle-rules-vs-mfa-delete)
  - [Solution A: Emulating S3 Lifecycle Rules](#solution-a-emulating-s3-lifecycle-rules)
  - [Solution B: Emulating S3 MFA-Delete](#solution-b-emulating-s3-mfa-delete)
- [Opinionated Security Configurations](#opinionated-security-configurations)
  - [`Object Ownership: "BucketOwnerEnforced"`](#object-ownership-bucketownerenforced)
  - [`Block Public Access`](#block-public-access)
  - [`Bucket Versioning: "Enabled"`](#bucket-versioning-enabled)
  - [`Object Lock: "Enabled"`](#object-lock-enabled)
  - [`Server-Side Encryption`](#server-side-encryption)
    - [Comparison: SSE-S3 vs SSE-KMS](#comparison-sse-s3-vs-sse-kms)
  - [`Bucket Key: "Enabled"`](#bucket-key-enabled)
- [⚙️ Module Usage](#️-module-usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)
- [Contributing / Roadmap](#contributing--roadmap)

## Lifecycle Rules vs MFA-Delete

AWS does not currently offer the ability for S3 buckets to have both lifecycle-rule configurations and MFA-delete enabled. This mutual exclusivity ostensibly presents users with a truly difficult tradeoff: automated cost-saving functionality on the one hand, and security best-practices on the other. However, with a little elbow grease we can _emulate_ these features, thereby allowing us to have our cost-saving cake and securely eat it too. To help determine which feature to natively enable and which to emulate, consider the solutions outlined below.

### Solution A: Emulating S3 Lifecycle Rules

Two AWS/S3-native utilities offer a close facsimile to lifecycle-rule configs: AWS Lambda Functions, and S3 Batch Operations.

<!-- TODO write more on emulating s3 lifecycle rules-->

### Solution B: Emulating S3 MFA-Delete

For many organizations, MFA-delete is almost certainly the simplest to emulate, since requiring MFA for delete operations can (with caveats) be achieved via the use of the "aws:MultiFactorAuthPresent" condition key in bucket-policy statements like the example below. However, **_the "aws:MultiFactorAuthPresent" condition key is not present in requests made using long-term credentials_**. If long-term credentials are not prohibited by account/organization policies, the below example can be amended to use "BoolIfExists" rather than "Bool", but such a configuration obviously opens the door to non-MFA delete operations via the use of long-term credentials.

<details>
  <summary><strong>Example Bucket-Policy with "aws:MultiFactorAuthPresent" Condition Key</strong></summary>

```json
{
  "Effect": "Deny",
  "Principal": { "AWS": "*" },
  "Action": ["s3:DeleteObject", "s3:DeleteObjectVersion"],
  "Resource": "arn:aws:s3:::example_bucket/*",
  "Condition": {
    "Bool": {
      //
      // Using "Bool" instead of "BoolIfExists" will ensure that MFA is always used. However, be aware
      // that since the MFA condition keys are NOT present on requests made using long-term credentials,
      // this will cause any "s3:DeleteObject" calls made using long-term credentials to fail.
      //
      "aws:MultiFactorAuthPresent": "false", // Checks whether MFA was used to validate the request credentials.
      "aws:MultiFactorAuthAge": 3600 // Optionally specify a max age on the request credentials, in seconds.
    }
  }
}
```

</details>

Another potential issue with emulating MFA-delete would be the constant triggering of **SecurityHub** findings related to the standard **CIS AWS Foundations Benchmark # 2.1.3, "Ensure MFA Delete is enabled on S3 buckets"**. If permitted, the command below can be used to disable findings related to this benchmark. However, additional measures would then need to be taken to ensure that every S3 is created with the "aws:MultiFactorAuthPresent" condition key in its bucket policy.

```bash
aws securityhub update-standards-control \
  --standards-control-arn "arn:aws:securityhub:REGION:ACCOUNT_NUM:control/cis-aws-foundations-benchmark/v/1.2.0/2.1.3*" \
  --control-status "DISABLED" \
  --disabled-reason "MFA-delete is enforced by S3 bucket policies."
```

---

## Opinionated Security Configurations

### `Object Ownership: "BucketOwnerEnforced"`

Before S3 bucket policies and object-ownership controls, access control lists were the primary means of controlling access to buckets/objects. Since ACLs offer less functionality and flexibility (e.g., ALLOW but no DENY), this module implements the "BucketOwnerEnforced" Object-Ownership control setting for all buckets, thereby providing guaranteed object ownership to the bucket owner, while also requiring the burden of access-control be managed by _policy_ mechanisms which feature greater utility, such as S3 bucket policies, IAM policies, VPC endpoint policies, and AWS Organizations SCPs.

**Relevant Security Standards:**

- AWS Foundational Security Best Practices
  - [[S3.12] S3 access control lists (ACLs) should not be used to manage user access to buckets](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-s3-12)

### `Block Public Access`

This is comprised of a group of four settings:

1. `block_public_acls: true`
2. `block_public_policy: true`
3. `restrict_public_buckets: true`
4. `ignore_public_acls: true`

As stated in _CIS Amazon Web Services Foundations Benchmark v1.4.0, #2.1.5_:

> Amazon S3 provides Block Public Access to help you manage public access to Amazon S3 resources. By default, S3 buckets and objects are created with public access disabled. However, an IAM principal with sufficient S3 permissions can enable public access at the bucket and/or object level. While enabled, Block Public Access prevents an individual bucket, and its contained objects, from becoming publicly accessible. Amazon S3 Block Public Access prevents the accidental or malicious public exposure of data contained within the respective bucket(s).

### `Bucket Versioning: "Enabled"`

<!-- TODO explain why bucket versioning is enabled. -->

### `Object Lock: "Enabled"`

<!-- TODO explain why object lock is enabled. -->

### `Server-Side Encryption`

Server-side encryption by default is enforced for all buckets. Users may choose to use S3-managed keys (SSE-S3), or use their own KMS key (SSE-KMS).

> Whichever method is used,

<!-- TODO See TODOs in /TODO_custom_tfsec_rules.md, expand on those here in this README -->

#### Comparison: SSE-S3 vs SSE-KMS

| **Factor**                  | **SSE-S3** | **SSE-KMS**                         |
| :-------------------------- | :--------- | :---------------------------------- |
| Cost                        | Almost $0  | KMS-related charges                 |
| Management Overhead         | None       | KMS-related permissions             |
| Can Audit                   | NO         | YES                                 |
| Cross-Account Object Access | NO         | YES, if permitted by the key policy |

**Cost:** Requests to configure the default encryption feature incur standard Amazon S3 request charges. According to [AWS S3 pricing data](https://aws.amazon.com/s3/pricing/), the price of such requests for a Standard-class S3 in the us-east-2 region runs $0.0004 per 1,000 requests.

### `Bucket Key: "Enabled"`

<!-- TODO explain why bucket key is enabled. -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-start -->

---

## ⚙️ Module Usage

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.5 |
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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_cors_configuration.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_object_lock_configuration.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_config"></a> [access\_logs\_config](#input\_access\_logs\_config) | Config object for logging bucket access events. This variable should<br>only be excluded if the bucket being created will itself be designated<br>to receive access logs from other buckets (in which case, do not provide<br>a value for var.sse\_kms\_config - access logs buckets must use SSE-S3).<br>"bucket\_name" must be the name of an existing S3 bucket to which to send<br>access logs. By default, "access\_logs\_prefix" will be set to the<br>var.bucket\_name value. | <pre>object({<br>    bucket_name        = string<br>    access_logs_prefix = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket. Warning: this value cannot be changed<br>after bucket creation - changing this input will therefore force<br>the creation of a new bucket. The list of bucket-naming rules is<br>available at the link below.<br>https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html. | `string` | n/a | yes |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | A JSON-encoded string which can be properly decoded into a valid IAM<br>bucket policy for the bucket. | `string` | n/a | yes |
| <a name="input_bucket_tags"></a> [bucket\_tags](#input\_bucket\_tags) | The tags of the S3 bucket. | `map(string)` | `null` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | Config map for CORS rules; map rule IDs/names to objects which define<br>them. The map keys (rule IDs/names) cannot be longer than 255 characters.<br>For "allowed\_methods", valid values are GET, PUT, HEAD, POST, and DELETE.<br>HTTP headers included in "allowed\_headers" will be specified in the<br>"Access-Control-Request-Headers" header. "max\_age\_seconds" sets the time<br>in seconds that a browser is to cache the preflight response for the<br>specified resource. | <pre>map(object({<br>    allowed_methods = list(string)<br>    allowed_origins = list(string)<br>    allowed_headers = optional(list(string))<br>    expose_headers  = optional(list(string))<br>    max_age_seconds = number<br>  }))</pre> | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Map of lifecycle rule config objects. If the bucket must utilize the<br>MFA-delete feature, simply exclude this variable. Each key should be<br>the name of a lifecycle rule with a value set to an object with rule<br>config properties. Please refer to the relevant resource docs (link<br>below) in TF Registry for info regarding the available rule params:<br>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration#argument-reference. | <pre>map(object({<br>    # Use rule names for map keys<br>    filter = optional(object({<br>      prefix                   = optional(string)<br>      object_size_greater_than = optional(number) # Min size in bytes to which the rule applies.<br>      object_size_less_than    = optional(number) # Max size in bytes to which the rule applies.<br>      tag                      = optional(object({ key = string, value = string }))<br>      and = optional(object({<br>        prefix                   = optional(string)<br>        object_size_greater_than = optional(number)<br>        object_size_less_than    = optional(number)<br>        tags                     = optional(map(string))<br>      }))<br>    }))<br>    abort_incomplete_multipart_upload = optional(object({<br>      days_after_initiation = number<br>    }))<br>    transition = optional(object({<br>      date          = optional(string) # If provided, must be in RFC 3339 format.<br>      days          = optional(number) # If provided, must a non-zero positive integer.<br>      storage_class = string<br>    }))<br>    expiration = optional(object({<br>      date                         = optional(string)<br>      days                         = optional(number)<br>      expired_object_delete_marker = optional(bool)<br>    }))<br>    noncurrent_version_transition = optional(object({<br>      newer_noncurrent_versions = optional(number)<br>      noncurrent_days           = optional(number)<br>      storage_class             = string<br>    }))<br>    noncurrent_version_expiration = optional(object({<br>      newer_noncurrent_versions = optional(number)<br>      noncurrent_days           = optional(number)<br>    }))<br>    status = optional(string) # Defaults to "Enabled", can optionally pass "Disabled".<br>  }))</pre> | `null` | no |
| <a name="input_mfa_delete_config"></a> [mfa\_delete\_config](#input\_mfa\_delete\_config) | Config object for the MFA-delete feature. If the bucket will instead<br>enable the lifecycle-rule configs feature, simply exclude this variable. | <pre>object({<br>    auth_device_serial_number = string<br>    auth_device_code_value    = string<br>  })</pre> | `null` | no |
| <a name="input_object_lock_default_retention"></a> [object\_lock\_default\_retention](#input\_object\_lock\_default\_retention) | Config object to set the bucket's default object-lock retention policy.<br>The "mode" property can be either "COMPLIANCE" or "GOVERNANCE". For the<br>retention period duration, supply a number to either "days" or "years",<br>but not both. | <pre>object({<br>    mode  = string<br>    days  = optional(number)<br>    years = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_replication_config"></a> [replication\_config](#input\_replication\_config) | Config object for replication of bucket objects. For the "rules" property, map each<br>rule name to an object configuring the rule. Rule names must be less than or equal<br>to 255 characters.<br><br>Rule Properties: Each rule's "priority" should be a number unique among all provided<br>rules; these numbers determine which rule's filter takes precedence, with higher<br>numbers taking priority (if no rules contain filters, "priority" values have no effect).<br>"is\_enabled" defaults to "true" if not provided. The "should\_replicate ..." properties<br>all default to "true" if not provided.<br><br>Destination Properties: In the "destination" config, "should\_destination\_become\_owner"<br>defaults to "true" if not provided. "should\_enable\_metrics" defaults to "false"; if<br>metrics are enabled, the S3 service will send replication metrics to CloudWatch. If the<br>destination bucket uses SSE-KMS, the ARN of the dest bucket's encryption key must be<br>provided via the "replica\_kms\_key\_arn" property. "should\_replication\_complete\_within\_15\_minutes"<br>defaults to "false"; when set to "true", the S3 service will create S3 Event Notifications<br>if the replication process fails and/or takes longer than 15 minutes (the amount of time<br>is not currently customizable). By default, if "storage\_class" is not specified, the S3<br>service uses the storage class of the source object to create the replica; valid override<br>values are "STANDARD\_IA", "INTELLIGENT\_TIERING", "ONEZONE\_IA", "GLACIER\_IR", "GLACIER",<br>and "DEEP\_ARCHIVE". | <pre>object({<br>    s3_replication_service_role_arn = string<br>    rules = map(object({<br>      priority                           = number<br>      is_enabled                         = optional(bool)<br>      should_replicate_delete_markers    = optional(bool)<br>      should_replicate_existing_objects  = optional(bool)<br>      should_replicate_encrypted_objects = optional(bool)<br>      filter = optional(object({<br>        prefix = optional(string)<br>        tag    = optional(object({ key = string, value = string }))<br>        and = optional(object({<br>          prefix = optional(string)<br>          tags   = optional(map(string))<br>        }))<br>      }))<br>      destination = object({<br>        account                                       = optional(string)<br>        bucket_arn                                    = string<br>        storage_class                                 = optional(string)<br>        replica_kms_key_arn                           = optional(string) # dest bucket SSE-KMS key ARN<br>        should_destination_become_owner               = optional(bool)<br>        should_enable_metrics                         = optional(bool)<br>        should_replication_complete_within_15_minutes = optional(bool)<br>      })<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_sse_kms_config"></a> [sse\_kms\_config](#input\_sse\_kms\_config) | Config object to utilize an existing KMS key for server-side encryption<br>(SSE-by-default is enabled on all buckets created by this module). If not<br>provided, the AWS-managed SSE-S3 key will be used instead. If a KMS key<br>ARN is provided, it is highly recommended to permit the bucket to use<br>the key as a Bucket-Key, thereby reducing KMS-related costs by more than<br>90% on average. This is not enforced by default, however, since enabling<br>the Bucket-Key feature may require refactoring of the KMS key policy (S3<br>encryption context conditions for Bucket-Keys must point to the ARN of<br>the BUCKET - not the ARN of OBJECTS, as is the case for non-Bucket-Key<br>SSE-KMS keys). A KMS key alias may be provided in lieu of an ARN, but this<br>is highly discouraged if the bucket may be used in cross-account operations,<br>as the KMS service will resolve the key within the REQUESTER'S account,<br>which can result in data encrypted with a KMS key that belongs to the<br>requester, and not the bucket administrator. Please be aware that SSE-KMS<br>may NOT be used for access-logs buckets. | <pre>object({<br>    key_arn                  = string<br>    should_enable_bucket_key = bool<br>  })</pre> | `null` | no |
| <a name="input_transfer_acceleration"></a> [transfer\_acceleration](#input\_transfer\_acceleration) | Set to "Enabled" to enable transfer acceleration. May also be set to<br>"Suspended" after transfer acceleration has been enabled to temporarily<br>turn off transfer acceleration. | `string` | `null` | no |
| <a name="input_web_host_config"></a> [web\_host\_config](#input\_web\_host\_config) | Config object for setting up the bucket as a web host. Either "routing" OR<br>"redirect\_all\_requests\_to" must be specified, but not both. The property<br>"routing.redirect\_rules", if provided, must map names of routing-rules to<br>objects which define them. The "replace" property may use either "key\_with"<br>OR "key\_prefix\_with", but not both. The two "protocol" properties can be<br>either "http" or "https"; if not provided (null) the default behavior will<br>be to use the protocol used in the original request. | <pre>object({<br>    routing = optional(object({<br>      index_document = string<br>      error_document = optional(string)<br>      redirect_rules = optional(map(object({<br>        host_name          = optional(string) # The host name to use in the redirect request<br>        protocol           = optional(string) # http / https / null<br>        http_redirect_code = optional(string) # The HTTP redirect code to use on the response<br>        replace = optional(object({<br>          key_prefix_with = optional(string) # docs/ --> documents/<br>          key_with        = optional(string) # foo.html --> error.html<br>        }))<br>        condition = optional(object({<br>          http_error_code_returned_equals = optional(string) # "404"<br>          key_prefix_equals               = optional(string) # docs/<br>        }))<br>      })))<br>    }))<br>    redirect_all_requests_to = optional(object({<br>      host_name = string<br>      protocol  = optional(string) # http / https / null<br>    }))<br>  })</pre> | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_S3_Bucket"></a> [S3\_Bucket](#output\_S3\_Bucket) | The S3 bucket resource. |
| <a name="output_S3_Bucket_CORS_Config"></a> [S3\_Bucket\_CORS\_Config](#output\_S3\_Bucket\_CORS\_Config) | The S3 bucket CORS config resource. |
| <a name="output_S3_Bucket_Lifecycle_Config"></a> [S3\_Bucket\_Lifecycle\_Config](#output\_S3\_Bucket\_Lifecycle\_Config) | Map of S3 bucket lifecycle rule config resources. |
| <a name="output_S3_Bucket_Logging_Config"></a> [S3\_Bucket\_Logging\_Config](#output\_S3\_Bucket\_Logging\_Config) | The S3 bucket access logging config resource. |
| <a name="output_S3_Bucket_Object_Lock_Default_Retention_Config"></a> [S3\_Bucket\_Object\_Lock\_Default\_Retention\_Config](#output\_S3\_Bucket\_Object\_Lock\_Default\_Retention\_Config) | The S3 bucket's object-lock default retention config resource. |
| <a name="output_S3_Bucket_Policy"></a> [S3\_Bucket\_Policy](#output\_S3\_Bucket\_Policy) | The S3 bucket policy resource. |
| <a name="output_S3_Bucket_Public_Access_Block"></a> [S3\_Bucket\_Public\_Access\_Block](#output\_S3\_Bucket\_Public\_Access\_Block) | The S3 bucket public access block config resource. |
| <a name="output_S3_Bucket_Replication_Config"></a> [S3\_Bucket\_Replication\_Config](#output\_S3\_Bucket\_Replication\_Config) | The S3 bucket replication config resource. |
| <a name="output_S3_Bucket_SSE_Config"></a> [S3\_Bucket\_SSE\_Config](#output\_S3\_Bucket\_SSE\_Config) | The S3 bucket SSE config resource. |
| <a name="output_S3_Bucket_Transfer_Acceleration_Config"></a> [S3\_Bucket\_Transfer\_Acceleration\_Config](#output\_S3\_Bucket\_Transfer\_Acceleration\_Config) | The S3 bucket transfer acceleration config resource. |
| <a name="output_S3_Bucket_Versioning_Config"></a> [S3\_Bucket\_Versioning\_Config](#output\_S3\_Bucket\_Versioning\_Config) | The S3 bucket versioning config resource. |
| <a name="output_S3_Bucket_Web_Host_Config"></a> [S3\_Bucket\_Web\_Host\_Config](#output\_S3\_Bucket\_Web\_Host\_Config) | The S3 bucket web host config resource. |
| <a name="output_S3_Buket_Ownership_Controls"></a> [S3\_Buket\_Ownership\_Controls](#output\_S3\_Buket\_Ownership\_Controls) | The S3 bucket ownership controls config resource. |

---

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center" style="margin-top:30px;">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [trevor@nerdware.cloud](mailto:trevor@nerdware.cloud)

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
  <a href="mailto:trevor@nerdware.cloud">
    <img src="https://github.com/trevor-anderson/trevor-anderson/blob/main/assets/email_icon_circle.svg" height="40" />
  </a>
  <br><br>

  <a href="https://daremightythings.co/">
    <strong><i>Dare Mighty Things.</i></strong>
  </a>

</div>
<!-- prettier-ignore-end -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

---

## Contributing / Roadmap

As both AWS S3 and associated Terraform resources change over time, so too must this module. If you don't yet see a feature you'd like, feel free to drop a [pull request](https://github.com/Nerdware-LLC/fixit-cloud-modules/pulls). Please note, however, that features which run contrary to the module's [opinionated configs](#opinionated-security-configurations) will _not_ be implemented unless a fundamental change has been implemented by AWS or Terraform in the underlying services/components which significantly alters the circumstances behind the reasoning for a given config.

**Features in the Pipeline:**

- S3 Bucket Analytics Config
- S3 Bucket Intelligent-Tiering Config
- S3 Bucket Inventory Config
- S3 Bucket Metrics
- S3 Bucket Notifications
- S3 Objects/Object-Copies
