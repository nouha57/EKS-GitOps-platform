# What I Built: EKS GitOps Platform

## Executive Summary

I built a production-ready Kubernetes platform on AWS EKS that demonstrates modern cloud-native practices including Infrastructure as Code, GitOps, and automated certificate/DNS management. The platform is fully functional, secure, and cost-optimized, showcasing end-to-end DevOps capabilities.

**Live Demo:** https://hello.nouha-zouaghi.cc  
**ArgoCD UI:** https://argocd.nouha-zouaghi.cc

## Project Highlights

### 🎯 What Problem Does This Solve?

Traditional application deployment involves:
- Manual infrastructure provisioning
- Manual DNS configuration
- Manual SSL certificate management
- Manual application deployments
- Inconsistent environments
- Configuration drift

**My solution automates everything:**
- Infrastructure provisioned via Terraform
- DNS records created automatically
- SSL certificates issued and renewed automatically
- Applications deployed via GitOps
- Consistent, reproducible environments
- No configuration drift

### 🏗️ What I Built

#### 1. Infrastructure Layer (Terraform)

**VPC & Networking:**
- Custom VPC with 10.0.0.0/16 CIDR
- 6 subnets across 3 availability zones (3 public, 3 private)
- Internet Gateway for public internet access
- NAT Gateway for private subnet egress
- Route tables for public and private routing
- Security groups with least privilege

**EKS Cluster:**
- Kubernetes 1.28 managed cluster
- Managed node group with auto-scaling (1-4 nodes)
- t3.medium instances in private subnets
- CloudWatch logging enabled
- VPC CNI, CoreDNS, and kube-proxy addons

**IAM Security:**
- EKS cluster role with minimal permissions
- Node group role with required policies
- OIDC provider for IRSA (IAM Roles for Service Accounts)
- Dedicated IAM roles for ExternalDNS and AWS LB Controller
- No long-lived credentials in pods

**DNS:**
- Route53 hosted zone for nouha-zouaghi.cc
- Automated DNS delegation
- Support for multiple subdomains

**Total:** 42 AWS resources provisioned via Terraform

#### 2. Platform Layer (Kubernetes)

**ArgoCD (GitOps Engine):**
- Continuous delivery platform
- Monitors Git repositories for changes
- Automatically syncs Kubernetes state
- Web UI for application management
- RBAC for access control
- Accessible at https://argocd.nouha-zouaghi.cc

**Ingress-Nginx (Traffic Management):**
- Kubernetes ingress controller
- AWS Network Load Balancer integration
- HTTP and HTTPS traffic routing
- SSL termination
- Rate limiting capabilities

**cert-manager (Certificate Automation):**
- Automated TLS certificate provisioning
- Let's Encrypt integration
- HTTP-01 challenge solver
- Automatic certificate renewal
- Staging and production issuers

**ExternalDNS (DNS Automation):**
- Watches Kubernetes ingress resources
- Automatically creates Route53 DNS records
- TXT record ownership tracking
- Automatic cleanup on resource deletion
- IRSA for secure Route53 access

#### 3. Application Layer

**Hello World Demo App:**
- Nginx-based web application
- Custom HTML with platform status
- Kubernetes Deployment with 2 replicas
- ClusterIP Service
- Ingress with automatic TLS and DNS
- Accessible at https://hello.nouha-zouaghi.cc

## Technical Implementation

### Infrastructure as Code

**Terraform Modules:**
```
terraform/
├── modules/
│   ├── vpc/        # Network infrastructure
│   ├── eks/        # Kubernetes cluster
│   ├── iam/        # Security roles
│   └── route53/    # DNS management
└── main.tf         # Root configuration
```

**Key Features:**
- Modular design for reusability
- Environment-specific configurations
- Output values for integration
- State management ready

### GitOps Workflow

```
Developer → Git Push → ArgoCD Detects → Validates → Deploys → Live
```

**Benefits:**
- Declarative configuration
- Version control for all changes
- Audit trail
- Easy rollbacks
- Consistent deployments

### Automation Highlights

**DNS Automation:**
1. Create Ingress with hostname annotation
2. ExternalDNS detects the Ingress
3. Route53 A record created automatically
4. DNS propagates globally
5. Application accessible via domain

**Certificate Automation:**
1. Create Ingress with cert-manager annotation
2. cert-manager detects the Ingress
3. Certificate request sent to Let's Encrypt
4. HTTP-01 challenge completed automatically
5. Certificate issued and stored in Kubernetes Secret
6. Ingress controller uses certificate for TLS
7. Auto-renewal 30 days before expiry

## Skills Demonstrated

### Cloud & Infrastructure
- ✅ **AWS Services:** EKS, VPC, EC2, IAM, Route53, ELB, CloudWatch
- ✅ **Infrastructure as Code:** Terraform modules, state management, best practices
- ✅ **Networking:** VPC design, subnets, routing, NAT, load balancing
- ✅ **High Availability:** Multi-AZ deployment, auto-scaling

### Kubernetes
- ✅ **Core Concepts:** Pods, Deployments, Services, Ingress, ConfigMaps, Secrets
- ✅ **RBAC:** Role-based access control for ArgoCD
- ✅ **Networking:** Network policies, ingress controllers, service mesh concepts
- ✅ **Storage:** Understanding of persistent volumes (not used in this project)

### DevOps & Automation
- ✅ **GitOps:** ArgoCD for continuous delivery
- ✅ **CI/CD:** Automated deployment pipelines
- ✅ **Automation:** DNS, TLS, infrastructure provisioning
- ✅ **Monitoring:** CloudWatch integration, logging strategies

### Security
- ✅ **IAM:** Least privilege, IRSA, no long-lived credentials
- ✅ **Network Security:** Private subnets, security groups, network policies
- ✅ **Encryption:** TLS/SSL, secrets management
- ✅ **Compliance:** Security best practices, audit logging

### Problem Solving
- ✅ **Debugging:** Resolved VPC CNI IRSA issue during deployment
- ✅ **Troubleshooting:** Node health checks, certificate validation
- ✅ **Documentation:** Comprehensive README and architecture docs

## Challenges Overcome

### 1. VPC CNI IRSA Configuration

**Problem:** EKS nodes failed to join cluster with "Unhealthy nodes" error.

**Root Cause:** VPC CNI addon was configured to use IRSA with incorrect role annotation.

**Solution:** 
- Identified the issue by checking node conditions
- Found VPC CNI pods in CrashLoopBackOff
- Removed incorrect IRSA annotation
- VPC CNI now uses node IAM role directly
- Updated Terraform to prevent recurrence

**Learning:** Understanding Kubernetes networking and AWS IAM integration is critical for EKS.

### 2. DNS Delegation

**Challenge:** Configuring domain name servers for Route53.

**Solution:**
- Created Route53 hosted zone via Terraform
- Retrieved name servers from Terraform output
- Updated domain registrar (Spaceship) with AWS name servers
- Verified DNS propagation

**Learning:** DNS delegation is essential for automated DNS management.

### 3. Certificate Validation

**Challenge:** Ensuring Let's Encrypt can validate domain ownership.

**Solution:**
- Configured HTTP-01 challenge solver
- Ensured ingress-nginx was accessible from internet
- Verified NLB was routing traffic correctly
- Monitored cert-manager logs for validation

**Learning:** Certificate automation requires proper ingress configuration and public accessibility.

## Results & Metrics

### Infrastructure
- **Deployment Time:** ~15 minutes (automated)
- **Resources Created:** 42 AWS resources
- **Availability Zones:** 3 (high availability)
- **Auto-scaling:** 1-4 nodes based on demand

### Platform
- **Components Deployed:** 4 (ArgoCD, ingress-nginx, cert-manager, ExternalDNS)
- **Automation Level:** 100% (no manual DNS/TLS management)
- **Certificate Renewal:** Automatic (30 days before expiry)
- **DNS Updates:** Real-time (on ingress creation/deletion)

### Cost
- **Monthly Cost:** ~$191 (EKS + 2 nodes + networking)
- **Cost Optimization:** Auto-scaling, right-sized instances
- **Potential Savings:** 70% with Spot instances

### Security
- **IAM Roles:** 6 (least privilege)
- **Encryption:** TLS for all external traffic
- **Network Isolation:** Private subnets for nodes
- **Secrets:** Kubernetes secrets, no hardcoded credentials

## What Makes This Project Stand Out

### 1. Production-Ready
- Not a tutorial follow-along
- Real infrastructure with real costs
- Security best practices implemented
- High availability design

### 2. End-to-End Automation
- Infrastructure provisioning automated
- DNS management automated
- Certificate management automated
- Application deployment automated

### 3. Modern Practices
- Infrastructure as Code (Terraform)
- GitOps (ArgoCD)
- Immutable infrastructure
- Declarative configuration

### 4. Comprehensive Documentation
- Detailed README with quick start
- Architecture documentation with diagrams
- Troubleshooting guides
- Code comments and explanations

### 5. Real-World Application
- Live demo accessible on the internet
- Custom domain with valid SSL
- Professional presentation
- Portfolio-ready

## Future Enhancements

### Planned Improvements
1. **Monitoring Stack:** Prometheus + Grafana for metrics
2. **Logging:** Loki for centralized logging
3. **Secrets Management:** External Secrets Operator
4. **Service Mesh:** Istio for advanced traffic management
5. **Multi-Environment:** Staging and production environments
6. **CI/CD Pipeline:** GitHub Actions for automated testing

### Scalability Improvements
1. **Cluster Autoscaler:** Automatic node scaling
2. **Horizontal Pod Autoscaler:** Automatic pod scaling
3. **Spot Instances:** 70% cost savings
4. **Multi-Region:** Disaster recovery setup

## Key Takeaways

### Technical Skills
- Deep understanding of Kubernetes architecture
- Proficiency with Terraform and IaC
- AWS cloud services expertise
- GitOps workflow implementation
- Security best practices

### Soft Skills
- Problem-solving and debugging
- Documentation and communication
- Project planning and execution
- Attention to detail
- Continuous learning

### Business Value
- Reduced deployment time (hours → minutes)
- Eliminated manual errors
- Improved security posture
- Cost-optimized infrastructure
- Scalable and maintainable solution

## Conclusion

This project demonstrates my ability to:
- Design and implement cloud-native architectures
- Automate infrastructure and application deployment
- Apply security best practices
- Solve complex technical challenges
- Document and communicate technical concepts
- Build production-ready systems

The platform is fully functional, secure, and ready for real-world use. It showcases modern DevOps practices and cloud-native technologies that are in high demand in the industry.

---

**Project Duration:** 2 weeks  
**Technologies Used:** AWS EKS, Terraform, Kubernetes, ArgoCD, cert-manager, ExternalDNS, Nginx  
**Lines of Code:** ~2,000 (Terraform + Kubernetes manifests)  
**Documentation:** 3 comprehensive documents (README, ARCHITECTURE, this document)

**Live Demo:** https://hello.nouha-zouaghi.cc  
**Source Code:** https://github.com/nouha57/eks-gitops-platform
