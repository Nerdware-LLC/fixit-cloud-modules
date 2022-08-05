######################################################################
### OUTPUTS

output "DynamoDB_Table" {
  description = "The DynamoDB table resource object."
  value       = aws_dynamodb_table.this
}

output "DynamoDB_Table_Items" {
  description = "List of DynamoDB table item resource objects."
  value       = aws_dynamodb_table_item.list
}

output "DynamoDB_Kinesis_Stream_Destination" {
  description = "The DynamoDB Kinesis data stream destination resource object."
  value       = one(aws_dynamodb_kinesis_streaming_destination.list)
}

output "DynamoDB_AutoScaling_Targets" {
  description = <<-EOF
  Map of DynamoDB autoscaling policy resource objects, the keys of which
  are in the format "(table|gsi)/NAME/(reads|writes)". So a table with
  PROVISIONED capacity named "Foo_Table" with global indexes "Foo_GSI_1"
  and "Foo_GSI_2" would have the following six keys: "table/Foo_Table/reads",
  "table/Foo_Table/writes", "gsi/Foo_GSI_1/reads", "gsi/Foo_GSI_1/writes",
  "gsi/Foo_GSI_2/reads", and "gsi/Foo_GSI_2/writes".
  EOF

  value = aws_appautoscaling_target.map
}

output "DynamoDB_AutoScaling_Policies" {
  description = <<-EOF
  Map of DynamoDB autoscaling policy resource objects, the keys of which
  are in the format "(table|gsi)/NAME/(reads|writes)". So a table with
  PROVISIONED capacity named "Foo_Table" with global indexes "Foo_GSI_1"
  and "Foo_GSI_2" would have the following six keys: "table/Foo_Table/reads",
  "table/Foo_Table/writes", "gsi/Foo_GSI_1/reads", "gsi/Foo_GSI_1/writes",
  "gsi/Foo_GSI_2/reads", and "gsi/Foo_GSI_2/writes".
  EOF

  value = aws_appautoscaling_policy.map
}

######################################################################
