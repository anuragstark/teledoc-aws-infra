# TeleDoc — DevOps Infrastructure & CI/CD Pipeline

> **Production URL:** [teledoc.co.in](https://teledoc.co.in)
> **Live Site:** Hosted on Hostinger (production)
> **AWS Deployment:** Showcase infrastructure demonstrating DevOps capabilities

---

## 🏗️ Architecture

```
                        ┌─────────────────────────────────┐
                        │         GitHub Actions           │
                        │   Build → Test → Scan → Deploy   │
                        └──────────────┬──────────────────┘
                                       │
                        ┌──────────────▼──────────────────┐
                        │          AWS ECR                 │
                        │   teledoc-frontend               │
                        │   teledoc-backend                │
                        └──────────────┬──────────────────┘
                                       │
           ┌───────────────────────────▼───────────────────────────┐
           │                    AWS VPC (10.0.0.0/16)              │
           │                                                       │
           │    ┌─────────────────┐     ┌──────────────────┐      │
           │    │      ALB        │     │  Monitor EC2     │      │
           │    │  (Port 80)      │     │  (t2.micro)      │      │
           │    └────────┬────────┘     │  • Prometheus    │      │
           │             │              │  • Grafana       │      │
           │             ▼              │  • Blackbox      │      │
           │    ┌─────────────────┐     └──────────────────┘      │
           │    │   App EC2       │                                │
           │    │   (t2.medium)   │     ┌──────────────────┐      │
           │    │   • React/NGINX │     │   RDS MySQL      │      │
           │    │   • Laravel/PHP │────▶│   (db.t3.micro)  │      │
           │    │   • Node Export │     │   7-day backups   │      │
           │    │   • cAdvisor    │     └──────────────────┘      │
           │    └─────────────────┘                                │
           └───────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Category | Tools |
|---|---|
| **Infrastructure as Code** | Terraform (AWS provider, S3 remote state) |
| **Configuration Management** | Ansible (roles, playbooks, Jinja2 templates) |
| **CI/CD** | GitHub Actions (Build → Test → Trivy Scan → ECR Push → Deploy) |
| **Containerization** | Docker (multi-stage builds), Docker Compose |
| **Cloud Platform** | AWS (VPC, EC2, ALB, RDS, ECR, IAM, Security Groups) |
| **Reverse Proxy** | NGINX (SPA routing, API proxy, gzip, caching) |
| **Monitoring** | Prometheus + Grafana + Blackbox Exporter |
| **Database** | RDS MySQL 8.0 (automated backups, 7-day retention) |

---

## 📁 Project Structure

```
├── .github/workflows/
│   └── deploy.yml              # CI/CD Pipeline
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Provider & backend config
│   ├── vpc.tf                  # VPC, subnets, IGW
│   ├── ec2.tf                  # App & Monitor instances
│   ├── alb.tf                  # Load Balancer
│   ├── rds.tf                  # MySQL database
│   ├── ecr.tf                  # Container registry
│   ├── iam.tf                  # Roles & policies
│   ├── security-groups.tf      # Network security
│   ├── variables.tf            # Input variables
│   └── outputs.tf              # Output values
│
├── ansible/                     # Configuration Management
│   ├── playbooks/
│   │   ├── setup-app-server.yml
│   │   ├── setup-monitoring.yml
│   │   └── deploy.yml
│   └── roles/
│       ├── docker/             # Docker installation
│       ├── app/                # App deployment
│       └── monitoring/         # Monitoring stack
│
├── monitoring/                  # Observability
│   ├── prometheus/prometheus.yml
│   ├── grafana/dashboards/     # Pre-built dashboards
│   └── docker-compose.monitoring.yml
│
├── nginx/default.conf           # NGINX reverse proxy
├── Dockerfile                   # Frontend (multi-stage)
├── backend/Dockerfile           # Backend (multi-stage)
└── docker-compose.prod.yml      # Production compose
```

---

## 🚀 Deployment Steps

### Prerequisites
- AWS CLI configured
- Terraform >= 1.5.0
- Ansible >= 2.14
- Docker

### 1. Create S3 Bucket (Terraform State)
```bash
aws s3 mb s3://teledoc-terraform-state --region ap-south-1
```

### 2. Deploy Infrastructure
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

### 3. Configure Ansible Inventory
```bash
# Update ansible/inventory/hosts.ini with Terraform outputs
terraform output app_server_public_ip
terraform output monitor_server_public_ip
```

### 4. Setup Servers
```bash
cd ../ansible
ansible-playbook playbooks/setup-app-server.yml -e @vars/production.yml
ansible-playbook playbooks/setup-monitoring.yml
```

### 5. Configure GitHub Secrets
| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |
| `EC2_HOST` | App server Elastic IP |
| `EC2_SSH_KEY` | Contents of teledoc.pem |

### 6. Push & Deploy
```bash
git push origin main
# GitHub Actions will automatically build, scan, and deploy
```

### 7. Setup Subdomain
Add CNAME record in Hostinger DNS:
```
aws.teledoc.co.in → teledoc-alb-XXXXX.ap-south-1.elb.amazonaws.com
```

---

## 📊 Monitoring

- **Grafana:** `http://<monitor-ip>:3000` (admin/teledoc123)
- **Prometheus:** `http://<monitor-ip>:9090`

### Pre-built Dashboards:
1. **Server Metrics** — CPU, Memory, Disk, Network (Node Exporter)
2. **Docker Containers** — Container CPU, Memory, Network (cAdvisor)
3. **Website Availability** — UP/DOWN status, Response Time (Blackbox)

---

## 🧹 Teardown

```bash
cd terraform
terraform destroy
```

This destroys all AWS resources. RDS automated backups are also deleted.

---

## 📸 Screenshots

See `devops/screenshots/` for AWS Console screenshots documenting the infrastructure.
