######################################################################
### KMS Key Regional Replicas

resource "aws_kms_replica_key" "ap-northeast-1" {
  count    = var.regional_replicas.ap-northeast-1 == true ? 1 : 0
  provider = aws.ap-northeast-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-northeast-2

resource "aws_kms_replica_key" "ap-northeast-2" {
  count    = var.regional_replicas.ap-northeast-2 == true ? 1 : 0
  provider = aws.ap-northeast-2

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-northeast-3

resource "aws_kms_replica_key" "ap-northeast-3" {
  count    = var.regional_replicas.ap-northeast-3 == true ? 1 : 0
  provider = aws.ap-northeast-3

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-south-1

resource "aws_kms_replica_key" "ap-south-1" {
  count    = var.regional_replicas.ap-south-1 == true ? 1 : 0
  provider = aws.ap-south-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-southeast-1

resource "aws_kms_replica_key" "ap-southeast-1" {
  count    = var.regional_replicas.ap-southeast-1 == true ? 1 : 0
  provider = aws.ap-southeast-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-southeast-2

resource "aws_kms_replica_key" "ap-southeast-2" {
  count    = var.regional_replicas.ap-southeast-2 == true ? 1 : 0
  provider = aws.ap-southeast-2

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ca-central-1

resource "aws_kms_replica_key" "ca-central-1" {
  count    = var.regional_replicas.ca-central-1 == true ? 1 : 0
  provider = aws.ca-central-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-north-1

resource "aws_kms_replica_key" "eu-north-1" {
  count    = var.regional_replicas.eu-north-1 == true ? 1 : 0
  provider = aws.eu-north-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-central-1

resource "aws_kms_replica_key" "eu-central-1" {
  count    = var.regional_replicas.eu-central-1 == true ? 1 : 0
  provider = aws.eu-central-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-west-1

resource "aws_kms_replica_key" "eu-west-1" {
  count    = var.regional_replicas.eu-west-1 == true ? 1 : 0
  provider = aws.eu-west-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-west-2

resource "aws_kms_replica_key" "eu-west-2" {
  count    = var.regional_replicas.eu-west-2 == true ? 1 : 0
  provider = aws.eu-west-2

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-west-3

resource "aws_kms_replica_key" "eu-west-3" {
  count    = var.regional_replicas.eu-west-3 == true ? 1 : 0
  provider = aws.eu-west-3

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - sa-east-1

resource "aws_kms_replica_key" "sa-east-1" {
  count    = var.regional_replicas.sa-east-1 == true ? 1 : 0
  provider = aws.sa-east-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - us-east-1

resource "aws_kms_replica_key" "us-east-1" {
  count    = var.regional_replicas.us-east-1 == true ? 1 : 0
  provider = aws.us-east-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - us-west-1

resource "aws_kms_replica_key" "us-west-1" {
  count    = var.regional_replicas.us-west-1 == true ? 1 : 0
  provider = aws.us-west-1

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - us-west-2

resource "aws_kms_replica_key" "us-west-2" {
  count    = var.regional_replicas.us-west-2 == true ? 1 : 0
  provider = aws.us-west-2

  primary_key_arn         = aws_kms_key.this.arn
  description             = var.key_description
  deletion_window_in_days = 7
  tags                    = var.key_tags
}

######################################################################
