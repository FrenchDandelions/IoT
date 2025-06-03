#!/bin/bash
set -e

CLUSTER_NAME="default"
CLUSTER_PORT=443
APP_PORT="8888:30013@loadbalancer"
NAMESPACE_ARGOCD="argocd"

sudo k3d cluster create $CLUSTER_NAME -p $CLUSTER_PORT:$CLUSTER_PORT -p $APP_PORT 

sudo kubectl get ns $NAMESPACE_ARGOCD || kubectl create namespace $NAMESPACE_ARGOCD
sudo kubectl apply -n $NAMESPACE_ARGOCD -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo kubectl apply -n $NAMESPACE_ARGOCD -k patchs
sudo kubectl apply -n $NAMESPACE_ARGOCD -f confs

sudo kubectl config set-context --current --namespace=$NAMESPACE_ARGOCD

sudo kubectl wait --for=condition=available --timeout=300s deployment -n $NAMESPACE_ARGOCD argocd-server

# Retrieve and display Argo CD admin password
ARGOCD_PASSWORD=$(sudo kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
echo "Argo CD admin password: $ARGOCD_PASSWORD"

# Port-forward Argo CD server so you can access the UI on localhost:8080
sudo kubectl -n $NAMESPACE_ARGOCD port-forward svc/argocd-server 8080:80
