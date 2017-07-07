echo "Creating Java MicroProfile App"

IP_ADDR=$(bx cs workers $CLUSTER_NAME | grep normal | awk '{ print $2 }')
if [ -z $IP_ADDR ]; then
  echo "$CLUSTER_NAME not created or workers not ready"
  exit 1
fi

echo -e "Configuring vars"
exp=$(bx cs cluster-config $CLUSTER_NAME | grep export)
if [ $? -ne 0 ]; then
  echo "Cluster $CLUSTER_NAME not created or not ready."
  exit 1
fi
eval "$exp"

echo "changing target images for all the yaml files"
kubectl delete --ignore-not-found=true -f manifests/deploy-schedule.yaml
kubectl delete --ignore-not-found=true -f manifests/deploy-session.yaml
kubectl delete --ignore-not-found=true -f manifests/deploy-speaker.yaml
kubectl delete --ignore-not-found=true -f manifests/deploy-vote.yaml
kubectl delete --ignore-not-found=true -f manifests/deploy-webapp.yaml
kubectl delete --ignore-not-found=true -f manifests/deploy-cloudant.yaml
kubectl delete --ignore-not-found=true -f manifests/deploy-job.yaml
kubectl delete --ignore-not-found=true -f manifests/ingress.yaml
sed -i s#"registry.ng.bluemix.net/<namespace>"#"docker.io/tomcli"# manifests/deploy-schedule.yaml
sed -i s#"registry.ng.bluemix.net/<namespace>"#"docker.io/tomcli"# manifests/deploy-session.yaml
sed -i s#"registry.ng.bluemix.net/<namespace>"#"docker.io/tomcli"# manifests/deploy-speaker.yaml
sed -i s#"registry.ng.bluemix.net/<namespace>"#"docker.io/tomcli"# manifests/deploy-vote.yaml
sed -i s#"registry.ng.bluemix.net/<namespace>"#"docker.io/tomcli"# manifests/deploy-webapp.yaml

echo "install Istio"
curl -L https://git.io/getIstio | sh -
cd $(ls | grep istio)
export PATH="$PATH:$(pwd)/bin"
kubectl apply -f install/kubernetes/istio-rbac-alpha.yaml
kubectl apply -f install/kubernetes/istio.yaml

#Make sure all the pods are running before proceeding to the next step.
PODS=$(kubectl get pods | grep istio | grep Pending)
while [ ${#PODS} -ne 0 ]
do
    echo "Some Pods are Pending..."
    PODS=$(kubectl get pods | grep istio | grep Pending)
    sleep 5s
done
PODS=$(kubectl get pods | grep istio | grep ContainerCreating)
while [ ${#PODS} -ne 0 ]
do
    echo "Some Pods are still creating Containers..."
    PODS=$(kubectl get pods | grep istio | grep ContainerCreating)
    sleep 5s
done
echo "Finished Istio Control Plane setup."

echo "Creating Java MicroProfile with Injected Envoys..."
cd ..
kubectl create -f manifests/ingress.yaml
kubectl apply -f manifests/deploy-job.yaml
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-schedule.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-session.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-speaker.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-cloudant.yaml --includeIPRanges=172.30.0.0/16,172.20.0.0/16)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-vote.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-webapp.yaml)
istioctl create -f manifests/route-rule-v1.yaml

PODS=$(kubectl get pods | grep Init)
while [ ${#PODS} -ne 0 ]
do
    echo "Some Pods are Initializing..."
    PODS=$(kubectl get pods | grep Init)
    sleep 5s
done
echo "Java MicroProfile done."

echo "Getting IP and Port"
kubectl get nodes
kubectl get svc | grep ingress
export GATEWAY_URL=$(kubectl get po -l istio=ingress -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc istio-ingress -o 'jsonpath={.spec.ports[0].nodePort}')
echo $GATEWAY_URL
if [ -z "$GATEWAY_URL" ]
then
    echo "GATEWAY_URL not found"
    exit 1
fi
kubectl get pods,svc
echo "You can now view your Sample Java MicroProfile App at http://$GATEWAY_URL"
echo "Note: It will take up to 5 minutes for the app to be fully functioning."
