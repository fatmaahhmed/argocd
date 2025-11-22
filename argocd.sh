#!/bin/bash

# Create argocd namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Expose ArgoCD server (choose one method):

# Option 1: Port Forward (for local access)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Option 2: LoadBalancer (for cloud environments)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Option 3: NodePort (for on-premise)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Apply your ArgoCD application
kubectl apply -f /Users/fatmaahmed/Desktop/devops/argocd/argoApplication/app-argocd.yaml

# Login to ArgoCD CLI (optional)
argocd login localhost:8080 --username admin --password <password-from-above> --insecure