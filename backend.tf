terraform {
  backend "s3" {
    bucket         = "destination-bucket-btc"        # Your existing S3 bucket
    key            = "terraform/state.tfstate"       # The file path within the bucket
    region         = "us-east-1"                     # The region of your bucket
    encrypt        = true                            # Encrypt the state file
  }
}
