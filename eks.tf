# Data source para autenticação do cluster EKS
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# DATA SOURCE (Auth)
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

# EKS CLUSTER && NODES
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = "flask-cluster"
  cluster_version = "1.33"

  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.app_1a.id, aws_subnet.app_1c.id]

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_iam_role = false
  iam_role_arn    = "arn:aws:iam::765732380112:role/EKSRole"

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  enable_irsa = false

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 3
      max_size       = 3
      min_size       = 2

      create_iam_role = false
      iam_role_arn    = "arn:aws:iam::765732380112:role/EKSNodeGroupRole"
      

      tags = {
        Name  = "eks-nodegroup"
        AMBIENTE  = "DEV"
        RESPONSAVEL = "artur.jorge@inmetrics.com.br"
        SCHEDULE = "online"
        CENTRODECUSTO = "ADMPLATDIGITAL"
      }
    }
    
  }

  tags = {
    Name  = "eks"
    AMBIENTE  = "DEV"
    RESPONSAVEL = "artur.jorge@inmetrics.com.br"
    SCHEDULE = "online"
    CENTRODECUSTO = "ADMPLATDIGITAL"
  }
} 