provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      Application    = local.application
      Environment    = local.env
      CostCenter     = local.cost_center
      CreatedBy      = "terraform"
      // TerraformStack = replace(path.cwd, "/.*cloudhandson-kube-tf-bootstrap/", "/cloudhandson-kube-tf-bootstrap")
      TerraformStack = "/cloudhandson-kube-tf-bootstrap"
      Reason         = local.component
      component      = local.component
      Product        = local.component
      ProductVersion = local.component_version
      ApplicationId = "fec9a6fe-2536-49e7-9fcc-43d08d2ab98d"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "cloudhandson-${AWS_ENV}-terraform-tfstate"
    key    = "terraform/${AWS_ENV}/cloudhandson/eks/${CLUSTER_ENV}/${CLUSTER_NAME}/${APPLICATION_NAME}-tf-resources.tfstate"
    region = "ap-south-1"
  }
}

locals {
  env               = "${CLUSTER_ENV}"
  region            = "ap-south-1"
  application       = "cloudhandson"
  application_name  = "${APPLICATION_NAME}"
  namespace         = "${APPLICATION_NAMESPACE}"
  cluster_name      = "${CLUSTER_NAME}"
  eks_cluster_name  = "${local.cluster_name}-${local.env}-eks-cluster"
  component         = "eks"
  component_version = "1.33"
  cost_center       = "cloudhandson-eks" #to be updated
}

module "project_tf_bootstrap" {
  component         = local.component
  source            = "./resources"
  namespace         = local.namespace
  application       = local.application_name
  env               = local.env
  eks_cluster_name  = local.eks_cluster_name
  perimeter         = local.cluster_name
}
