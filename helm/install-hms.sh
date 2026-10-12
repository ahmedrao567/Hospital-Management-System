#!/usr/bin/env bash
set -euo pipefail

# Simple installer for Rancher Desktop / local cluster
# Usage: ./helm/install-hms.sh

NAMESPACE=${NAMESPACE:-hms}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-Tarun@12}
HELM_TIMEOUT=${HELM_TIMEOUT:-3m}

echo "Checking tools..."
command -v helm >/dev/null 2>&1 || { echo "helm not found"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found"; exit 1; }

echo "Creating namespace $NAMESPACE (if missing)"
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

echo "Adding bitnami repo for MySQL (if missing)"
helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null 2>&1 || true
helm repo update >/dev/null

echo "Installing MySQL..."
helm upgrade --install hms-mysql bitnami/mysql \
  --namespace "$NAMESPACE" \
  --set auth.rootPassword="$MYSQL_ROOT_PASSWORD" \
  --set primary.persistence.enabled=false \
  --wait --timeout 5m

install_chart(){
  local name="$1"
  local path="$2"
  local timeout="${3:-$HELM_TIMEOUT}"

  echo "Installing $name from $path"
  helm upgrade --install "$name" "$path" \
    --namespace "$NAMESPACE" \
    --wait --timeout "$timeout"

  echo "Waiting for rollout $name"
  kubectl rollout status deployment/"$name" -n "$NAMESPACE" --timeout="$timeout" || true
}

echo "Installing Eureka Server"
install_chart hms-eureka-server ./helm/eureka-server 3m

echo "Installing backend services"
install_chart hms-userms ./helm/userms 3m
install_chart hms-profilems ./helm/profilems 3m
install_chart hms-appointment ./helm/appointment 3m
install_chart hms-pharmacy ./helm/pharmacy 3m
install_chart hms-media ./helm/media 3m

echo "Installing Gateway"
install_chart hms-gateway ./helm/gateway 3m

echo "Installing Frontend"
install_chart hms-frontend ./helm/frontend 3m

echo "All charts requested. Use 'kubectl -n $NAMESPACE get all' to inspect resources." 

echo "To override image tags, run e.g.:
# NAMESPACE=hms helm upgrade --install hms-userms ./helm/userms --set image.tag=your-tag -n hms --wait"

exit 0
