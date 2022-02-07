# kms key

resource "aws_kms_key" "snyk_sync_kms_key" {
  description              = "Snyk Sync Runners Key"
  deletion_window_in_days  = 10
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
}


# Secrets
resource "aws_secretsmanager_secret" "snyk_sync_secrets" {
  name = "snyk_sync_secrets"
}

# Versions
resource "aws_secretsmanager_secret_version" "snyk_sync_instance_secrets" {
  secret_id     = aws_secretsmanager_secret.snyk_sync_secrets.id
  secret_string = jsonencode(var.secrets)
}


resource "aws_iam_role" "snyk_sync_secrets_access" {
  name = "snyk_sync_secrets_accesse"
  path = "/development/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "access_snyk_secrets_iam_policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
          ],
          "Resource" : aws_secretsmanager_secret.snyk_sync_secrets.arn
        },
        {
          "Effect" : "Allow",
          "Action" : "secretsmanager:ListSecrets",
          "Resource" : "*"
        }
      ]
    })
  }

}


resource "aws_iam_instance_profile" "snyk_instance_profile" {
  name = "snyk_instance_profile"
  role = aws_iam_role.snyk_sync_secrets_access.name
}
