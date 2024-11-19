# IAM Role for the process_reversal Lambda function
resource "aws_iam_role" "process_reversal_role" {
  name = "${var.project}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy to allow access to DynamoDB tables
resource "aws_iam_policy" "process_reversal_dynamodb_policy" {
  name        = "${var.project}_dynamodb_policy"
  description = "Policy to allow Lambda to access DynamoDB tables for process reversal"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = [
          data.aws_dynamodb_table.transactions_table.arn,
          data.aws_dynamodb_table.audit_trail_table.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "process_reversal_policy_attachment" {
  role       = aws_iam_role.process_reversal_role.name
  policy_arn = aws_iam_policy.process_reversal_dynamodb_policy.arn
}
