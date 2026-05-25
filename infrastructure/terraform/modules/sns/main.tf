resource "aws_sns_topic" "order_notifications" {
  name              = "${var.name_prefix}-${var.order_topic_name}"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.order_topic_name}"
  })
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.email_subscriptions)

  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "email"
  endpoint  = each.value
}

data "aws_iam_policy_document" "topic_policy" {
  statement {
    sid     = "DenyInsecureTransport"
    actions = ["sns:*"]
    effect  = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.order_notifications.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.order_notifications.arn
  policy = data.aws_iam_policy_document.topic_policy.json
}
