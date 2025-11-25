
# -----------------------------------------------------------------------------------
# 1. IAM ROLE PARA O CLUSTER EKS (CONTROL PLANE)
# -----------------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# -----------------------------------------------------------------------------------
# 2. IAM ROLE PARA OS NÓS (NODE GROUP)
# -----------------------------------------------------------------------------------
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# -----------------------------------------------------------------------------------
# 3. CLUSTER EKS
# -----------------------------------------------------------------------------------
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.30" # Mantendo a versão original

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    # O Security Group do Cluster é criado automaticamente pelo EKS
    # e será referenciado no Node Group.
  }

  # Garante que as roles sejam criadas antes do cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
  ]
}

# -----------------------------------------------------------------------------------
# 4. SECURITY GROUP CUSTOMIZADO PARA OS NÓS
# -----------------------------------------------------------------------------------
# Mantido do arquivo original, mas com ajustes nas referências
resource "aws_security_group" "eks_node_custom_sg" {
  name        = "${var.cluster_name}-node-custom-sg"
  description = "Custom Security Group for EKS Worker Nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-node-custom-sg"
  }
}

# -----------------------------------------------------------------------------------
# 5. REGRAS DE SAÍDA (OUTBOUND) E ENTRADA (INBOUND) PARA O SG DOS NÓS
# -----------------------------------------------------------------------------------

# ADICIONAR REGRAS DE SAÍDA (OUTBOUND) AO SG CUSTOMIZADO
resource "aws_security_group_rule" "eks_node_custom_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # All protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_node_custom_sg.id
  description       = "Allow all outbound traffic"
}

# ADICIONAR REGRAS DE ENTRADA (INBOUND) AO SG CUSTOMIZADO (Self)
# Permite comunicação entre os próprios nós
resource "aws_security_group_rule" "eks_node_custom_ingress_self" {
type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_node_custom_sg.id
  description       = "Allow all traffic from self"
}

# ADICIONAR REGRAS DE ENTRADA (INBOUND) AO SG CUSTOMIZADO (Cluster -> Node)
# Permite comunicação do Control Plane (SG do Cluster) para o Kubelet (porta 10250)
resource "aws_security_group_rule" "eks_node_custom_ingress_cluster" {
  type                     = "ingress"
  from_port                = 10250 # Porta kubelet
  to_port                  = 10250
  protocol                 = "tcp"
  # Referência ao SG do Cluster EKS
  source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  security_group_id        = aws_security_group.eks_node_custom_sg.id
  description              = "Allow traffic from EKS Cluster SG (Kubelet 10250)"
}

# -----------------------------------------------------------------------------------
# 6. REGRA DE COMUNICAÇÃO NÓ -> CONTROL PLANE (PORTA 443)
# -----------------------------------------------------------------------------------

# Regra de Ingress para o Security Group do Cluster EKS (Control Plane)
# Permite que os nós se comuniquem com o Control Plane na porta 443
resource "aws_security_group_rule" "cluster_ingress_from_nodes_443" {
  type              = "ingress"

  from_port         = 443
  to_port           = 443
  protocol          = "tcp"

  # A origem do tráfego é o Security Group customizado dos nós
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_node_custom_sg.id

  description       = "Permite nodes EKS conectarem a API do control plane (443)"
}

# -----------------------------------------------------------------------------------
# 7. NODE GROUP GERENCIADO PELO EKS
# -----------------------------------------------------------------------------------
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "node-group-eks"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.instance_type
  ami_type        = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }

  # Tags necessárias para o Cluster Autoscaler (se for usado) e para organização
  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    Environment = "dev"
    Project     = var.cluster_name
  }

  # Garante que o cluster e as roles sejam criadas antes do node group
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.eks_cni_policy,
  ]
}

# -----------------------------------------------------------------------------------
# 8. ADDON VPC-CNI (Opcional, mas recomendado para garantir a versão)
# -----------------------------------------------------------------------------------
# O EKS geralmente instala o CNI por padrão, mas é bom ter o addon para controle.
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  # O CNI precisa de uma Service Account Role (IRSA) se o modo for IRSA.
  # No modo padrão, ele usa a role do nó. Para simplificar, vamos confiar na role do nó.
  # Se o erro persistir, o próximo passo seria configurar o IRSA para o CNI.
  # Por enquanto, vamos manter a configuração padrão que usa a role do nó.
}

# -----------------------------------------------------------------------------------
# 9. ADDON METRICS SERVER ADDON (para HPA e monitoramento)
# -----------------------------------------------------------------------------------
# Usando o novo recurso aws_eks_access_entry para o acesso do usuário principal
# Enable Metrics Server Addon for EKS Cluster
resource "aws_eks_addon" "metrics_server" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "metrics-server"
}

# -----------------------------------------------------------------------------------
# 10. CONFIGURAÇÃO DE ACESSO (aws_auth ou access_entry)
# -----------------------------------------------------------------------------------
# Usando o novo recurso aws_eks_access_entry para o acesso do usuário principal
resource "aws_eks_access_entry" "infra_user_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.principal_user_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "infra_user_admin_policy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_eks_access_entry.infra_user_access.principal_arn
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}