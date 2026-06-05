# TeleDoc Enterprise AWS Infrastructure

![TeleDoc AWS Architecture](Deployment%20Screenshots/TeleDoc_AWS_Architecture.gif)

**Live Domain:** [https://teledoc.co.in/](https://teledoc.co.in/)

This repository contains the complete, production-ready DevOps and Infrastructure-as-Code (IaC) setup for the **TeleDoc Platform**, a massive B2B telehealth and e-commerce marketplace.

**IMPORTANT NOTICE FOR REVIEWERS:** This repository is specifically designed to showcase the Cloud Infrastructure, CI/CD pipelines, and DevOps architecture. The actual proprietary application source code (Laravel Backend / React Frontend) is kept private and is not included here.

This infrastructure is designed for high availability, zero-downtime deployments, and automated scaling on AWS.

---

## Repository Structure

*   `terraform/` - Contains all IaC scripts to provision the entire AWS environment (VPC, ASG, RDS, Application Load Balancers, IAM Roles).
*   `ansible/` - Configuration management playbooks for server bootstrapping, installing dependencies, and configuring the Prometheus/Grafana monitoring stack on EC2 fleets.
*   `docker/` & `Dockerfile` - Multi-stage Dockerfiles optimizing Nginx and PHP-FPM containers for maximum performance under high traffic loads.
*   `.github/workflows/` - GitHub Actions pipelines (`deploy.yml`, `infra.yml`) enabling automated CI/CD and zero-downtime Blue/Green deployments.
*   `monitoring/` - Configuration files for Prometheus and Grafana dashboards for real-time visibility into system health.
*   `nginx/` - Nginx configurations to act as a secure reverse proxy and route SPA traffic seamlessly.
*   `convert-to-webp.sh` - An automated Bash pipeline to recursively optimize static image assets into WebP format, drastically improving LCP Core Web Vitals.
*   `Deployment Screenshots/` - Visual evidence of the infrastructure in action (Grafana dashboards, AWS console, successful CI/CD runs, and architecture diagrams).

---

## What We Built & How

### 1. Infrastructure as Code (Terraform)
Instead of clicking through the AWS console, the entire cloud environment was codified using Terraform. This includes setting up secure Virtual Private Clouds (VPCs), configuring Auto Scaling Groups (ASG) to handle traffic spikes, and provisioning a highly available RDS MySQL database.

### 2. Auto-Scaling & Health Checks
We implemented custom system health check APIs (e.g., `/ping` endpoints) that integrate directly with AWS Application Load Balancers (ALB). If an EC2 instance or backend container degrades, the ALB automatically stops sending it traffic and the Auto Scaling Group spins up a replacement—guaranteeing zero downtime.

### 3. Containerization (Docker)
The application layer was decoupled from the host OS using heavily optimized multi-stage Dockerfiles. Build dependencies are separated from the runtime environment (Nginx + PHP-FPM) to keep image sizes extremely small, accelerating deployment times and enhancing security.

### 4. Configuration Management & Monitoring (Ansible + Prometheus)
We used Ansible to fully automate server bootstrapping. Crucially, the **Ansible inventory is dynamically generated** by GitHub Actions using real-time Terraform outputs, ensuring playbooks always target the correct ephemeral EC2 instances. 
For observability, Prometheus uses **AWS EC2 Service Discovery (`ec2_sd_configs`)** to automatically detect and scrape metrics from new Auto Scaling instances the moment they launch. We also integrated the **Blackbox Exporter** to actively probe the Application Load Balancer via HTTP, verifying true external website availability.

### 5. Continuous Deployment & DevSecOps (GitHub Actions)
Fully automated workflows (`deploy.yml` and `infra.yml`) handle the entire deployment lifecycle:
* **Docker Buildx Caching (`type=gha`)**: Reuses unmodified Docker layers to significantly accelerate computationally expensive multi-stage builds.
* **Shift-Left Security (Trivy)**: Actively scans Docker images for `CRITICAL/HIGH` vulnerabilities, blocking insecure code before it ever reaches AWS ECR.
* **Zero-Trust Secrets**: Passwords are never baked into image layers. They are securely injected into containers at runtime via **AWS SSM Parameter Store**.
* **Zero-Downtime Rollouts**: The pipeline triggers an AWS Auto Scaling **Instance Refresh** to gracefully rotate instances without dropping a single user request.

---

## Note on Secrets
**This is a public portfolio repository.** All `.env` files, `.pem` SSH keys, and production database credentials have been explicitly excluded and stripped from this repository for security purposes. Any variables shown in `.example` files are purely for structural reference.

---
**Architected and Built by Anurag chauhan**
