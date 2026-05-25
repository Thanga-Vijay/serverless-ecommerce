data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "stepfunctions_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  for_each = var.lambda_services

  name               = "${var.name_prefix}-${each.key}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "lambda" {
  for_each = var.lambda_services

  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/${var.name_prefix}-${each.key}:*"]
  }

  dynamic "statement" {
    for_each = length(each.value.dynamodb_tables) == 0 ? [] : [1]
    content {
      sid = "DynamoDBAccess"
      actions = [
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ]
      resources = flatten([
        for table_key in each.value.dynamodb_tables : [
          var.dynamodb_table_arns[table_key],
          "${var.dynamodb_table_arns[table_key]}/index/*"
        ]
      ])
    }
  }

  dynamic "statement" {
    for_each = length(each.value.sqs_queues) == 0 ? [] : [1]
    content {
      sid = "SQSAccess"
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
        "sqs:SendMessage"
      ]
      resources = [for queue_key in each.value.sqs_queues : var.sqs_queue_arns[queue_key]]
    }
  }

  dynamic "statement" {
    for_each = length(each.value.sns_topics) == 0 ? [] : [1]
    content {
      sid       = "SNSPublish"
      actions   = ["sns:Publish"]
      resources = [for topic_key in each.value.sns_topics : var.sns_topic_arns[topic_key]]
    }
  }

  dynamic "statement" {
    for_each = length(each.value.s3_buckets) == 0 ? [] : [1]
    content {
      sid = "S3ObjectAccess"
      actions = [
        "s3:AbortMultipartUpload",
        "s3:GetObject",
        "s3:PutObject"
      ]
      resources = [for bucket_key in each.value.s3_buckets : "${var.s3_bucket_arns[bucket_key]}/*"]
    }
  }
}

resource "aws_iam_role_policy" "lambda" {
  for_each = var.lambda_services

  name   = "${var.name_prefix}-${each.key}-policy"
  role   = aws_iam_role.lambda[each.key].id
  policy = data.aws_iam_policy_document.lambda[each.key].json
}

resource "aws_iam_role" "stepfunctions" {
  name               = "${var.name_prefix}-stepfunctions-role"
  assume_role_policy = data.aws_iam_policy_document.stepfunctions_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "stepfunctions" {
  statement {
    sid       = "InvokeKnownLambdas"
    actions   = ["lambda:InvokeFunction"]
    resources = [for service in keys(var.lambda_services) : "arn:aws:lambda:*:*:function:${var.name_prefix}-${service}"]
  }

  statement {
    sid = "CloudWatchLogsDelivery"
    actions = [
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:DescribeLogGroups",
      "logs:DescribeResourcePolicies",
      "logs:GetLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:UpdateLogDelivery"
    ]
    resources = ["*"]
  }

  statement {
    sid = "XRayTracing"
    actions = [
      "xray:PutTelemetryRecords",
      "xray:PutTraceSegments"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "stepfunctions" {
  name   = "${var.name_prefix}-stepfunctions-policy"
  role   = aws_iam_role.stepfunctions.id
  policy = data.aws_iam_policy_document.stepfunctions.json
}
