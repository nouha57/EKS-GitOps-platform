# Screenshots Directory

Place your platform screenshots here.

## Required Screenshots

1. **argocd-dashboard.png** - ArgoCD UI showing applications
2. **hello-world-app.png** - Hello World app in browser with URL and SSL
3. **eks-cluster.png** - AWS Console showing EKS cluster
4. **ssl-certificate.png** - Browser showing valid Let's Encrypt certificate
5. **kubectl-resources.png** - Terminal showing `kubectl get all -A`
6. **terraform-output.png** - Terminal showing `terraform output`

## How to Take Screenshots

### ArgoCD Dashboard
1. Visit https://argocd.nouha-zouaghi.cc
2. Log in with admin credentials
3. Take screenshot of main dashboard

### Hello World App
1. Visit https://hello.nouha-zouaghi.cc
2. Ensure URL bar and lock icon are visible
3. Take full-page screenshot

### EKS Cluster
1. AWS Console → EKS → Clusters
2. Click on eks-gitops-platform-dev
3. Screenshot showing cluster details

### SSL Certificate
1. Visit https://hello.nouha-zouaghi.cc
2. Click lock icon → Certificate
3. Screenshot showing Let's Encrypt details

### Terminal Screenshots
```bash
# Kubernetes resources
kubectl get all -A

# Terraform outputs
cd terraform
terraform output
```

## Screenshot Tips

- Use high resolution (at least 1920x1080)
- Ensure text is readable
- Include relevant context (URLs, status indicators)
- Crop out sensitive information if any
- Use PNG format for better quality

## After Adding Screenshots

Update the README.md to reference your actual screenshots instead of placeholders.
