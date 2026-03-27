provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# IAM ROLE
# -----------------------------
resource "aws_iam_role" "glue_role" {
  name = "glue-role-inline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# -----------------------------
# INLINE POLICY
# -----------------------------
resource "aws_iam_role_policy" "glue_inline_policy" {
  name = "glue-inline-policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "S3Access",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::my-glue-project-bucket-pradeep",
          "arn:aws:s3:::my-glue-project-bucket-pradeep/*"
        ]
      },
      {
        Sid = "CloudWatchLogs",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Sid = "GlueAccess",
        Effect = "Allow",
        Action = [
          "glue:*"
        ],
        Resource = "*"
      }
    ]
  })
}

# -----------------------------
# GLUE JOB
# -----------------------------
resource "aws_glue_job" "glue_job" {
  name     = "terraform-glue-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://my-glue-project-bucket-pradeep/scripts/glue_job.py"
    python_version  = "3"
  }

  glue_version = "4.0"

  default_arguments = {
    "--job-language" = "python"
  }

  worker_type       = "G.1X"
  number_of_workers = 2
}