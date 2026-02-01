variable "cluster_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "application" {
  type = string
}

variable "env" {
  type = string
}

variable "component" {
  type = string
}

variable "region" {
  type = string
  default = "ap-south-1"
}
