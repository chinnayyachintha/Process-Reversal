# Outputs for DynamoDB Tables
output "transactions_table_name" {
  description = "Name of the DynamoDB Transactions Table"
  value       = data.aws_dynamodb_table.transactions_table.name
}

output "audit_trail_table_name" {
  description = "Name of the DynamoDB Audit Trail Table"
  value       = data.aws_dynamodb_table.audit_trail_table.name
}

output "transactions_table_arn" {
  description = "ARN of the DynamoDB Transactions Table"
  value       = data.aws_dynamodb_table.transactions_table.arn
}

output "audit_trail_table_arn" {
  description = "ARN of the DynamoDB Audit Trail Table"
  value       = data.aws_dynamodb_table.audit_trail_table.arn
}

# Outputs for Lambda Functions
output "process_void_lambda_function_name" {
  description = "Name of the Lambda function for processing void transactions"
  value       = aws_lambda_function.process_reversal.function_name
}

output "process_void_lambda_function_arn" {
  description = "ARN of the Lambda function for processing void transactions"
  value       = aws_lambda_function.process_reversal.arn
}


# Outputs for IAM Role
output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.process_reversal_role.arn
}

output "lambda_execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.process_reversal_role.name
}

# Outputs for SQS Queue
output "reversal_queue_name" {
  description = "Name of the SQS Queue for processing reversals"
  value       = aws_sqs_queue.reversal_queue.name
}

output "reversal_queue_url" {
  description = "URL of the SQS Queue for processing reversals"
  value       = aws_sqs_queue.reversal_queue.id
}

