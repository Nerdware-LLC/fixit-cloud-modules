######################################################################
### INPUT VARIABLES

variable "sns_topics" {
  description = <<-EOF
  Map of SNS Topic names to config objects. "policy_statements" must map
  SNS Topic Policy statement SIDs to statement config objects. Common
  policy_statements inputs are available in the [Usage Examples](#usage-examples)
  section of the README.

  Use "kms_master_key_id" to enable topic SSE. "is_fifo_topic" and
  "enable_content_based_deduplication" both default to "false".

  Use "message_delivery_reporting" to configure Topics to send message delivery
  success/failure info to CloudWatch Logs for the five supported types of SNS
  endpoints: HTTP, SQS, Kinesis Firehose, Lambda, and Application. The IAM
  service roles specified in the "_role_arn" properties must provide the SNS
  service principal ("sns.amazonaws.com") with the permission necessary to write
  the logs to the desired CloudWatch Logs log group. A custom sampling rate can
  also be specified as an integer representing the percentage of successful
  messages for which CloudWatch Logs will be provided; this defaults to "100"
  if not provided.
  EOF

  type = map(
    # map keys: SNS Topic names
    object({
      policy_statements = map(
        # map keys: policy statement SIDs
        object({
          effect = string
          principals = object({
            type        = string
            identifiers = list(string)
          })
          actions = list(string)
          conditions = optional(map(
            # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")
            object({
              key    = string
              values = list(string)
            })
          ))
        })
      )

      delivery_policy_json               = optional(string)
      display_name                       = optional(string)
      kms_master_key_id                  = optional(string)
      is_fifo_topic                      = optional(bool) # Default: false
      enable_content_based_deduplication = optional(bool) # Default: false
      tags                               = optional(map(string))

      message_delivery_reporting = optional(object({
        application = optional(object({
          success_role_arn = optional(string)
          failure_role_arn = optional(string)
          sample_rate      = optional(number)
        }))
        http = optional(object({
          success_role_arn = optional(string)
          failure_role_arn = optional(string)
          sample_rate      = optional(number)
        }))
        sqs = optional(object({
          success_role_arn = optional(string)
          failure_role_arn = optional(string)
          sample_rate      = optional(number)
        }))
        kinesis_firehose = optional(object({
          success_role_arn = optional(string)
          failure_role_arn = optional(string)
          sample_rate      = optional(number)
        }))
        lambda = optional(object({
          success_role_arn = optional(string)
          failure_role_arn = optional(string)
          sample_rate      = optional(number)
        }))
      }))
    })
  )
}

#---------------------------------------------------------------------

variable "sns_topic_subscriptions" {
  description = <<-EOF
  List of SNS Topic Subscription config objects. "endpoint" describes
  where to send topic data, the format of which is determined by the
  "protocol" a subscription uses. "protocol" must be either "sqs", "sms",
  "lambda", "firehose", "application", "email", "email-json", "http", or
  "https". Please refer to the [SNS Topic Subscription Protocols](#sns-topic-subscription-protocols)
  section in the README for details regarding each type of "protocol".
  "topic" can either be a topic "name", if the Topic is being managed
  within the same module call, or a topic ARN if the Topic is managed
  externally. For more info, please refer to the links provided in the
  [Useful Links](#useful-links) section of the README.
  EOF

  type = list(
    object({
      endpoint                        = string
      protocol                        = string
      topic                           = string
      kinesis_delivery_iam_role_arn   = optional(string)
      confirmation_timeout_in_minutes = optional(number)
      delivery_policy_json            = optional(string)
      filter_policy_json              = optional(string)
      redrive_policy_json             = optional(string)
      endpoint_auto_confirms          = optional(bool) # Default: false
      enable_raw_message_delivery     = optional(bool) # Default: false
    })
  )
  default = []
}

######################################################################
