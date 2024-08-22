# IAM Role
resource "aws_iam_role" "example_role" {
  name = "example_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy
resource "aws_iam_policy" "example_policy" {
  name        = "example_policy"
  description = "Example policy for demo purposes"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "*"
      },
    ]
  })
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "example_role_policy_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn  = aws_iam_policy.example_policy.arn
}

# IAM User
resource "aws_iam_user" "example_user" {
  name = "example_user"
}

# IAM User Policy Attachment
resource "aws_iam_user_policy_attachment" "example_user_policy_attachment" {
  user       = aws_iam_user.example_user.name
  policy_arn  = aws_iam_policy.example_policy.arn
}
