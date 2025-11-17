# data IAM
resource "aws_iam_user" "principal_user" {
  name = var.user_name
}

# Data source para obter o ID da conta AWS atual
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "ssm_access" {
  name        = "SSMParameterAccessForEKS"
  description = "Permite acesso a parâmetros SSM para AMI otimizada do EKS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowEKSAMIParameterAccess"
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        # Usando o ID da conta dinâmico
        Resource = "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/aws/service/eks/optimized-ami/*"
      },
      {
        Sid      = "AllowEKSAMIParameterAccessForSpecificVersion"
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        # O ARN de parâmetro de serviço não precisa do ID da conta
        Resource = "arn:aws:ssm:us-east-1::parameter/aws/service/eks/optimized-ami/1.33/amazon-linux-2023/x86_64/standard/recommended/release_version"
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