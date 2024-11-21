resource "aws_lambda_function" "process_reversal" {
  function_name = "${var.project}_ledger_audit_trail"
  runtime       = "python3.9"
  role          = aws_iam_role.process_reversal_role.arn
  handler       = "process_reversal.handler"
  timeout       = 15

  # Upload your Lambda code zip file
  filename = "lambda_function/process_reversal.zip"

  # Environment variables for table names
  environment {
    variables = {
      TRANSACTION_TABLE = data.aws_dynamodb_table.transactions_table.name
      AUDIT_TRAIL_TABLE = data.aws_dynamodb_table.audit_trail_table.name
    }
  }
}
