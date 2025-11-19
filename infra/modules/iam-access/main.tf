# data IAM
resource "aws_iam_user" "principal_user" {
  name = var.user_name
}

resource "aws_iam_policy" "ssm_access" {
  name        = "SSMGetParameter"
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
        Resource = ["*"]
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

resource "aws_iam_user_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --- Políticas adicionais (somente se eks_auto_mode = true) ---
resource "aws_iam_user_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
}

resource "aws_iam_user_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
}

resource "aws_iam_user_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
}

resource "aws_iam_user_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
}

resource "aws_iam_user_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_user_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_user_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}