output "state_machine_arns" {
  description = "Step Functions state machine ARNs keyed by workflow."
  value       = { for key, state_machine in aws_sfn_state_machine.this : key => state_machine.arn }
}

output "state_machine_names" {
  description = "Step Functions state machine names keyed by workflow."
  value       = { for key, state_machine in aws_sfn_state_machine.this : key => state_machine.name }
}
