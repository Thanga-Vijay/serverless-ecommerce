resource "aws_sqs_queue" "dlq" {
  for_each = var.queues

  name                      = "${var.name_prefix}-${each.key}-dlq"
  message_retention_seconds = 1209600
  kms_master_key_id         = "alias/aws/sqs"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}-dlq"
  })
}

resource "aws_sqs_queue" "this" {
  for_each = var.queues

  name                       = "${var.name_prefix}-${each.key}"
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  message_retention_seconds  = each.value.message_retention_seconds
  receive_wait_time_seconds  = 10
  kms_master_key_id          = "alias/aws/sqs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = each.value.max_receive_count
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
  })
}

data "aws_iam_policy_document" "queue_policy" {
  for_each = aws_sqs_queue.this

  statement {
    sid     = "DenyInsecureTransport"
    actions = ["sqs:*"]
    effect  = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [each.value.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  for_each = aws_sqs_queue.this

  queue_url = each.value.id
  policy    = data.aws_iam_policy_document.queue_policy[each.key].json
}
