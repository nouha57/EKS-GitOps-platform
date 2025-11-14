# cert-manager

This directory contains the configuration for cert-manager, which automatically provisions and manages TLS certificates.

## Installation

cert-manager has been installed using the official manifest:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
```

## ClusterIssuers

Two ClusterIssuers have been configured:

### 1. Let's Encrypt Staging (for testing)
```bash
kubectl apply -f cluster-issuer-staging.yaml
```

Use this for testing to avoid hitting rate limits.

### 2. Let's Encrypt Production
```bash
kubectl apply -f cluster-issuer-prod.yaml
```

Use this for production certificates.

## Usage

Add these annotations to your Ingress to get automatic TLS certificates:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod  # or letsencrypt-staging
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.nouha-zouaghi.cc
    secretName: myapp-tls  # cert-manager will create this secret
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

## Verify Installation

Check cert-manager pods:
```bash
kubectl get pods -n cert-manager
```

Check ClusterIssuers:
```bash
kubectl get clusterissuer
```

Check certificates:
```bash
kubectl get certificate -A
```

Check certificate requests:
```bash
kubectl get certificaterequest -A
```

## Troubleshooting

**Check certificate status:**
```bash
kubectl describe certificate <cert-name> -n <namespace>
```

**Check certificate request:**
```bash
kubectl describe certificaterequest <request-name> -n <namespace>
```

**Check ACME challenge:**
```bash
kubectl get challenge -A
kubectl describe challenge <challenge-name> -n <namespace>
```

**Check cert-manager logs:**
```bash
kubectl logs -n cert-manager deployment/cert-manager -f
```

**Common issues:**

1. **HTTP-01 challenge failing**: Ensure ingress-nginx is working and the domain resolves to the load balancer
2. **Rate limits**: Use staging issuer for testing
3. **DNS not resolving**: Wait for DNS propagation (can take up to 48 hours, usually 5-10 minutes)

## Rate Limits

Let's Encrypt has rate limits:
- **Staging**: Very high limits, use for testing
- **Production**: 50 certificates per registered domain per week

Always test with staging first!
