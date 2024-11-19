
# Payment Reversal and Audit Trail Implementation

This document explains the implementation of a payment reversal process and the use of an audit trail to log and track reversal actions in a payment processing system. It covers how to persist payment reversal details and retrieve original ledger entries for processing reversals.

## 1. Persisting Payment Audit Trail

This involves capturing every reversal action (like refunds or cancellations) and storing them in an audit trail.

### What You Need to Do

#### DynamoDB (Audit Table)

Create a DynamoDB table that logs the reversal actions.

#### Attributes to Store

- **TransactionID**: The original transaction's ID being reversed.
- **ReversalID**: A unique identifier for the reversal action.
- **Timestamp**: The date and time when the reversal was initiated.
- **Initiator**: Who initiated the reversal (e.g., user or system).
- **Amount**: The amount being refunded or canceled.
- **Currency**: The currency of the reversal.
- **Status**: Whether the reversal was successful or failed.
- **Reason**: Why the reversal is being performed (e.g., customer refund).

### Steps to Implement

1. **Capture Data**: When a reversal action occurs, capture all the relevant details like who initiated the reversal, the amount, and why it's happening.
2. **Write to DynamoDB**: Store this captured data in the DynamoDB audit table.
3. **Optional – Use SQS FIFO Queues**: In high-traffic systems, using Amazon SQS FIFO queues can help ensure that logs are persisted in the correct order, especially for large volumes of transactions.

### Example

Here’s an example of how the data would look in your audit table:

```json
{
  "TransactionID": "abc123",
  "ReversalID": "rev567",
  "Timestamp": "2024-11-19T12:34:56Z",
  "Initiator": "User123",
  "Amount": "100.00",
  "Currency": "USD",
  "Status": "SUCCESS",
  "Reason": "Customer Refund"
}
```

---

## 2. Retrieving Ledger Entries to Revert

Before you can perform a reversal (like a refund), you need to verify the original transaction's details to ensure the reversal is valid.

### What You Need to Do

#### DynamoDB (Ledger Table)

Create a ledger table that stores the original payment transaction details.

#### Attributes to Store

- **TransactionID**: The unique identifier for the payment.
- **Amount**: The original payment amount.
- **Currency**: The currency used for the payment.
- **Payment Processor Response**: Response from the payment processor (e.g., "SUCCESS", "FAILED").
- **Timestamp**: When the original payment was made.
- **Status**: The current status of the transaction (e.g., "COMPLETED", "FAILED").

### Steps to Implement

1. **Receive Reversal Request**: When a reversal request (e.g., refund) is received, the request should include the TransactionID of the payment to be reversed.
2. **Query the Ledger**: Query the ledger table to retrieve the original payment details using the TransactionID.
3. **Validate the Transaction**:
   - Ensure that the original transaction exists in the ledger.
   - Check that the transaction is eligible for reversal (for example, the status should be "COMPLETED").
   - Ensure that the reversal amount matches the original transaction amount.
4. **Update Transaction Status**: After the reversal is processed, update the original transaction's status to "REFUNDED" or another appropriate status.
5. **Log the Reversal**: Finally, write the reversal details to the audit trail (as explained in step 1).

### Example Query Response

Here’s an example of how a query response might look when retrieving the original transaction details:

```json
{
  "TransactionID": "abc123",
  "Amount": "100.00",
  "Currency": "USD",
  "Status": "COMPLETED",
  "Timestamp": "2024-11-01T10:30:00Z"
}
```

---

## Workflow Summary

1. **Persist Audit Trail**: Log all reversal actions (e.g., refund, cancellation) into the DynamoDB audit table, including relevant data like the initiator, timestamp, and status.
2. **Retrieve Ledger Entries**: Query the ledger table using the transaction ID from the reversal request. Retrieve the original transaction details to ensure it is eligible for reversal.
3. **Update Status**: After processing the reversal, update the original transaction status (e.g., from "COMPLETED" to "REFUNDED").
4. **Log Reversal**: Write the reversal information into the audit trail for transparency and debugging.

---

## Why This Is Important

- **Transparency**: Every reversal is logged with detailed information for auditing purposes.
- **Accountability**: It is clear who initiated the reversal and why.
- **Error Handling**: If a reversal fails, the audit trail helps track and troubleshoot the issue.
- **Data Consistency**: Ensures that reversals are only applied to valid transactions, preventing errors like double refunds.

---

## Next Steps

1. Implement DynamoDB tables for the **audit trail** and **ledger**.
2. Set up the process for capturing and storing the reversal data when a payment reversal occurs.
3. Implement the logic to query the ledger table and validate the reversal request.
4. Update the status of the original payment transaction and log the reversal.
