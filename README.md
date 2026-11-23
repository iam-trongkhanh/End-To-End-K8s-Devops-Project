# End-To-End-K8s-Devops-Project: an AWS DevSecOps lab

University lab by Khanh Trong Le (Lê Trọng Khánh). Source for a Jenkins → Terraform →
Amazon EKS setup, with an Argo CD ingress declaration and setup scripts for the Jenkins
server and a jump server.

**Scope.** This repository holds infrastructure code, setup scripts and Kubernetes
manifests. It is not a record of a running cluster, an executed application pipeline or a
live domain. Some values must be configured before use: the Argo CD `repoURL`, the ingress
hosts (`*.example.com`) and the repository the `Jenkinsfile` checks out
(`iam-trongkhanh/EKS-Cluster`, the name used in `PROJECT_SUMMARY.md`).

**Case study:** [AWS DevSecOps delivery lab](https://khanhcloud.online/work/aws-devsecops/)
walks through the Jenkins Terraform workflow, the EKS module inputs and the Argo CD ingress
Application, with links to the exact lines at commit `79c4d61`.

## What the files do

| Path | Contents |
|---|---|
| `Jenkinsfile` | Parameterized Terraform job: `init` and `validate` on `eks/`, then `plan`, `apply` or `destroy` with `<Environment>.tfvars`. `apply` and `destroy` run with `-auto-approve`. |
| `eks/`, `module/` | A VPC in `ap-southeast-2` with three public and three private subnets and one NAT gateway for private egress; an EKS 1.30 cluster with a private-only API endpoint; on-demand and Spot managed node groups; an IAM OIDC provider; add-ons vpc-cni, coredns, kube-proxy and aws-ebs-csi-driver. |
| `setup-backend.tf` | S3 bucket (versioning, server-side encryption) and DynamoDB table for Terraform remote state and locking. |
| `jenkins-server-setup.sh` | EC2 user data for the Jenkins server: Jenkins, Docker, Terraform, AWS CLI, Trivy, eksctl, kubectl and a SonarQube container. |
| `jump-server.sh` | EC2 user data for a jump server with AWS CLI, kubectl, Helm and eksctl. The API endpoint is private (`endpoint-public-access = false`), so `kubectl` has to run from inside the VPC. |
| `install-aws-load-balancer-controller.sh` | Creates an IRSA service account with eksctl and installs the AWS Load Balancer Controller with Helm. |
| `k8s/` | Namespaces for frontend, backend and database; ALB ingress manifests (internet-facing for frontend and backend, internal for database); an Argo CD Application that syncs `k8s/ingress/` with automated pruning and self-healing. |

## Not in this repository

Application build and image-scan stages, ECR repositories, application Deployments,
persistent volume claims, Prometheus/Grafana and DNS records belong to the lab's target
architecture. There is no code or log for them here, so this README does not claim them.

## Setup

Step-by-step notes are in `README_SETUP.md`. Create the state backend first
(`setup-backend.tf`), then run the Jenkins job with `plan` before `apply`.
