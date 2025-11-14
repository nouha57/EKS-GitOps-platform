# Quick Reference Guide

## 🔗 URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| ArgoCD | https://argocd.nouha-zouaghi.cc | admin / (see below) |
| Hello World | https://hello.nouha-zouaghi.cc | N/A |

**Get ArgoCD Password:**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## 📦 Common Commands

### Terraform

```bash
# Initialize
cd terraform
terraform init

# Plan
terraform plan -var-file=environments/dev/terraform.tfvars

# Apply
terraform apply -var-file=environments/dev/terraform.tfvars

# Destroy
terraform destroy -var-file=environments/dev/terraform.tfvars

# Outputs
terraform output
terraform output -raw external_dns_role_arn
terraform output route53_name_servers
```

### Kubernetes

```bash
# Configure kubectl
aws eks update-kubeconfig --region us-east-2 --name eks-gitops-platform-dev

# Get nodes
kubectl get nodes

# Get all pods
kubectl get pods -A

# Get pods in namespace
kubectl get pods -n argocd
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get pods -n external-dns
kubectl get pods -n applications

# Get services
kubectl get svc -A

# Get ingresses
kubectl get ingress -A

# Get certificates
kubectl get certificate -A

# Describe resource
kubectl describe pod <pod-name> -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>
kubectl describe certificate <cert-name> -n <namespace>

# Logs
kubectl logs <pod-name> -n <namespace>
kubectl logs -f <pod-name> -n <namespace>  # Follow
kubectl logs deployment/<deployment-name> -n <namespace>

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

### ArgoCD

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Restart ArgoCD server
kubectl rollout restart deployment argocd-server -n argocd

# Get applications
kubectl get applications -n argocd

# Sync application
kubectl patch application <app-name> -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

### cert-manager

```bash
# Get certificates
kubectl get certificate -A

# Get certificate requests
kubectl get certificaterequest -A

# Get challenges
kubectl get challenge -A

# Describe certificate
kubectl describe certificate <cert-name> -n <namespace>

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager -f

# Get ClusterIssuers
kubectl get clusterissuer
```

### ExternalDNS

```bash
# Check ExternalDNS logs
kubectl logs -n external-dns deployment/external-dns -f

# Check Route53 records
aws route53 list-resource-record-sets --hosted-zone-id $(terraform output -raw route53_zone_id)

# Test DNS resolution
nslookup hello.nouha-zouaghi.cc
nslookup argocd.nouha-zouaghi.cc
```

### Ingress-Nginx

```bash
# Get ingress controller
kubectl get pods -n ingress-nginx

# Get load balancer
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Check logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f

# Get ingresses
kubectl get ingress -A
```

## 🔍 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n <namespace>

# Describe pod
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

### Certificate Issues

```bash
# Check certificate status
kubectl get certificate -n <namespace>
kubectl describe certificate <cert-name> -n <namespace>

# Check certificate request
kubectl get certificaterequest -n <namespace>
kubectl describe certificaterequest <request-name> -n <namespace>

# Check challenges
kubectl get challenge -A
kubectl describe challenge <challenge-name> -n <namespace>

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager -f
```

### DNS Issues

```bash
# Check ExternalDNS logs
kubectl logs -n external-dns deployment/external-dns -f

# Check Route53 records
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>

# Test DNS
nslookup <hostname>
dig <hostname>

# Check ingress annotations
kubectl get ingress <ingress-name> -n <namespace> -o yaml
```

### Ingress Issues

```bash
# Check ingress
kubectl get ingress -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>

# Check ingress controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f

# Check load balancer
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Test connectivity
curl -v http://<nlb-dns-name>
curl -v https://<hostname>
```

### Node Issues

```bash
# Check nodes
kubectl get nodes
kubectl describe node <node-name>

# Check node conditions
kubectl get nodes -o wide

# Check node logs (via AWS Console or SSM)
aws ec2 get-console-output --instance-id <instance-id>
```

## 📊 Monitoring

### Check All Components

```bash
# Quick health check
kubectl get nodes
kubectl get pods -A | grep -v Running
kubectl get ingress -A
kubectl get certificate -A | grep -v True
```

### Resource Usage

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -A

# Describe node
kubectl describe node <node-name>
```

## 🧹 Cleanup

### Delete Application

```bash
kubectl delete -f kubernetes/applications/hello-world/
```

### Delete Platform Components

```bash
kubectl delete namespace argocd ingress-nginx cert-manager external-dns applications
```

### Destroy Infrastructure

```bash
# IMPORTANT: Delete Kubernetes resources first!
kubectl get svc -A  # Ensure no LoadBalancers remain

cd terraform
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## 🔐 Security

### Get Secrets

```bash
# ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# TLS certificates
kubectl get secret <cert-secret-name> -n <namespace> -o yaml
```

### Check IAM Roles

```bash
# List IAM roles
aws iam list-roles | grep eks-gitops-platform

# Get role details
aws iam get-role --role-name <role-name>

# List attached policies
aws iam list-attached-role-policies --role-name <role-name>
```

## 📈 Scaling

### Scale Deployment

```bash
# Scale manually
kubectl scale deployment <deployment-name> -n <namespace> --replicas=3

# Check scaling
kubectl get deployment <deployment-name> -n <namespace>
```

### Scale Nodes

```bash
# Update node group (via AWS Console or CLI)
aws eks update-nodegroup-config \
  --cluster-name eks-gitops-platform-dev \
  --nodegroup-name eks-gitops-platform-dev-node-group \
  --scaling-config minSize=2,maxSize=6,desiredSize=3
```

## 🔄 Updates

### Update Application

```bash
# Edit deployment
kubectl edit deployment <deployment-name> -n <namespace>

# Or apply updated manifest
kubectl apply -f kubernetes/applications/hello-world/
```

### Update Platform Component

```bash
# Restart deployment
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Check rollout status
kubectl rollout status deployment <deployment-name> -n <namespace>
```

## 📝 Useful Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Kubectl aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgi='kubectl get ingress'
alias kgc='kubectl get certificate'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# Namespace aliases
alias kn='kubectl config set-context --current --namespace'

# ArgoCD
alias argopass='kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo'

# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfo='terraform output'
```

## 🆘 Emergency Procedures

### Cluster Not Accessible

```bash
# Reconfigure kubectl
aws eks update-kubeconfig --region us-east-2 --name eks-gitops-platform-dev

# Check AWS credentials
aws sts get-caller-identity

# Check cluster status
aws eks describe-cluster --name eks-gitops-platform-dev --region us-east-2
```

### All Pods Failing

```bash
# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20
```

### Cost Runaway

```bash
# Check running resources
kubectl get pods -A
kubectl get svc -A | grep LoadBalancer

# Scale down
kubectl scale deployment --all --replicas=0 -n applications

# Or destroy everything
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## 📞 Support Resources

- **AWS EKS Docs:** https://docs.aws.amazon.com/eks/
- **Kubernetes Docs:** https://kubernetes.io/docs/
- **ArgoCD Docs:** https://argo-cd.readthedocs.io/
- **cert-manager Docs:** https://cert-manager.io/docs/
- **Terraform AWS Provider:** https://registry.terraform.io/providers/hashicorp/aws/

---

**Keep this document handy for quick reference!**
