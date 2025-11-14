# ArgoCD Installation

This directory contains the ArgoCD installation configuration for the EKS GitOps platform.

## Installation

ArgoCD has been installed using the official manifests:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Accessing ArgoCD

### Option 1: Port Forward (Immediate Access)

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then access ArgoCD at: https://localhost:8080

### Option 2: Via Ingress (After ingress-nginx and cert-manager are deployed)

ArgoCD will be accessible at: https://argocd.nouha-zouaghi.cc

## Login Credentials

**Username:** `admin`

**Password:** Get the initial password with:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Initial password: `V1dLtQEh9waDXEoG`

**Important:** Change the admin password after first login:
```bash
argocd account update-password
```

Or via UI: User Info → Update Password

## Configuration

ArgoCD is configured with:
- Insecure mode enabled (TLS termination at ingress)
- RBAC with readonly default policy
- Metrics enabled
- ApplicationSet controller enabled
- Notifications controller enabled

## Next Steps

1. Access ArgoCD UI using port-forward
2. Deploy platform components (ingress-nginx, cert-manager, external-dns) using ArgoCD
3. Create ArgoCD ingress for external access
4. Deploy sample applications

## Useful Commands

**Check ArgoCD pods:**
```bash
kubectl get pods -n argocd
```

**View ArgoCD server logs:**
```bash
kubectl logs -n argocd deployment/argocd-server -f
```

**List ArgoCD applications:**
```bash
kubectl get applications -n argocd
```

**Sync an application:**
```bash
kubectl patch application <app-name> -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

## Troubleshooting

**Pods not starting:**
```bash
kubectl describe pod -n argocd <pod-name>
```

**Check ArgoCD application status:**
```bash
kubectl describe application -n argocd <app-name>
```

**Reset admin password:**
```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
kubectl -n argocd rollout restart deployment argocd-server
```
