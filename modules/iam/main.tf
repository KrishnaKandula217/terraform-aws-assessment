# IAM Module - Main Configuration
# Creates IAM role and instance profile for EC2

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "s3_logs_policy" {
  name        = "${var.project_name}-s3-logs-policy-${var.environment}"
  description = "Policy to allow EC2 to write logs to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-s3-logs-policy-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach S3 policy to role
resource "aws_iam_role_policy_attachment" "s3_logs_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_logs_policy.arn
}

# Attach AWS managed policy for SSM (optional but recommended for management)
resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
}
