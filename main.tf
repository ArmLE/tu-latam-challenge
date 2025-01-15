resource "aws_sqs_queue" "terraform_ingest_queue" {
  name                          = "terraform-ingest-queue"
  visibility_timeout_seconds    = 10
  delay_seconds                 = 0
  max_message_size              = 1024
  message_retention_seconds     = 10
  receive_wait_time_seconds     = 1
}
resource "aws_lambda_function" "redshift_ingest_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "redshift_ingest_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      REDSHIFT_HOST     = "your-redshift-cluster-endpoint"
      REDSHIFT_DATABASE = "your_database"
      REDSHIFT_USER     = "your_user"
      REDSHIFT_PASSWORD = "your_password"
    }
  }
}
resource "aws_redshift_cluster" "demo_redshift" {
  cluster_identifier       = "demo-redshift-cluster"
  node_type                = "dc2.large"
  master_username          = "admin"
  master_password          = "Password123"
  cluster_type             = "single-node"
  database_name            = "demo"
  publicly_accessible      = true
  automated_snapshot_retention_period = 1
}