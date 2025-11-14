# EKS GitOps Platform

A production-ready Kubernetes platform on AWS EKS implementing GitOps principles with automated infrastructure provisioning, certificate management, and DNS configuration.

![Platform Status](https://img.shields.io/badge/status-production-green)
![Kubernetes](https://img.shields.io/badge/kubernetes-1.28-blue)
![Terraform](https://img.shields.io/badge/terraform-1.6+-purple)
![AWS](https://img.shields.io/badge/AWS-EKS-orange)

## 🎯 Project Overview

This project demonstrates a complete cloud-native platform built on AWS EKS, showcasing modern DevOps practices including Infrastructure as Code (IaC), GitOps, and automated certificate/DNS management. The platform is designed to be production-ready, secure, and cost-effective.

## 🌐 Live Demo

> **Status: Currently Live** ✅
> 
> The platform is currently deployed and accessible at:
> - **ArgoCD UI:** https://argocd.nouha-zouaghi.cc
> - **Demo Application:** https://hello.nouha-zouaghi.cc
>
> *Note: Infrastructure may be temporarily destroyed to manage costs (~$191/month). 
> The platform can be redeployed in ~15 minutes using the provided Terraform code. 
> Screenshots of the working deployment are available below.*

<!-- 
DEPLOYMENT STATUS INSTRUCTIONS:
When infrastructure is LIVE, use this:

> **Status: Currently Live** ✅
> 
> The platform is currently deployed and accessible at:
> - **ArgoCD UI:** https://argocd.nouha-zouaghi.cc
> - **Demo Application:** https://hello.nouha-zouaghi.cc

When infrastructure is DESTROYED, use this:

> **Status: Temporarily Offline** 💤
> 
> The platform was live at:
> - **ArgoCD UI:** https://argocd.nouha-zouaghi.cc
> - **Demo Application:** https://hello.nouha-zouaghi.cc
>
> Infrastructure has been temporarily destroyed to manage costs (~$191/month).
> The platform can be redeployed in ~15 minutes using the provided Terraform code.
> Screenshots below show the working deployment.
-->

## 📸 Screenshots

### ArgoCD Dashboard
![ArgoCD Dashboard](docs/screenshots/argocd-dashboard.png)
*GitOps continuous delivery platform managing all applications*

### Hello World Application
![Hello World App](docs/screenshots/hello-world-app.png)
*Demo application with automatic HTTPS and DNS*

### AWS EKS Cluster
![EKS Cluster](docs/screenshots/eks-cluster.png)
*Managed Kubernetes cluster in AWS Console*

### Valid SSL Certificate
![SSL Certificate](docs/screenshots/ssl-certificate.png)
*Automatic Let's Encrypt certificate with cert-manager*

> **Note:** To add screenshots, create a `docs/screenshots/` directory and add your images there.

## 🏗️ Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │ Route53 │ (DNS: nouha-zouaghi.cc)
                    └────┬────┘
                         │
                    ┌────▼────────────────────────────────┐
                    │  Network Load Balancer (NLB)        │
                    └────┬────────────────────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │         EKS Cluster              │
        │  ┌───────────────────────────┐  │
        │  │   Ingress-Nginx           │  │
        │  │   (SSL Termination)       │  │
        │  └───────────┬───────────────┘  │
        │              │                   │
        │  ┌───────────┴───────────────┐  │
        │  │  Platform Components      │  │
        │  │  • ArgoCD                 │  │
        │  │  • cert-manager           │  │
        │  │  • external-dns           │  │
        │  └───────────────────────────┘  │
        │                                  │
        │  ┌───────────────────────────┐  │
        │  │  Applications             │  │
        │  │  • Hello World Demo       │  │
        │  │  • Your Apps Here         │  │
        │  └───────────────────────────┘  │
        └──────────────────────────────────┘
```

### Network Architecture

- **VPC:** 10.0.0.0/16 across 3 Availability Zones
- **Public Subnets:** 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24
- **Private Subnets:** 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
- **NAT Gateway:** For private subnet internet access
- **Internet Gateway:** For public subnet connectivity

## ✨ Features

### Infrastructure
- ✅ **AWS EKS 1.28** - Managed Kubernetes cluster
- ✅ **Multi-AZ Deployment** - High availability across 3 availability zones
- ✅ **Auto-scaling Node Groups** - Dynamic scaling (1-4 nodes)
- ✅ **VPC with Public/Private Subnets** - Secure network architecture
- ✅ **IAM Roles for Service Accounts (IRSA)** - Secure AWS API access

### Platform Components
- ✅ **ArgoCD** - GitOps continuous delivery
- ✅ **Ingress-Nginx** - Kubernetes ingress controller with NLB
- ✅ **cert-manager** - Automated TLS certificate management (Let's Encrypt)
- ✅ **ExternalDNS** - Automated DNS record management (Route53)

### Security
- ✅ **TLS/SSL Encryption** - Automatic HTTPS with Let's Encrypt
- ✅ **Network Policies** - Pod-to-pod communication control
- ✅ **IAM Least Privilege** - Minimal permissions per component
- ✅ **Private Node Groups** - Worker nodes in private subnets
- ✅ **Secrets Management** - Kubernetes secrets for sensitive data

### Automation
- ✅ **Infrastructure as Code** - Terraform for all AWS resources
- ✅ **GitOps Workflow** - ArgoCD for application deployment
- ✅ **Automatic DNS** - ExternalDNS creates Route53 records
- ✅ **Automatic TLS** - cert-manager provisions certificates

## 🚀 Quick Start

### Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured (`aws configure`)
- kubectl installed
- Terraform >= 1.6
- A registered domain name

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/eks-gitops-platform.git
cd eks-gitops-platform
```

### 2. Configure Variables

Edit `terraform/environments/dev/terraform.tfvars`:

```hcl
domain_name = "your-domain.com"  # Replace with your domain
cluster_name = "eks-gitops-platform-dev"
region = "us-east-2"
```

### 3. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

This will create (~15 minutes):
- VPC with networking
- EKS cluster
- Node groups
- IAM roles
- Route53 hosted zone

### 4. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-2 --name eks-gitops-platform-dev
kubectl get nodes
```

### 5. Update Domain Name Servers

Get the Route53 name servers:

```bash
terraform output route53_name_servers
```

Update your domain registrar with these name servers.

### 6. Deploy Platform Components

```bash
# Install ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

# Wait for cert-manager
kubectl wait --namespace cert-manager --for=condition=ready pod --selector=app.kubernetes.io/instance=cert-manager --timeout=300s

# Create ClusterIssuers
kubectl apply -f kubernetes/platform/cert-manager/

# Deploy ExternalDNS
kubectl apply -f kubernetes/platform/external-dns/
```

### 7. Install ArgoCD

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Configure insecure mode
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd

# Create ArgoCD ingress
kubectl apply -f kubernetes/platform/argocd/ingress.yaml

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### 8. Deploy Sample Application

```bash
kubectl apply -f kubernetes/applications/hello-world/
```

Access your application at: `https://hello.your-domain.com`

## 📊 What's Deployed

### Infrastructure Resources (42 AWS Resources)

| Resource Type | Count | Purpose |
|--------------|-------|---------|
| VPC | 1 | Network isolation |
| Subnets | 6 | 3 public + 3 private across AZs |
| NAT Gateway | 1 | Private subnet internet access |
| Internet Gateway | 1 | Public subnet internet access |
| Route Tables | 2 | Public and private routing |
| EKS Cluster | 1 | Kubernetes control plane |
| EKS Node Group | 1 | Worker nodes (2x t3.medium) |
| IAM Roles | 6 | Cluster, nodes, and IRSA roles |
| IAM Policies | 3 | Custom policies for platform components |
| Route53 Hosted Zone | 1 | DNS management |
| Security Groups | 1 | EKS cluster security |
| CloudWatch Log Group | 1 | EKS cluster logs |

### Kubernetes Resources

| Component | Namespace | Purpose |
|-----------|-----------|---------|
| ArgoCD | argocd | GitOps continuous delivery |
| Ingress-Nginx | ingress-nginx | Ingress controller + NLB |
| cert-manager | cert-manager | TLS certificate automation |
| ExternalDNS | external-dns | DNS record automation |
| Hello World | applications | Demo application |

## 💰 Cost Estimate

Approximate monthly costs (us-east-2 region):

| Service | Cost |
|---------|------|
| EKS Control Plane | $73/month |
| EC2 Instances (2x t3.medium) | ~$60/month |
| NAT Gateway | ~$32/month |
| Network Load Balancer | ~$16/month |
| Route53 Hosted Zone | $0.50/month |
| Data Transfer | ~$10/month |
| **Total** | **~$191/month** |

## 🛠️ Technology Stack

### Infrastructure
- **AWS EKS** - Managed Kubernetes service
- **Terraform** - Infrastructure as Code
- **VPC** - Network isolation and security

### Platform
- **ArgoCD** - GitOps continuous delivery
- **Ingress-Nginx** - Kubernetes ingress controller
- **cert-manager** - Automated certificate management
- **ExternalDNS** - Automated DNS management

### Kubernetes
- **Version:** 1.28
- **CNI:** AWS VPC CNI
- **DNS:** CoreDNS
- **Proxy:** kube-proxy

## 📁 Project Structure

```
.
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                  # Root configuration
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   ├── versions.tf              # Provider configuration
│   ├── modules/
│   │   ├── vpc/                 # VPC module
│   │   ├── eks/                 # EKS cluster module
│   │   ├── iam/                 # IAM roles module
│   │   └── route53/             # Route53 module
│   └── environments/
│       └── dev/
│           └── terraform.tfvars # Dev environment values
│
├── kubernetes/                   # Kubernetes manifests
│   ├── platform/                # Platform components
│   │   ├── namespaces/          # Namespace definitions
│   │   ├── argocd/              # ArgoCD configuration
│   │   ├── ingress-nginx/       # Ingress controller
│   │   ├── cert-manager/        # Certificate management
│   │   └── external-dns/        # DNS automation
│   └── applications/            # Application manifests
│       └── hello-world/         # Demo application
│
├── .kiro/                       # Project specifications
│   └── specs/
│       └── eks-gitops-platform/
│           ├── requirements.md  # Project requirements
│           ├── design.md        # Architecture design
│           └── tasks.md         # Implementation tasks
│
└── README.md                    # This file
```

## 🔐 Security Best Practices

1. **Network Isolation**
   - Worker nodes in private subnets
   - NAT Gateway for controlled egress
   - Security groups with minimal permissions

2. **IAM Security**
   - IRSA for pod-level AWS permissions
   - Least privilege IAM policies
   - No long-lived credentials in pods

3. **TLS Encryption**
   - All external traffic encrypted (HTTPS)
   - Automatic certificate rotation
   - Let's Encrypt production certificates

4. **Kubernetes Security**
   - Network policies for pod communication
   - Resource limits on all pods
   - RBAC for ArgoCD access control

## 🧪 Testing the Platform

### 1. Verify Infrastructure

```bash
# Check EKS cluster
aws eks describe-cluster --name eks-gitops-platform-dev --region us-east-2

# Check nodes
kubectl get nodes

# Check all pods
kubectl get pods -A
```

### 2. Verify Platform Components

```bash
# Check ingress controller
kubectl get svc -n ingress-nginx

# Check cert-manager
kubectl get pods -n cert-manager

# Check certificates
kubectl get certificate -A

# Check DNS records
kubectl get ingress -A
```

### 3. Access Applications

- **ArgoCD:** https://argocd.nouha-zouaghi.cc
- **Hello World:** https://hello.nouha-zouaghi.cc

## 🐛 Troubleshooting

### Pods Not Starting

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### Certificate Not Issuing

```bash
kubectl describe certificate <cert-name> -n <namespace>
kubectl get challenge -A
kubectl logs -n cert-manager deployment/cert-manager
```

### DNS Not Resolving

```bash
# Check ExternalDNS logs
kubectl logs -n external-dns deployment/external-dns

# Check Route53 records
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>

# Test DNS resolution
nslookup hello.nouha-zouaghi.cc
```

### Ingress Not Working

```bash
kubectl describe ingress <ingress-name> -n <namespace>
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## 🧹 Cleanup

To destroy all resources and avoid charges:

```bash
# Delete Kubernetes resources first
kubectl delete -f kubernetes/applications/hello-world/
kubectl delete -f kubernetes/platform/argocd/ingress.yaml
kubectl delete namespace argocd ingress-nginx cert-manager external-dns applications

# Wait for LoadBalancers to be deleted (important!)
kubectl get svc -A

# Destroy infrastructure
cd terraform
terraform destroy -var-file=environments/dev/terraform.tfvars
```

**Important:** Ensure all LoadBalancers are deleted before running `terraform destroy`, otherwise VPC deletion will fail.

## 📚 Skills Demonstrated

This project showcases proficiency in:

- ✅ **AWS Services** - EKS, VPC, IAM, Route53, NLB, CloudWatch
- ✅ **Infrastructure as Code** - Terraform modules and best practices
- ✅ **Kubernetes** - Deployments, Services, Ingress, RBAC, Network Policies
- ✅ **GitOps** - ArgoCD for continuous delivery
- ✅ **DevOps Automation** - Automated DNS, TLS, and deployments
- ✅ **Networking** - VPC design, subnets, routing, load balancing
- ✅ **Security** - IAM, IRSA, TLS, network policies, least privilege
- ✅ **Cloud Architecture** - High availability, scalability, cost optimization

## 🎓 Learning Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [cert-manager Documentation](https://cert-manager.io/docs/)

## 📝 License

This project is open source and available under the MIT License.

## 👤 Author

**Nouha Zouaghi**

- Domain: [nouha-zouaghi.cc](https://nouha-zouaghi.cc)
- GitHub: [@nouha57](https://github.com/nouha57)

## 🙏 Acknowledgments

- AWS for EKS and cloud infrastructure
- ArgoCD team for GitOps tooling
- cert-manager and Let's Encrypt for free TLS certificates
- Kubernetes community for excellent documentation

---

**⭐ If you found this project helpful, please consider giving it a star!**
#   E K S - G i t O p s - p l a t f o r m  
 