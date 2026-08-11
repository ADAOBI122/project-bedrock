data "archive_file" "lambda_zip" {

  type = "zip"

  source_dir = "../lambda"

  output_path = "../lambda.zip"

}



resource "aws_lambda_function" "asset_processor" {


  function_name = "bedrock-asset-processor"


  role = aws_iam_role.lambda_execution_role.arn


  handler = "handler.handler"


  runtime = "python3.12"


  filename = data.archive_file.lambda_zip.output_path



  tags = {

    Project = "tinyuka-2025-capstone"

  }

}




resource "aws_lambda_permission" "allow_s3" {


  statement_id = "AllowS3Invoke"


  action = "lambda:InvokeFunction"


  function_name = aws_lambda_function.asset_processor.function_name


  principal = "s3.amazonaws.com"


  source_arn = aws_s3_bucket.assets.arn


}



resource "aws_s3_bucket_notification" "bucket_notification" {


  bucket = aws_s3_bucket.assets.id


  lambda_function {


    lambda_function_arn = aws_lambda_function.asset_processor.arn


    events = [
      "s3:ObjectCreated:*"
    ]

  }


  depends_on = [
    aws_lambda_permission.allow_s3
  ]


}
