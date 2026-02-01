resource "aws_iam_role" "eso_role" {
  name               = "EKS_${var.env}_${var.cluster_name}_${var.namespace}_externalSecrets_role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
}


# For IRSA: Assume Role Policy
# data "aws_iam_policy_document" "eso_assume_role" {
#   statement {
#     effect = "Allow"
#     principals {
#       type = "Federated"
#       identifiers = [ local.oidc_arn ]
#     }
#     actions = [
#       "sts:AssumeRoleWithWebIdentity"
#       # "sts:TagSession"
#     ]
#     condition {
#       test = "StringLike"
#       variable = "${local.oidc_issuer}:aud"
#       values = [ "sts.amazonaws.com" ]
#     }
#     condition {
#       test = "StringLike"
#       variable = "${local.oidc_issuer}:sub"
#       values = [ "system:serviceaccount:${var.namespace}:${var.namespace}-external-secret" ]
#     }
#   }
# }

# For Identity Pod: Assume Role Policy
data "aws_iam_policy_document" "eso_assume_role" {
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


resource "aws_iam_policy" "eso_policy" {
  name = "EKS_${var.env}_${var.cluster_name}_${var.namespace}_externalSecrets_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.cluster_name}/${var.namespace}/*",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.cluster_name}/shared/*",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/shared/*",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/shared/*",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*",
        ]
      },
      {
        Action = [
          "ssm:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eso_role_policy_attachment" {
  policy_arn = aws_iam_policy.eso_policy.arn
  role       = aws_iam_role.eso_role.name
}

resource "aws_eks_pod_identity_association" "eso_pod_identity_association" {
  cluster_name = var.cluster_name
  # namespace = "external-secrets"
  # service_account = "external-secrets"
  namespace       = var.namespace
  service_account = "${var.namespace}:${var.namespace}-external-secret"
  role_arn        = aws_iam_role.eso_role.arn
}

# resource "aws_iam_role_policy_attachment" "eso_role_eks_kms_access_policy_attachment" {
#   policy_arn = data.aws_iam_policy.eks_kms_access.arn
#   role = aws_iam_role.eso_role.name
# }
