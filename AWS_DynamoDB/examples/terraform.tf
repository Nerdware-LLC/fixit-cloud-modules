######################################################################
### EXAMPLE USAGE: AWS_DynamoDB

module "Foo_DynamoDB_SSE_KMS_Keys" {
  /* Foo_DynamoDB_SSE_KMS_Keys module inputs */
}

module "Foo_Kinesis_Stream" {
  /* Foo_Kinesis_Stream module inputs */
}

module "AWS_DynamoDB" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_DynamoDB"

  table_name = "My_DynamoDB_Table"
  hash_key   = "ID"
  range_key  = "Name"

  attributes = [
    {
      name = "ID"
      type = "N"
    },
    {
      name = "Name"
      type = "S"
    },
    {
      name = "HighScore"
      type = "N"
    }
  ]

  global_secondary_indexes = {
    HighScoreGlobalIndex = {
      hash_key           = "Name"
      range_key          = "HighScore"
      projection_type    = "INCLUDE"
      non_key_attributes = ["ID"]
      capacity = {
        read = {
          max    = 10
          target = 7
          min    = 5
        }
        write = {
          max    = 10
          target = 8
          min    = 5
        }
      }
    }
  }

  server_side_encryption_kms_key_arn = (
    # In this example, "us-west-1" is the region with the base table
    module.Foo_DynamoDB_SSE_KMS_Keys.keys_by_table_region["us-west-1"].arn
  )

  billing_mode = "PROVISIONED" # <-- default
  capacity = {
    read = {
      max    = 20
      target = 13
      min    = 10
    }
    write = {
      max    = 20
      target = 15
      min    = 10
    }
  }

  ttl = {
    enabled        = true # <-- default
    attribute_name = "TimeToExist"
  }

  streams = {
    # You can have both types of streams if you want
    dynamodb_stream_view_type = "NEW_AND_OLD_IMAGES"
    kinesis_stream_arn        = module.Foo_Kinesis_Stream.Stream.arn
  }

  replicas = {
    /* In the example below, each replica is provided with its own key.
    However, depending on your use case, you may be able to simplify
    resource/permissions management AND reduce KMS expenditure by instead
    using a multi-region key. If you go that route, using an alias *could*
    further reduce management overhead, but as with multi-region keys in
    general, there are some important considerations of which you need to
    be aware. Please refer to AWS KMS docs for more information.       */
    for table_replica_region in ["us-east-1", "us-east-2"] : table_replica_region => {
      propagate_tags                = true
      enable_point_in_time_recovery = true # <-- default
      kms_key_arn = lookup(
        module.Foo_DynamoDB_SSE_KMS_Keys.keys_by_table_region,
        table_replica_region # <-- "us-east-1", "us-east-2"
      ).arn
    }
  }

  tags = {
    Name        = "My_DynamoDB_Table"
    Environment = "production"
  }
}

######################################################################
