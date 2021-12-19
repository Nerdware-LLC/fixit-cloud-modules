######################################################################
### Organization Access Analyzer

resource "aws_accessanalyzer_analyzer" "Org_AccessAnalyzer" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  analyzer_name = var.org_access_analyzer.name
  type          = "ORGANIZATION"
  tags          = var.org_access_analyzer.tags
}

######################################################################
