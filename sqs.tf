resource "aws_sqs_queue" "reversal_queue" {
  name                        = "ReversalProcessingQueue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true

  tags = {
    Name = "ReversalProcessingQueue"
  }
}
