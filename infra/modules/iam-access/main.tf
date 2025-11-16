# data IAM
resource "aws_iam_user" "principal_user" {
  name = var.user_name
}

resource "aws_iam_policy" "ssm_access" {
  name        = "SSMParameterAccessForEKS"
  description = "Permite acesso a parâmetros SSM para AMI otimizada do EKS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Statement1"
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ssm_access" {
  user       = aws_iam_user.principal_user.name
  policy_arn = aws_iam_policy.ssm_access.arn
}

resource "aws_iam_user_policy_attachment" "iam_readonly" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}