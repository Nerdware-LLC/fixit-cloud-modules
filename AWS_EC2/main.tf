######################################################################
### AWS EC2

# TODO EC2 resources

#---------------------------------------------------------------------
### EC2 Key Pair (optional)

# resource "aws_key_pair" "list" {
#   count = var.ec2_key_pair != null ? 1 : 0

#   key_name   = var.key_pair.key_name
#   public_key = var.key_pair.public_key
#   tags       = var.key_pair.tags

#   lifecycle {
#     /* "public_key" must be ignored bc the AWS API does not include
#     the field in the response, so `terraform apply` would otherwise
#     always attempt to replace the key pair.  */
#     ignore_changes = [public_key]
#   }
# }

######################################################################
