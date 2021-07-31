data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = "${local.base_name}-K8sNodeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    {
      "Name" = "${local.base_name}-K8sNodeRole"
    },
    local.tags
  )

}

data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "access_ecr" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_policy" "s3objectput" {
  name        = "${local.base_name}-K8sNode-s3objectput"
  path        = "/"
  description = "s3にオブジェクトをPUTする"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

resource "aws_iam_role_policy_attachment" "access_ecr" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.access_ecr.arn
}

resource "aws_iam_role_policy_attachment" "s3objectput" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3objectput.arn
}

resource "aws_iam_instance_profile" "k8snode" {
  name = "K8sNode-instance-profile"
  role = aws_iam_role.role.name
}

# 自動スケジュール設定
## CloudWatch Eventsで使用するIAMロール
resource "aws_iam_role" "k8snode_ssm_automation" {
  name               = "${local.base_name}-K8sNode-SSMautomation"
  assume_role_policy = data.aws_iam_policy_document.k8snode_ssm_automation_trust.json

  tags = merge(
    {
      "Name" = "${local.base_name}-K8sNode-SSMautomation"
    },
    local.tags
  )

}

## CloudWatch EventsのIAMロールにSSM Automationのポリシーを付与
resource "aws_iam_role_policy_attachment" "ssm-automation-atach-policy" {
  role       = aws_iam_role.k8snode_ssm_automation.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

## CloudWatch EventsからのaasumeRoleを許可するポリシー
data "aws_iam_policy_document" "k8snode_ssm_automation_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# EC2からCloudWatchLogsへの書き込み
data "aws_iam_policy" "cloudwatchlogsfull" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatchlogsfull" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.cloudwatchlogsfull.arn
}
