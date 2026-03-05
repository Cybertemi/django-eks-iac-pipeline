### Prime Choice – Django Application on AWS EKS

## Project Overview

Prime Choice is a Django-based web application deployed on Amazon EKS using a fully automated CI/CD pipeline. The project demonstrates an end-to-end DevOps workflow including infrastructure provisioning, containerization, vulnerability scanning and Kubernetes deployment.

This repository contains the application code, Terraform configuration for infrastructure, Docker setup for containerization, Kubernetes manifests for deployment and a GitHub Actions pipeline for automated builds and deployments. The goal of this project is to showcase modern DevOps practices for deploying scalable applications in the cloud.

### Architecture


Terraform – Infrastructure provisioning on AWS

AWS EKS – Managed Kubernetes cluster

Docker – Containerization of the Django application

Kubernetes – Container orchestration and deployment

PostgreSQL – Application database with persistent storage

GitHub Actions – CI/CD pipeline automation

Trivy – Container vulnerability scanning

DockerHub – Container image registry

### Prerequisites

To run or reproduce this project locally, ensure the following tools are installed:

Python 3.11+

pip

virtualenv

Docker

kubectl

AWS CLI

Terraform

Git

## Also, the following are needed:

AWS account with permissions for EKS, VPC, IAM, and EC2

DockerHub account for storing container images

GitHub repository for CI/CD pipeline execution

Local Application Setup (Quick Verification)

## NOTE
Local testing is optional but allows important for verification and to ensure the application runs before containerization.

### Steps for local testing

## Clone Repository
git clone <repository_url>
cd <repository_folder>
Create Virtual Environment
python -m venv venv
source venv/bin/activate (for linux)

venv\Scripts\activate (for wondows)

## Install Dependencies

pip install -r requirements.txt
Run the Application
python manage.py migrate
python manage.py runserver

The application will be available at:

http://127.0.0.1:8000

## Infrastructure Provisioning (Terraform)

Infrastructure is provisioned using Terraform to create AWS VPC, Subnets, IAM roles and EKS cluster

Run:

cd terraform
terraform init
terraform apply -auto-approve

Verify the cluster:

aws eks list-clusters --region us-east-1

## Docker Containerization

The Django application is packaged as a Docker container.

Build Image
docker build -t <dockerhub_username>/primechoice:<git_sha> .
Push Image
docker push <dockerhub_username>/primechoice:<git_sha>

## Kubernetes Deployment

The application and database are deployed using Kubernetes manifests.

Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name my-cluster

## Apply Kubernetes Resources

kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/django-configmap.yaml
kubectl apply -f kubernetes/django-secret.yaml
kubectl apply -f kubernetes/postgres-secret.yaml
kubectl apply -f kubernetes/postgres-pvc.yaml
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/postgres-service.yaml
kubectl apply -f kubernetes/django-deployment.yaml
kubectl apply -f kubernetes/django-service.yaml

## Verify Deployment

kubectl rollout status deployment/postgres -n django-app
kubectl rollout status deployment/django -n django-app

## Security Scanning with Trivy

Before deployment, Docker images are scanned for vulnerabilities using Trivy.

trivy image <dockerhub_username>/primechoice:<git_sha> --severity CRITICAL,HIGH

If vulnerabilities are detected:

Update dependencies in requirements.txt

Rebuild the Docker image

Redeploy the application

### CI/CD Pipeline (GitHub Actions)

The repository includes a GitHub Actions pipeline that automates the deployment process.This pipeline ensures consistent and automated deployments on every commit and its stages include:

Checkout repository

Configure AWS credentials

Authenticate with DockerHub

Build Docker image

Run Trivy vulnerability scan

Push image to DockerHub

Deploy Kubernetes manifests to EKS

Wait for PostgreSQL and Django rollout

Retrieve service information

Accessing the Live Application

## After deployment, retrieve the service details:

kubectl get svc -n django-app

Example output:

NAME       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)
django     LoadBalancer   172.xx.xx.xx    <external-ip>        80:31065/TCP


### Screenshots


Pipeline Success: pipeline_success.png

Terraform Infrastructure Provisionig: terraform_infra.png

Trivy Vulnerability Scan: trivy_scan.png

Live Application Running: django_live_app.png

### Troubleshooting
In a case of Pod CrashLoopBackOff or any other errors:

kubectl describe pod <pod-name> -n django-app
kubectl logs <pod-name> -n django-app
PVC Issues

### NOTE

Ensure the PersistentVolumeClaim is created before deploying PostgreSQL.

kubectl get pvc -n django-app


### Conclusion

This project demonstrates a complete DevOps workflow for deploying a Django application on AWS using modern cloud-native tools. Infrastructure is provisioned with Terraform, the application is containerized with Docker, security is enforced through vulnerability scanning, and deployment is automated through a CI/CD pipeline. Kubernetes ensures scalable and reliable application management, making the system reproducible and production-ready.

### Author

Temitope Ilori
Linkedin: http://linkedin.com/in/iloritemi
