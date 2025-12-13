# EKS-Cluster

Project Overview

This project implements a production-like DevSecOps pipeline on AWS using Jenkins, Amazon EKS, and ArgoCD.

I provisioned cloud infrastructure using Terraform and AWS CLI, including an EC2-based Jenkins server with secure access managed through IAM. The Jenkins environment was configured with essential DevOps and security tools such as Docker, SonarQube, Trivy, Terraform, kubectl, and AWS CLI.

A managed Amazon EKS cluster was deployed using eksctl, with applications exposed through an AWS Application Load Balancer (ALB). Container images for frontend and backend services were built and stored in Amazon ECR, and Jenkins pipelines were implemented to automate build, quality checks, security scanning, and deployment.

For continuous delivery, ArgoCD was used to apply GitOps practices, deploying a three-tier application (database, backend, frontend, ingress) in a declarative manner. Persistent Volumes and PVCs were configured to ensure data durability, while Prometheus and Grafana provided monitoring and observability. The application was made publicly accessible via custom DNS subdomains.
