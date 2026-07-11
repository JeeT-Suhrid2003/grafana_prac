# cat << 'EOF' > setup-loki.sh
#!/bin/bash

echo "========================================="
echo "💥 STEP 1: Cleaning up old installations..."
echo "========================================="
kuebctl create deployment observer --image jeet23/observer
kubectl apply -f https://raw.githubusercontent.com/JeeT-Suhrid2003/grafana_prac/refs/heads/main/service.yml
sleep 3
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update   

# Wait for namespace deletion to finalize
echo "Waiting for old namespace to clear..."
sleep 5

echo "========================================="
echo "🏗️ STEP 2: Creating Namespace & Deploying Loki Stack..."
echo "========================================="
kubectl create namespace monitoring

helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set loki.auth_enabled=false \
  --set grafana.enabled=true

echo "Waiting 15 seconds for pods to initialize..."
sleep 15

echo "========================================="
echo "⚙️ STEP 3: Patching Grafana Service to NodePort..."
echo "========================================="
kubectl patch svc loki-grafana -n monitoring -p '{"spec": {"type": "NodePort"}}'

echo "========================================="
echo "🔑 STEP 4: Retrieval and Status Report"
echo "========================================="
echo ""
sleep 5
echo "--- POD STATUS ---"
kubectl get pods -n monitoring

echo ""
echo "--- GRAFANA ACCESS DETAILS ---"
NODEPORT=$(kubectl get svc loki-grafana -n monitoring -o jsonpath='{.spec.ports[0].nodePort}')
PASSWORD=$(kubectl get secret --namespace monitoring loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

echo "👉 Killercoda NodePort to open: $NODEPORT"
echo "👉 Username: admin"
echo "👉 Password: $PASSWORD"
echo "========================================="
# EOF

# # Make it executable and run it
# chmod +x setup-loki.sh
# ./setup-loki.sh
