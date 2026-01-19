# How to Update Deployment Status

## When Infrastructure is LIVE

Edit `README.md` and replace the Live Demo section with:

```markdown
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
```

## When Infrastructure is DESTROYED

Edit `README.md` and replace the Live Demo section with:

```markdown
## 🌐 Live Demo

> **Status: Temporarily Offline** 💤
> 
> The platform was live at:
> - **ArgoCD UI:** https://argocd.nouha-zouaghi.cc
> - **Demo Application:** https://hello.nouha-zouaghi.cc
>
> Infrastructure has been temporarily destroyed to manage costs (~$191/month).
> The platform can be redeployed in ~15 minutes using the provided Terraform code.
> Screenshots below show the working deployment.
```

## Before Destroying Infrastructure

### 1. Take Screenshots

Capture these screenshots and save them to `docs/screenshots/`:

**ArgoCD Dashboard** (`argocd-dashboard.png`):
- Visit https://argocd.nouha-zouaghi.cc
- Log in
- Take screenshot of the main dashboard showing applications

**Hello World App** (`hello-world-app.png`):
- Visit https://hello.nouha-zouaghi.cc
- Make sure the URL and green lock icon are visible
- Take full-page screenshot

**EKS Cluster** (`eks-cluster.png`):
- Go to AWS Console → EKS
- Click on your cluster
- Take screenshot showing cluster status and details

**SSL Certificate** (`ssl-certificate.png`):
- Visit https://hello.nouha-zouaghi.cc
- Click the lock icon in browser
- Click "Certificate is valid"
- Take screenshot showing Let's Encrypt certificate details

**Kubernetes Resources** (`kubectl-resources.png`):
- Run: `kubectl get all -A`
- Take screenshot of terminal output

**Terraform Output** (`terraform-output.png`):
- Run: `terraform output`
- Take screenshot showing all outputs

### 2. Update README

- Change status to "Temporarily Offline"
- Verify screenshot links work
- Commit changes

### 3. Destroy Infrastructure

```bash
cd terraform
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## To Redeploy for Interviews

### Quick Redeploy (15 minutes)

```bash
# 1. Apply Terraform
cd terraform
terraform apply -var-file=environments/dev/terraform.tfvars

# 2. Configure kubectl
aws eks update-kubeconfig --region us-east-2 --name eks-gitops-platform-dev

# 3. Deploy platform components
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
kubectl wait --namespace cert-manager --for=condition=ready pod --selector=app.kubernetes.io/instance=cert-manager --timeout=300s
kubectl apply -f kubernetes/platform/cert-manager/
kubectl apply -f kubernetes/platform/external-dns/

# 4. Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd
kubectl apply -f kubernetes/platform/argocd/ingress.yaml

# 5. Deploy application
kubectl apply -f kubernetes/applications/hello-world/

# 6. Update README status to "Currently Live"
```

### Verify Everything Works

```bash
# Check all pods
kubectl get pods -A

# Check certificates
kubectl get certificate -A

# Test URLs
curl -I https://argocd.nouha-zouaghi.cc
curl -I https://hello.nouha-zouaghi.cc
```

## Cost Management Tips

### Option 1: Keep It Live During Job Search
- Cost: ~$191/month
- Best for: Active interviewing (1-3 months)
- Benefit: Always ready to demo

### Option 2: Deploy On-Demand
- Cost: ~$6/day when running
- Best for: Specific interview demos
- Deploy 1 day before interview
- Destroy after interview

### Option 3: Use Spot Instances
- Cost: ~$60/month (70% savings on compute)
- Edit `terraform/modules/eks/main.tf`:
  ```hcl
  capacity_type = "SPOT"
  ```
- Risk: Nodes can be terminated (acceptable for demo)

## Git Workflow

### When Destroying

```bash
# Take screenshots first!
# Update README status
git add README.md docs/screenshots/
git commit -m "Update: Infrastructure temporarily offline"
git push
```

### When Redeploying

```bash
# After infrastructure is live
# Update README status
git add README.md
git commit -m "Update: Infrastructure is live"
git push
```


## Quick Status Check

```bash
# Check if infrastructure exists
aws eks describe-cluster --name eks-gitops-platform-dev --region us-east-2 2>/dev/null && echo "✅ LIVE" || echo "❌ OFFLINE"
```

---

