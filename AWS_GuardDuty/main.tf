######################################################################
### GuardDuty
#---------------------------------------------------------------------
### us-east-2 (HOME REGION USES IMPLICIT/DEFAULT PROVIDER)

# Org main account assigns GD-admin status to Security account
resource "aws_guardduty_organization_admin_account" "us-east-2" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  admin_account_id = var.guardduty_admin_account_id
}

# GuardDuty's main resource
resource "aws_guardduty_detector" "us-east-2" {
  count = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

# GuardDuty Org config (sets defaults)
resource "aws_guardduty_organization_configuration" "us-east-2" {
  count = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0

  auto_enable = true
  detector_id = one(aws_guardduty_detector.us-east-2).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - ap-northeast-1

resource "aws_guardduty_organization_admin_account" "ap-northeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "ap-northeast-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ap-northeast-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.ap-northeast-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - ap-northeast-2

resource "aws_guardduty_organization_admin_account" "ap-northeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-2

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "ap-northeast-2" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-2

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ap-northeast-2" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-2

  auto_enable = true
  detector_id = one(aws_guardduty_detector.ap-northeast-2).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - ap-northeast-3

resource "aws_guardduty_organization_admin_account" "ap-northeast-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-3

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "ap-northeast-3" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-3

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ap-northeast-3" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-3

  auto_enable = true
  detector_id = one(aws_guardduty_detector.ap-northeast-3).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - ap-south-1

resource "aws_guardduty_organization_admin_account" "ap-south-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-south-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "ap-south-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-south-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ap-south-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-south-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.ap-south-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - ap-southeast-1

resource "aws_guardduty_organization_admin_account" "ap-southeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "ap-southeast-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ap-southeast-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.ap-southeast-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - ap-southeast-2

resource "aws_guardduty_organization_admin_account" "ap-southeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-2

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "ap-southeast-2" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-2

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ap-southeast-2" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-2

  auto_enable = true
  detector_id = one(aws_guardduty_detector.ap-southeast-2).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - ca-central-1

resource "aws_guardduty_organization_admin_account" "ca-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ca-central-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "ca-central-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ca-central-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ca-central-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.ca-central-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.ca-central-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - eu-north-1

resource "aws_guardduty_organization_admin_account" "eu-north-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-north-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "eu-north-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-north-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "eu-north-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-north-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.eu-north-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - eu-central-1

resource "aws_guardduty_organization_admin_account" "eu-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-central-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "eu-central-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-central-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "eu-central-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-central-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.eu-central-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - eu-west-1

resource "aws_guardduty_organization_admin_account" "eu-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "eu-west-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-west-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "eu-west-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-west-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.eu-west-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - eu-west-2

resource "aws_guardduty_organization_admin_account" "eu-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-2

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "eu-west-2" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-west-2

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "eu-west-2" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-west-2

  auto_enable = true
  detector_id = one(aws_guardduty_detector.eu-west-2).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - eu-west-3

resource "aws_guardduty_organization_admin_account" "eu-west-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-3

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "eu-west-3" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-west-3

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "eu-west-3" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.eu-west-3

  auto_enable = true
  detector_id = one(aws_guardduty_detector.eu-west-3).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - sa-east-1

resource "aws_guardduty_organization_admin_account" "sa-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.sa-east-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "sa-east-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.sa-east-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "sa-east-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.sa-east-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.sa-east-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - us-east-1

resource "aws_guardduty_organization_admin_account" "us-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-east-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "us-east-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.us-east-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "us-east-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.us-east-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.us-east-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - us-west-1

resource "aws_guardduty_organization_admin_account" "us-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "us-west-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.us-west-1

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "us-west-1" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.us-west-1

  auto_enable = true
  detector_id = one(aws_guardduty_detector.us-west-1).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

#---------------------------------------------------------------------
### GuardDuty - us-west-2

resource "aws_guardduty_organization_admin_account" "us-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-2

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_guardduty_detector" "us-west-2" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.us-west-2

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.detector_tags

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "us-west-2" {
  count    = local.IS_GUARDDUTY_ADMIN_ACCOUNT ? 1 : 0
  provider = aws.us-west-2

  auto_enable = true
  detector_id = one(aws_guardduty_detector.us-west-2).id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

# Whew! That's a LOT 👆 but why have you come all this way? 🤨
# You've traveled so far, adventurer. Be careful ye don't take
# an arrow in the knee - for here be dragons 👉🐉🐉⚔️🏹
######################################################################
