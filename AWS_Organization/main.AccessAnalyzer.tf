######################################################################
### Organization Access Analyzer

resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = var.org_access_analyzer.name
  type          = "ORGANIZATION"
  tags          = var.org_access_analyzer.tags
}

######################################################################
