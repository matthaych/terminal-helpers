alias k="kubectl"
alias kns="kubectl config set-context --current --namespace"
alias pods="kubectl get pods"
alias pod="kubectl describe pod"
alias klogs="kubectl logs -f"

function container_creating() {
    POD=$(kubectl get pods | grep "$SERVICE")
    while [ -z "$POD" ]; do
        echo "$SERVICE has not yet been created"
        sleep 1
        POD=$(kubectl get pods | grep "$SERVICE")
    done

    STATE=$(echo "$POD" | awk '{print $3}')
    if [ "$STATE" == "ContainerCreating" ] || [[ "$STATE" == "Init:"* ]] || [[ "$STATE" == "Pending" ]]; then
        echo "$SERVICE is $STATE"
        return 0
    else
        echo "READY: $SERVICE is $STATE"
        return 1
    fi
}

function kwait() {
    SERVICE=$1
    echo "Waiting for $SERVICE to be ready..."
    while container_creating "$SERVICE"; do
        sleep 5
    done
    POD=$(kubectl get pods | grep "$SERVICE")
    POD_ID=$(echo "$POD" | awk '{print $1}')

    kubectl logs -f "$POD_ID"
}

function kssh() {
  SERVICE=$1
  POD=$(kubectl get pods | grep "$SERVICE")
  POD_ID=$(echo "$POD" | awk '{print $1}')
  kubectl exec -it "$POD_ID" -- /bin/bash
}

function ksecret() {
  SECRET=$1
  kubectl get secret "$SECRET" -o json | jq '.data | map_values(@base64d)'
}