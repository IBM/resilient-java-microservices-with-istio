#!/bin/bash

# This script is intended to be run by Travis CI. If running elsewhere, invoke
# it with: TRAVIS_PULL_REQUEST=false [path to script]
# CLUSTER_NAME must be set prior to running (see environment variables in the
# Travis CI documentation).

# shellcheck disable=SC1090
source "$(dirname "$0")"/../scripts/resources.sh

kubeclt_clean() {
    echo "Cleaning cluster"
    kubectl delete --ignore-not-found=true -f manifests/deploy-schedule.yaml
    kubectl delete --ignore-not-found=true -f manifests/deploy-session.yaml
    kubectl delete --ignore-not-found=true -f manifests/deploy-speaker.yaml
    kubectl delete --ignore-not-found=true -f manifests/deploy-vote.yaml
    kubectl delete --ignore-not-found=true -f manifests/deploy-webapp.yaml
    kubectl delete --ignore-not-found=true -f manifests/deploy-cloudant.yaml
    kubectl delete --ignore-not-found=true -f manifests/deploy-job.yaml
    kubectl delete --ignore-not-found=true -f manifests/ingress.yaml
}

kubectl_config() {
    echo "Configuring kubectl"
    #shellcheck disable=SC2091
    $(bx cs cluster-config "$CLUSTER_NAME" | grep export)
}


kubectl_deploy() {
    kubeclt_clean

    echo "install Istio"
    curl -L https://git.io/getIstio | sh -
    pushd $(ls | grep istio)
    export PATH="$PATH:$(pwd)/bin"
    kubectl apply -f install/kubernetes/istio.yaml
    popd

    echo "Running scripts/quickstart.sh"
    "$(dirname "$0")"/../scripts/quickstart.sh

    echo "Waiting for pods to be running"
    i=0
    while [[ $(kubectl get pods | grep -c Running) -ne 6 ]]; do
        if [[ ! "$i" -lt 24 ]]; then
            echo "Timeout waiting on pods to be ready"
            test_failed "$0"
        fi
        sleep 10
        echo "...$i * 10 seconds elapsed..."
        ((i++))
    done
    echo "All pods are running"

    echo "Waiting for service to be available"
    sleep 120
}

verify_deploy(){
    echo "Verifying deployment was successful"
    PORT=$(kubectl get svc -n istio-system istio-ingress -o jsonpath={.spec.ports[0].nodePort})
    IPS=$(bx cs workers "$CLUSTER_NAME" | awk '{ print $2 }' | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
    for IP in $IPS; do
        if ! curl -sS http://"$IP":"$PORT"; then
            test_failed "$0"
        fi
    done
}

main(){
    is_pull_request "$0"

    if ! kubectl_config; then
        test_failed "$0"
    elif ! kubectl_deploy; then
        test_failed "$0"
    elif ! verify_deploy; then
        test_failed "$0"
    else
        test_passed "$0"
    fi
}

main
