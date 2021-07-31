# CloudWatchイベント - EC2の定時起動
resource "aws_cloudwatch_event_rule" "start_k8snode_rule" {
  count = local.auto_start ? 1 : 0

  name                = "${local.base_name}-K8sNode-StartRule"
  description         = "Start K8s Node"
  schedule_expression = local.auto_start_schedule

  tags = merge(
    {
      "Name" = "${local.base_name}-K8sNode-StartRule"
    },
    local.tags
  )

}

resource "aws_cloudwatch_event_target" "start_k8snode" {
  count = local.auto_start ? 1 : 0

  target_id = "${local.base_name}-StartInstanceTarget"
  arn       = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:automation-definition/AWS-StartEC2Instance"
  rule      = aws_cloudwatch_event_rule.start_k8snode_rule.0.name
  role_arn  = aws_iam_role.k8snode_ssm_automation.arn

  input = <<DOC
{
  "InstanceId": ${jsonencode(values(aws_instance.k8s_nodes)[*].id)}
}
DOC
}

# CloudWatchイベント - EC2の定時停止
resource "aws_cloudwatch_event_rule" "stop_k8snode_rule" {
  count = local.auto_stop ? 1 : 0

  name                = "${local.base_name}-K8sNode-StopRule"
  description         = "Stop K8s Node"
  schedule_expression = local.auto_stop_schedule

  tags = merge(
    {
      "Name" = "${local.base_name}-K8sNode-StopRule"
    },
    local.tags
  )

}

resource "aws_cloudwatch_event_target" "stop_k8snode" {
  count = local.auto_stop ? 1 : 0

  target_id = "${local.base_name}-StopInstanceTarget"
  arn       = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:automation-definition/AWS-StopEC2Instance"
  rule      = aws_cloudwatch_event_rule.stop_k8snode_rule.0.name
  role_arn  = aws_iam_role.k8snode_ssm_automation.arn

  input = <<DOC
{
  "InstanceId": ${jsonencode(values(aws_instance.k8s_nodes)[*].id)}
}
DOC
}
