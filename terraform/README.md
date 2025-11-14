# EKS GitOps Platform - Terraform Infrastructure

This directory contains the Terraform configuration for provisioning the EKS GitOps platform infrastructure on AWS.

## Architecture

The infrastructure is composed of the following modules:

- **VPC Module**: Creates VPC with public and private subnets across 3 availability zones
- **IAM Module**: Creates IAM roles and policies for EKS cluster, node groups, and IRSA (IAM Roles for Service Accounts)
- **EKS Module**: Provisions EKS cluster with managed node groups and essential addons
- **Route53 Module**: Creates a hosted zone for DNS management

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.6
- A registered domain name (for Route53 hosted zone)

## Quick Start

### 1. Configure Variables

Edit `environments/dev/terraform.tfvars` and update the following:

```hcl
domain_name = "your-domain.com"  # Replace with your actual domain
```

You can also customize other variables like:
- `cluster_name`: Name of the EKS cluster
- `region`: AWS region for deployment
- `node_group_desired_size`: Number of worker nodes

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
```

### 4. Apply the Configuration

```bash
terraform apply -var-file=environments/dev/terraform.tfvars
```

This will create approximately 42 resources including:
- VPC with 6 subnets (3 public, 3 private)
- NAT Gateway and Internet Gateway
- EKS cluster with managed node group
- IAM roles and policies
- Route53 hosted zone
- CloudWatch log group for cluster logs

### 5. Configure kubectl

After the apply completes, configure kubectl to access your cluster:

```bash
aws eks update-kubeconfig --region us-east-2 --name eks-gitops-platform-dev
```

Or use the output command:

```bash
terraform output -raw configure_kubectl | bash
```

### 6. Configure DNS Delegation

After creation, you need to delegate your domain to the Route53 name servers:

```bash
terraform output route53_name_servers
```

Add these name servers to your domain registrar's DNS configuration.

## Important Outputs

After applying, Terraform will output several important values:

- `cluster_endpoint`: EKS cluster API endpoint
- `cluster_name`: Name of the EKS cluster
- `oidc_provider_arn`: ARN of the OIDC provider for IRSA
- `external_dns_role_arn`: IAM role ARN for ExternalDNS service account
- `route53_zone_id`: Route53 hosted zone ID
- `route53_name_servers`: Name servers for DNS delegation
- `configure_kubectl`: Command to configure kubectl

View all outputs:

```bash
terraform output
```

## Module Dependencies

The modules have the following dependency order:

1. **VPC** - Created first (no dependencies)
2. **IAM** - Creates cluster and node roles (no dependencies on EKS)
3. **EKS** - Uses IAM roles and VPC subnets
4. **IAM OIDC Provider** - Created after EKS using cluster OIDC issuer URL
5. **Route53** - Independent, can be created in parallel

Note: There is a managed circular dependency between IAM and EKS modules. Terraform handles this correctly because:
- IAM cluster/node roles don't depend on EKS
- EKS cluster uses those roles
- IAM OIDC provider uses EKS cluster's OIDC issuer URL

## Cost Estimate

Approximate monthly costs (us-east-2 region):

- EKS Control Plane: $73/month
- EC2 Instances (2x t3.medium): ~$60/month
- NAT Gateway: ~$32/month
- Network Load Balancer: ~$16/month (created by ingress controller)
- Route53 Hosted Zone: $0.50/month
- Data Transfer: ~$10/month

**Total: ~$191/month**

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file=environments/dev/terraform.tfvars
```

**Important**: Make sure to delete any Kubernetes resources (LoadBalancers, PersistentVolumes) before destroying the infrastructure, as they may prevent VPC deletion.

## Backend Configuration

For production use, configure S3 backend for remote state storage. Uncomment and configure the backend block in `main.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "eks-gitops-platform/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

## Troubleshooting

### Quota Limits

If you encounter quota limit errors, check your AWS service quotas:

```bash
aws service-quotas list-service-quotas --service-code eks
aws service-quotas list-service-quotas --service-code ec2
```

### VPC Deletion Issues

If VPC deletion fails, check for:
- Remaining ENIs (Elastic Network Interfaces)
- LoadBalancers created by Kubernetes
- Security groups created by Kubernetes

### OIDC Provider Issues

If IRSA roles aren't working, verify:
- OIDC provider is created correctly
- Service account annotations match the IAM role ARN
- Trust relationship in IAM role includes correct OIDC provider

## Next Steps

After infrastructure is provisioned:

1. Install ArgoCD (see `kubernetes/platform/argocd/`)
2. Deploy platform components (ingress-nginx, cert-manager, external-dns)
3. Deploy sample applications
4. Configure monitoring and logging

See the main project README for complete setup instructions.
