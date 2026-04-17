#!/bin/bash

# Apply Kubernetes manifests for ToggleMaster

echo "Applying namespaces..."
kubectl apply -f k8s/namespaces.yml

echo "Applying secrets..."
kubectl apply -f k8s/secrets.yml

echo "Applying configmaps..."
kubectl apply -f k8s/configmaps.yml

echo "Applying services..."
kubectl apply -f k8s/auth-service.yml
kubectl apply -f k8s/flag-service.yml
kubectl apply -f k8s/targeting-service.yml
kubectl apply -f k8s/evaluation-service.yml
kubectl apply -f k8s/analytics-service.yml

echo "Applying ingress..."
kubectl apply -f k8s/ingress.yml

echo "Applying HPA..."
kubectl apply -f k8s/hpa.yml

echo "All manifests applied!"