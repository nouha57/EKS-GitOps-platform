# Ingress Nginx Controller

This directory contains the configuration for the Nginx Ingress Controller.

## Installation

Ingress-nginx has been installed using the official AWS manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml
```

## Configuration

The ingress controller is configured with:
- AWS Network Load Balancer (NLB) for external access
- HTTP (port 80) and HTTPS (port 443) listeners
- Automatic SSL redirect (configured per ingress)
- Rate limiting capabilities

## Load Balancer

Get the load balancer URL:
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

Current Load Balancer: `a5fc5b32702de460a9bffa7a4245b111-8bb3985cc11f6f96.elb.us-east-2.amazonaws.com`

## Verify Installation

Check ingress controller pods:
```bash
kubectl get pods -n ingress-nginx
```

Check ingress controller logs:
```bash
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f
```

## Usage

Create an Ingress resource to expose your application:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  namespace: applications
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    external-dns.alpha.kubernetes.io/hostname: myapp.nouha-zouaghi.cc
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.nouha-zouaghi.cc
    secretName: myapp-tls
  rules:
  - host: myapp.nouha-zouaghi.cc
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
```

## Troubleshooting

**Check ingress resources:**
```bash
kubectl get ingress -A
```

**Describe an ingress:**
```bash
kubectl describe ingress <ingress-name> -n <namespace>
```

**Check NLB status:**
```bash
aws elbv2 describe-load-balancers --region us-east-2 | grep DNSName
```
