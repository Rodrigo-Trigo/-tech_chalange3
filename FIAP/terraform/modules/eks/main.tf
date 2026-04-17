# Data source para LabRole (AWS Academy)
data "aws_iam_role" "lab_role" {
  name = var.lab_role_name
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = data.aws_iam_role.lab_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [data.aws_iam_role.lab_role]

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

# Security Group para Node Group
resource "aws_security_group" "node_group" {
  name        = "${var.project_name}-node-group-sg"
  description = "Security group for EKS node group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-node-group-sg"
    Environment = var.environment
  }
}

# Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = var.subnet_ids
  version         = var.kubernetes_version

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  tags = {
    Name        = "${var.project_name}-node-group"
    Environment = var.environment
  }

  depends_on = [data.aws_iam_role.lab_role]
}

# OIDC Provider para IRSA (IAM Roles for Service Accounts)
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name        = "${var.project_name}-eks-oidc"
    Environment = var.environment
  }
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Addon: VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = null

  tags = {
    Name        = "${var.project_name}-vpc-cni-addon"
    Environment = var.environment
  }
}

# Addon: CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "coredns"
  addon_version     = var.coredns_version
  resolve_conflicts = "OVERWRITE"

  tags = {
    Name        = "${var.project_name}-coredns-addon"
    Environment = var.environment
  }
}

# Addon: kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "kube-proxy"
  addon_version     = var.kube_proxy_version
  resolve_conflicts = "OVERWRITE"

  tags = {
    Name        = "${var.project_name}-kube-proxy-addon"
    Environment = var.environment
  }
}
