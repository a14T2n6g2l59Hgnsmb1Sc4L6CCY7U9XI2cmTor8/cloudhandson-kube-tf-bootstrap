resource "aws_iam_role" "application" {
  name               = "EKS_${var.env}_${var.cluster_name}_${var.namespace}_pod_role"
  assume_role_policy = data.aws_iam_policy_document.app_assume_role.json
}

# For IRSA: Assume Role Policy
# data "aws_iam_policy_document" "app_assume_role" {
#   statement {
#     effect = "Allow"
#     principals {
#       type = "Federated"
#       identifiers = [ local.oidc_arn ]
#     }
#     actions = [
#       "sts:AssumeRoleWithWebIdentity"
#     ]
#     condition {
#       test = "StringLike"
#       variable = "${local.oidc_issuer}:aud"
#       values = [ "sts.amazonaws.com" ]
#     }
#     condition {
#       test = "StringLike"
#       variable = "${local.oidc_issuer}:sub"
#       values = [ "system:serviceaccount:${var.namespace}:${var.namespace}" ]
#     }
#   }
# }

# For Identity Pod: Assume Role Policy
data "aws_iam_policy_document" "app_assume_role" {
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEksAuthToAssumeRoleForPodIdentity",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "pods.eks.amazonaws.com"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "application" {
  cluster_name    = "${var.cluster_name}-${var.env}-eks-cluster"
  namespace       = var.namespace
  role_arn        = aws_iam_role.application.arn
  service_account = var.application
}

## The new global attachment:
# resource "aws_iam_role_policy_attachment" "pod_role_global_pod_policies_attachment" {
#   policy_arn = data.aws_iam_policy.eks_global_pod_policies.arn
#   role       = aws_iam_role.application.name
# }

resource "aws_iam_role_policy_attachment" "pod_role_parameterstore_access_policy" {
  policy_arn = aws_iam_policy.eso_policy.arn
  role       = aws_iam_role.application.name
}
