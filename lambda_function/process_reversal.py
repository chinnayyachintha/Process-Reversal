import json
import boto3
import os
from datetime import datetime

# Initialize DynamoDB client
dynamodb = boto3.resource("dynamodb")

# Fetch environment variables
ORIGINAL_TRANSACTION_TABLE = os.environ["ORIGINAL_TRANSACTION_TABLE"]
AUDIT_TRAIL_TABLE = os.environ["AUDIT_TRAIL_TABLE"]

def handler(event, context):
    try:
        # Parse input from API Gateway
        body = json.loads(event["body"])
        transaction_id = body["TransactionID"]
        reversal_amount = float(body["ReversalAmount"])
        reason = body.get("Reason", "No reason provided")
        initiator = body.get("Initiator", "System")
        
        # Get reference to DynamoDB tables
        original_table = dynamodb.Table(ORIGINAL_TRANSACTION_TABLE)
        audit_table = dynamodb.Table(AUDIT_TRAIL_TABLE)

        # Step 1: Retrieve the original transaction
        original_transaction = original_table.get_item(Key={"TransactionID": transaction_id})
        
        if "Item" not in original_transaction:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "Transaction not found"})
            }
        
        transaction = original_transaction["Item"]

        # Step 2: Validate the transaction status and amount
        if transaction["Status"] != "COMPLETED":
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Transaction is not eligible for reversal"})
            }
        
        if reversal_amount > float(transaction["Amount"]):
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Reversal amount exceeds original transaction amount"})
            }

        # Step 3: Log the reversal attempt in the audit trail
        audit_id = f"audit-{datetime.utcnow().isoformat()}"
        audit_entry = {
            "AuditID": audit_id,
            "TransactionID": transaction_id,
            "Action": "REVERSAL",
            "Status": "PENDING",
            "Initiator": initiator,
            "Timestamp": datetime.utcnow().isoformat(),
            "Metadata": {
                "ReversalAmount": reversal_amount,
                "Reason": reason
            }
        }

        audit_table.put_item(Item=audit_entry)

        # Step 4: Update the original transaction status
        original_table.update_item(
            Key={"TransactionID": transaction_id},
            UpdateExpression="SET #s = :new_status",
            ExpressionAttributeNames={"#s": "Status"},
            ExpressionAttributeValues={":new_status": "REFUNDED"}
        )

        # Step 5: Mark audit entry as SUCCESS
        audit_table.update_item(
            Key={"AuditID": audit_id},
            UpdateExpression="SET #s = :new_status",
            ExpressionAttributeNames={"#s": "Status"},
            ExpressionAttributeValues={":new_status": "SUCCESS"}
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Transaction reversed successfully"})
        }

    except Exception as e:
        # Log the error
        print(f"Error: {str(e)}")

        return {
            "statusCode": 500,
            "body": json.dumps({"error": "An internal server error occurred"})
        }
