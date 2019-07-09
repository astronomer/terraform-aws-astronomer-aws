resource "aws_security_group_rule" "extra_connection_to_private_kube_api_cluster" {
  count = length(var.extra_sg_ids_for_eks_security)

  description              = "Connect the extra security groups to the EKS cluster private endpoint"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = var.extra_sg_ids_for_eks_security[count.index] 
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  type        = "ingress"
}
