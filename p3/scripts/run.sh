#!/bin/bash
set -e

CLUSTER_NAME="default"
CLUSTER_PORT=443
APP_NAME="wil-playground"
APP_PORT=8888:30013
APP_DEST_NAMESPACE="dev"
APP_DEST_SERVER="https://kubernetes.default.svc"
NAMESPACE_ARGOCD="argocd"
APP_PATH="development"
APP_REPO="https://github.com/FrenchDandelions/IoT-argocd"

k3d cluster create $CLUSTER_NAME -p $CLUSTER_PORT:$CLUSTER_PORT -p $APP_PORT 

kubectl get ns $NAMESPACE_ARGOCD || kubectl create namespace $NAMESPACE_ARGOCD

kubectl config set-context --current --namespace=$NAMESPACE_ARGOCD

kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=available deployment/argocd-server -n $NAMESPACE_ARGOCD --timeout=90s

kubectl patch deployment argocd-server -n $NAMESPACE_ARGOCD --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--insecure"}]'

kubectl wait --for=condition=available --timeout=300s deployment argocd-server

kubectl apply -f confs

kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/part-of=argocd

argocd login --core

kubectl get ns $APP_DEST_NAMESPACE || kubectl create namespace $APP_DEST_NAMESPACE && echo "${GREEN} * Creating $APP_DEST_NAMESPACE namespace${RESET}"

argocd app create "$APP_NAME" --repo "$APP_REPO" --path "$APP_PATH" --dest-server "$APP_DEST_SERVER" --sync-policy automated --dest-namespace "$APP_DEST_NAMESPACE"

# Retrieve and display Argo CD admin password
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
echo "Argo CD admin password: $ARGOCD_PASSWORD"

# Port-forward Argo CD server so you can access the UI on localhost:8080
kubectl -n $NAMESPACE_ARGOCD port-forward svc/argocd-server 8080:80
