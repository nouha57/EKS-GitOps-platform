# Architecture Documentation

## Table of Contents
1. [Overview](#overview)
2. [Infrastructure Architecture](#infrastructure-architecture)
3. [Network Architecture](#network-architecture)
4. [Security Architecture](#security-architecture)
5. [Application Flow](#application-flow)
6. [Component Details](#component-details)
7. [Data Flow](#data-flow)
8. [Disaster Recovery](#disaster-recovery)

## Overview

The EKS GitOps Platform is a production-ready Kubernetes platform built on AWS, implementing modern cloud-native patterns including GitOps, Infrastructure as Code, and automated certificate/DNS management.

### Design Principles

1. **Infrastructure as Code** - All infrastructure defined in Terraform
2. **GitOps** - Declarative application deployment via ArgoCD
3. **Security First** - Least privilege, encryption, network isolation
4. **Automation** - Minimize manual operations
5. **Cost Optimization** - Right-sized resources, auto-scaling
6. **High Availability** - Multi-AZ deployment

## Infrastructure Architecture

### AWS Resources

```
┌─────────────────────────────────────────────────────────────────────┐
│                           AWS Account                                │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    VPC (10.0.0.0/16)                         │   │
│  │                                                               │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │           Availability Zone us-east-2a               │   │   │
│  │  │  ┌────────────────┐    ┌────────────────┐           │   │   │
│  │  │  │ Public Subnet  │    │ Private Subnet │           │   │   │
│  │  │  │ 10.0.101.0/24  │    │ 10.0.1.0/24    │           │   │   │
│  │  │  │                │    │                │           │   │   │
│  │  │  │  NAT Gateway   │    │  EKS Node      │           │   │   │
│  │  │  │  NLB           │    │                │           │   │   │
│  │  │  └────────────────┘    └────────────────┘           │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  │                                                               │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │           Availability Zone us-east-2b               │   │   │
│  │  │  ┌────────────────┐    ┌────────────────┐           │   │   │
│  │  │  │ Public Subnet  │    │ Private Subnet │           │   │   │
│  │  │  │ 10.0.102.0/24  │    │ 10.0.2.0/24    │           │   │   │
│  │  │  │                │    │                │           │   │   │
│  │  │  │                │    │  EKS Node      │           │   │   │
│  │  │  └────────────────┘    └────────────────┘           │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  │                                                               │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │           Availability Zone us-east-2c               │   │   │
│  │  │  ┌────────────────┐    ┌────────────────┐           │   │   │
│  │  │  │ Public Subnet  │    │ Private Subnet │           │   │   │
│  │  │  │ 10.0.103.0/24  │    │ 10.0.3.0/24    │           │   │   │
│  │  │  │                │    │                │           │   │   │
│  │  │  │                │    │                │           │   │   │
│  │  │  └────────────────┘    └────────────────┘           │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  │                                                               │   │
│  │  ┌────────────────┐                                          │   │
│  │  │ Internet       │                                          │   │
│  │  │ Gateway        │                                          │   │
│  │  └────────────────┘                                          │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    EKS Control Plane                          │  │
│  │                  (Managed by AWS)                             │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    Route53 Hosted Zone                        │  │
│  │                  nouha-zouaghi.cc                             │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    IAM Roles & Policies                       │  │
│  │  • EKS Cluster Role                                           │  │
│  │  • Node Group Role                                            │  │
│  │  • OIDC Provider                                              │  │
│  │  • ExternalDNS Role (IRSA)                                    │  │
│  │  • AWS LB Controller Role (IRSA)                              │  │
│  └───────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────┘
```

## Network Architecture

### Traffic Flow

```
Internet User
     │
     ▼
Route53 DNS Resolution
(hello.nouha-zouaghi.cc → NLB DNS)
     │
     ▼
Network Load Balancer
(Public Subnets)
     │
     ▼
Ingress-Nginx Controller
(Pods in Private Subnets)
     │
     ├─── TLS Termination
     ├─── SSL Certificate Validation
     └─── Route to Backend Service
          │
          ▼
     Kubernetes Service
     (ClusterIP)
          │
          ▼
     Application Pods
     (hello-world)
```

### Subnet Design

| Subnet Type | CIDR | AZ | Purpose |
|-------------|------|----|---------| 
| Public | 10.0.101.0/24 | us-east-2a | NAT Gateway, NLB |
| Public | 10.0.102.0/24 | us-east-2b | NLB |
| Public | 10.0.103.0/24 | us-east-2c | NLB |
| Private | 10.0.1.0/24 | us-east-2a | EKS Nodes |
| Private | 10.0.2.0/24 | us-east-2b | EKS Nodes |
| Private | 10.0.3.0/24 | us-east-2c | EKS Nodes |

### Routing

**Public Subnets:**
- Default route: 0.0.0.0/0 → Internet Gateway
- Local route: 10.0.0.0/16 → Local

**Private Subnets:**
- Default route: 0.0.0.0/0 → NAT Gateway
- Local route: 10.0.0.0/16 → Local

## Security Architecture

### Defense in Depth

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Network Security                                   │
│ • VPC Isolation                                             │
│ • Private Subnets for Nodes                                 │
│ • Security Groups                                           │
│ • Network Policies                                          │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Identity & Access                                  │
│ • IAM Roles with Least Privilege                           │
│ • IRSA for Pod-Level Permissions                           │
│ • OIDC Provider for EKS                                     │
│ • No Long-Lived Credentials                                │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Encryption                                         │
│ • TLS for All External Traffic                             │
│ • Secrets Encrypted at Rest                                │
│ • EKS Envelope Encryption                                  │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Application Security                               │
│ • Resource Limits on Pods                                   │
│ • Read-Only Root Filesystems                               │
│ • Non-Root Containers                                       │
│ • RBAC for ArgoCD                                           │
└─────────────────────────────────────────────────────────────┘
```

### IAM Roles

**EKS Cluster Role:**
- Permissions: AmazonEKSClusterPolicy, AmazonEKSVPCResourceController
- Purpose: EKS control plane operations

**Node Group Role:**
- Permissions: AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly
- Purpose: Worker node operations, CNI, ECR access

**ExternalDNS Role (IRSA):**
- Permissions: Route53 read/write for hosted zone
- Purpose: Automated DNS record management
- Trust: EKS OIDC provider + external-dns service account

**AWS Load Balancer Controller Role (IRSA):**
- Permissions: ELB, EC2, WAF operations
- Purpose: Manage AWS load balancers from Kubernetes
- Trust: EKS OIDC provider + aws-load-balancer-controller service account

## Application Flow

### Deployment Flow (GitOps)

```
Developer
    │
    ▼
Git Repository
(Kubernetes Manifests)
    │
    ▼
ArgoCD
(Monitors Git Repo)
    │
    ├─── Detects Changes
    ├─── Validates Manifests
    └─── Applies to Cluster
         │
         ▼
    Kubernetes API
         │
         ├─── Creates Deployment
         ├─── Creates Service
         └─── Creates Ingress
              │
              ▼
         cert-manager
         (Provisions TLS Certificate)
              │
              ▼
         ExternalDNS
         (Creates Route53 Record)
              │
              ▼
         Application Live!
```

### Request Flow

```
1. User → https://hello.nouha-zouaghi.cc
2. DNS Resolution → Route53 → NLB DNS Name
3. NLB → Ingress-Nginx Pod (Port 443)
4. Ingress-Nginx:
   - Terminates TLS
   - Validates Certificate
   - Routes based on Host header
5. Kubernetes Service (ClusterIP)
6. Application Pod
7. Response ← Back through same path
```

## Component Details

### ArgoCD

**Purpose:** GitOps continuous delivery

**Components:**
- Application Controller: Monitors Git repos and syncs state
- Repo Server: Generates Kubernetes manifests
- Server: API and UI
- Redis: Caching
- Dex: SSO (disabled in this setup)

**Configuration:**
- Insecure mode (TLS at ingress)
- RBAC with readonly default
- Automated sync with prune
- Self-heal enabled

### Ingress-Nginx

**Purpose:** Kubernetes ingress controller

**Components:**
- Controller: Nginx process managing ingress rules
- Admission Webhook: Validates ingress resources
- Default Backend: 404 handler

**Configuration:**
- AWS NLB for external access
- HTTP (80) and HTTPS (443) listeners
- SSL passthrough disabled (TLS termination)
- Rate limiting enabled

### cert-manager

**Purpose:** Automated TLS certificate management

**Components:**
- Controller: Manages certificates
- Webhook: Validates certificate resources
- CA Injector: Injects CA bundles

**Configuration:**
- Let's Encrypt production issuer
- Let's Encrypt staging issuer (for testing)
- HTTP-01 challenge solver
- Automatic renewal (30 days before expiry)

### ExternalDNS

**Purpose:** Automated DNS record management

**Components:**
- Controller: Watches ingress/service resources
- Route53 Provider: Creates/updates DNS records

**Configuration:**
- Domain filter: nouha-zouaghi.cc
- TXT record ownership
- Sync policy: sync (creates and deletes)
- IRSA for Route53 access

## Data Flow

### Certificate Provisioning

```
1. Ingress Created
   └─ Annotation: cert-manager.io/cluster-issuer: letsencrypt-prod
   
2. cert-manager Detects Ingress
   └─ Creates Certificate Resource
   
3. Certificate Controller
   └─ Creates CertificateRequest
   
4. ACME Issuer
   ├─ Creates Order
   └─ Creates Challenge (HTTP-01)
   
5. Challenge Solver
   ├─ Creates Temporary Ingress
   └─ Serves Challenge Token
   
6. Let's Encrypt
   ├─ Validates Challenge
   └─ Issues Certificate
   
7. cert-manager
   └─ Stores Certificate in Secret
   
8. Ingress Controller
   └─ Uses Certificate for TLS
```

### DNS Record Creation

```
1. Ingress Created
   └─ Annotation: external-dns.alpha.kubernetes.io/hostname: hello.nouha-zouaghi.cc
   
2. ExternalDNS Detects Ingress
   └─ Extracts Hostname and Target (NLB DNS)
   
3. ExternalDNS Controller
   ├─ Checks Route53 for Existing Record
   └─ Creates/Updates A Record (Alias to NLB)
   
4. Route53
   └─ Record: hello.nouha-zouaghi.cc → NLB DNS
   
5. DNS Propagation
   └─ Global DNS servers updated (5-10 minutes)
```

## Disaster Recovery

### Backup Strategy

**Infrastructure:**
- Terraform state in S3 (when configured)
- Infrastructure can be recreated from code

**Kubernetes Resources:**
- Manifests in Git repository
- ArgoCD can redeploy from Git

**Persistent Data:**
- No persistent volumes in current setup
- Application data should be stored externally (RDS, S3, etc.)

### Recovery Procedures

**Complete Cluster Loss:**
1. Run `terraform apply` to recreate infrastructure
2. Configure kubectl
3. Redeploy platform components
4. ArgoCD will sync applications from Git

**Node Failure:**
- Auto Scaling Group automatically replaces failed nodes
- Kubernetes reschedules pods to healthy nodes

**AZ Failure:**
- Multi-AZ deployment ensures availability
- Traffic automatically routed to healthy AZs

### RTO/RPO

- **RTO (Recovery Time Objective):** ~30 minutes
  - Infrastructure: 15 minutes
  - Platform components: 10 minutes
  - Applications: 5 minutes

- **RPO (Recovery Point Objective):** 0 (no data loss)
  - All configuration in Git
  - No persistent state in cluster

## Monitoring & Observability

### Current State

**Logs:**
- EKS Control Plane logs → CloudWatch
- Application logs → stdout (viewable via kubectl)

**Metrics:**
- Kubernetes metrics-server (not installed)
- CloudWatch Container Insights (not enabled)

### Future Enhancements

**Recommended Additions:**
- Prometheus for metrics collection
- Grafana for visualization
- Loki for log aggregation
- Alertmanager for alerting
- Jaeger for distributed tracing

## Scalability

### Current Capacity

- **Nodes:** 1-4 (auto-scaling)
- **Pods per Node:** ~17 (t3.medium)
- **Total Pod Capacity:** 17-68 pods

### Scaling Strategies

**Horizontal Pod Autoscaling (HPA):**
- Scale pods based on CPU/memory
- Requires metrics-server

**Cluster Autoscaler:**
- Automatically adds/removes nodes
- Based on pending pods

**Vertical Pod Autoscaling (VPA):**
- Adjusts pod resource requests
- Based on actual usage

## Cost Optimization

### Current Costs

- **Fixed:** $73/month (EKS control plane)
- **Variable:** $60-240/month (nodes, 1-4 instances)
- **Networking:** $48/month (NAT + NLB)
- **Total:** $181-361/month

### Optimization Strategies

1. **Spot Instances:** 70% cost savings on nodes
2. **Cluster Autoscaler:** Scale down during low usage
3. **Right-Sizing:** Monitor and adjust instance types
4. **Reserved Instances:** 40% savings for predictable workloads
5. **Fargate:** Serverless option for specific workloads

## Technology Decisions

### Why EKS?

- Managed control plane (reduced operational overhead)
- AWS integration (IAM, VPC, ELB)
- Automatic updates and patches
- Enterprise support

### Why Terraform?

- Declarative infrastructure
- State management
- Modular design
- Wide AWS provider support

### Why ArgoCD?

- GitOps native
- Kubernetes-native
- Excellent UI
- Active community

### Why Ingress-Nginx?

- Most popular ingress controller
- Feature-rich
- Well-documented
- AWS NLB integration

### Why cert-manager?

- Automated certificate lifecycle
- Let's Encrypt integration
- Kubernetes-native
- Widely adopted

### Why ExternalDNS?

- Automated DNS management
- Route53 integration
- Reduces manual operations
- Kubernetes-native

## Future Enhancements

### Short Term
- [ ] Monitoring stack (Prometheus + Grafana)
- [ ] Cluster Autoscaler
- [ ] Horizontal Pod Autoscaler
- [ ] AWS Load Balancer Controller

### Medium Term
- [ ] Service Mesh (Istio/Linkerd)
- [ ] Policy Engine (OPA/Kyverno)
- [ ] Secrets Management (External Secrets Operator)
- [ ] Multi-environment setup (staging, prod)

### Long Term
- [ ] Multi-cluster setup
- [ ] Disaster recovery automation
- [ ] Cost optimization automation
- [ ] Advanced security scanning

---

**Document Version:** 1.0  
**Last Updated:** November 2025  
**Author:** Nouha Zouaghi
