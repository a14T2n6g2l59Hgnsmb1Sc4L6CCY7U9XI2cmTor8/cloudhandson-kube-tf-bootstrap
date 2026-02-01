# cloudhandson-kube-tf-bootstrap

* This repository is used to **provision and manage AWS resources required for bootstrapping EKS clusters**
using **Terraform**.

* It prepares infrastructure components around EKS, such as IAM roles, policies, DNS records, parameter store values, and EFS-related resources.

## Repository structure

```text
.
├── .github/workflows/
│   └── lab.yaml                       # CI/CD workflow for lab env
│   └── main.yaml                      # CI/CD workflow for dev/qa/preprod/prod env
├── bin/
│   ├── cicd.sh                        # Local Terraform execution script
│   └── main.tf                        # Terraform template
├── resources/
│   ├── data.tf
│   ├── efs.tf
│   ├── iam_application.tf
│   ├── iam_external_secrets.tf
│   ├── locals.tf
│   ├── parameter_store.tf
│   ├── route53.tf
│   ├── variables.tf
│   └── policies/
│       └── <application>/
│           └── policies-<env>.json
└── README.md
```

## How it works
- `bin/main.tf` is a Terraform **template**
- Environment variables are injected using `envsubst`
- The generated `main.tf` calls the Terraform module located in `./resources`
- Terraform state is stored in a remote **S3 backend**

## Environment variables

Terraform uses environment variables that are injected into `bin/main.tf` using the `envsubst` command.

These variables must be defined **before Terraform is executed**, either:
- by the CI/CD workflow, or
- by the local execution script (`cicd.sh`)

### Required variables

| Variable name | Description | Example |
|--------------|------------|---------|
| `AWS_ENV` | AWS environment used for backend and tagging | `lab`, `noprod`, `prod` |
| `CLUSTER_ENV` | The environment of the cluster | `lab`, `dev`, `qa`, `preprod`, `prod` |
| `CLUSTER_NAME` | Name of the EKS cluster | `common`, `b2c` |
| `APPLICATION_NAME` | Application identifier | **Dynamic:** the script builds `applications_list` using GitHub CLI (commented line). It lists repos in `GH_ORG` filtered by topics (`$ENV,$CLUSTER`), then converts repo names into application names. **Static:** the script sets `applications_list="wm-octpassthrough"` and runs only for that application. |
| `NAMESPACE` | Kubernetes namespace for the application | Always derived from the current application in the loop (`NAMESPACE`=`APPLICATION_NAME`) |


## Execution methods

The repository supports **two execution modes**:
1. **CI/CD workflow (recommended)**
2. **Local execution using a shell script:** ./bin/cicd.sh

### Method 1 – CI/CD workflow (recommended)
Terraform is executed through a GitHub Actions workflow that calls a reusable workflow and applies changes.
It runs Terraform sequentially in the following order: dev -> qa -> preprod -> prod

#### Triggers
The workflow is triggered:
- On push to the `master` branch
- Manually using `workflow_dispatch`

### Method 2 – Local execution (shell script)
Local execution is mainly intended for:
- Development
- Testing
- Troubleshooting

#### Local requirements

- Terraform ≥ 1.2.8
- AWS credentials configured locally
- Bash
- `envsubst`

#### Usage
```bash
# Terraform plan
./bin/cicd.sh dev common plan

# Terraform apply
./bin/cicd.sh dev common apply
```
# cloudhandson-kube-tf-bootstrap
