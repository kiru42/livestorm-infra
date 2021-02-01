###################
##   RESSOURCES   #
###################

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "${local.common_tags["Name"]}-cloudwatch"
  retention_in_days = 7
  tags              = local.common_tags
}
