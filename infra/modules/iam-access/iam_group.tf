# Criação do grupo IAM "required_accesses"
resource "aws_iam_group" "required_accesses" {
  name = "required_accesses"
}

# Lista de políticas gerenciadas da AWS a serem anexadas ao grupo
locals {
  required_accesses_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
  ]
}

# Anexa as políticas ao grupo usando um loop 'for_each'
resource "aws_iam_group_policy_attachment" "required_accesses_attachments" {
  for_each   = toset(local.required_accesses_policies)
  group      = aws_iam_group.required_accesses.name
  policy_arn = each.value
}

# Adiciona o usuário "principal_user" ao grupo "required_accesses"
resource "aws_iam_group_membership" "principal_user_membership" {
  name = "principal_user_membership"
  users = [
    aws_iam_user.principal_user.name,
  ]
  group = aws_iam_group.required_accesses.name
}