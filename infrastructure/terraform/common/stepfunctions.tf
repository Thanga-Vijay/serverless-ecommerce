module "stepfunctions" {
  source = "../modules/stepfunctions"

  name_prefix        = local.name_prefix
  execution_role_arn = module.lambda_iam.stepfunctions_execution_role_arn
  log_group_arn      = module.monitoring.stepfunctions_log_group_arn
  state_machines = {
    order-workflow = {
      definition = jsonencode({
        Comment = "Serverless ecommerce order workflow"
        StartAt = "OrderReceived"
        States = {
          OrderReceived = {
            Type = "Pass"
            Next = "InventoryReserved"
          }
          InventoryReserved = {
            Type = "Pass"
            End  = true
          }
        }
      })
    }
  }
  tags = local.common_tags
}
