data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = "${var.cluster_name}"
}

# data "aws_lb" "eks_alb" {
#   name = "eks-${var.cluster_name}"
# }

# data "aws_iam_policy" "eks_global_pod_policies" {
#   name = "eks_${var.cluster_name}_global_pod_policies"
# }
