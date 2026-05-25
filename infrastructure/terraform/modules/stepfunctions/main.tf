resource "aws_sfn_state_machine" "this" {
  for_each = var.state_machines

  name       = "${var.name_prefix}-${each.key}"
  role_arn   = var.execution_role_arn
  type       = each.value.type
  definition = each.value.definition

  logging_configuration {
    include_execution_data = true
    level                  = "ERROR"
    log_destination        = "${var.log_group_arn}:*"
  }

  tracing_configuration {
    enabled = true
  }

  tags = var.tags
}
