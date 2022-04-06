## Steps to setup kubernetes infrastructure

### 1. Install ArgoCD via helm
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace 
```

### 2. Get ArgoCD credentials
```bash
Username: admin
Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" -n argocd | base64 -d
```


### 3. Deploy the ArgoCD applications
```bash
kubectl apply -f k8s-infra/argo-apps/
```

### 4. Setup ArgoCD Ingress

> Required: Ingress controller and cert-manager with letsencrypt.

* Argocd Ingress
```yaml
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    # If you encounter a redirect loop or are getting a 307 response code 
    # then you need to force the nginx ingress to connect to the backend using HTTPS.
    #
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  rules:
  - host: argocd.litmuschaos.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: argocd-server
            port:
              name: https
  tls:
  - hosts:
    - argocd.litmuschaos.io
    secretName: argocd-secret # do not change, this is provided by Argo CD
```

* docs ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/rewrite-target: /$1
  name: litmus-docs-ingress
  namespace: litmus-docs
spec:
  rules:
  - host: docs.litmuschaos.io
    http:
      paths:
      - path: /(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: litmusdoc-service
            port:
              number: 80
  ingressClassName: nginx
  tls:
    - hosts:
        - docs.litmuschaos.io
      secretName: litmus-docs-tls
```

* v1 docs ingress 

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/rewrite-target: /$1
  name: v1-litmus-docs-ingress
  namespace: v1-litmus-docs
spec:
  rules:
  - host: v1-docs.litmuschaos.io
    http:
      paths:
      - path: /(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: v1-litmusdoc-service
            port:
              number: 80
  ingressClassName: nginx
  tls:
    - hosts:
        - v1-docs.litmuschaos.io
      secretName: v1-litmus-docs-tls
```

* prod hub

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/rewrite-target: /$1
  name: prod-hub-ingress
  namespace: prod-hub-litmuschaos
spec:
  rules:
  - host: hub.litmuschaos.io
    http:
      paths:
      - path: /api/(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: prod-chart-litmuschaos-server-service
            port:
              number: 8080
      - path: /(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: prod-chart-litmuschaos-client-service
            port:
              number: 80
  - host: www.hub.litmuschaos.io
    http:
      paths:
      - path: /api/(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: prod-chart-litmuschaos-server-service
            port:
              number: 8080
      - path: /(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: prod-chart-litmuschaos-client-service
            port:
              number: 80
  ingressClassName: nginx
  tls:
  - hosts:
    - hub.litmuschaos.io
    - www.hub.litmuschaos.io
    secretName: prod-hub-litmus-tls
```

* staging hub

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/rewrite-target: /$1
  name: staging-hub-ingress
  namespace: staging-hub-litmuschaos
spec:
  rules:
  - host: staging-hub.litmuschaos.io
    http:
      paths:
      - path: /api/(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: staging-chart-litmuschaos-server-service
            port:
              number: 8080
      - path: /(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: staging-chart-litmuschaos-client-service
            port:
              number: 80
  ingressClassName: nginx
  tls:
  - hosts:
    - staging-hub.litmuschaos.io
    secretName: staging-hub-litmus-tls
```

  