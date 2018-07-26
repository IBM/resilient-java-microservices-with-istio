[![Build Status](https://travis-ci.org/IBM/resilient-java-microservices-with-istio.svg?branch=master)](https://travis-ci.org/IBM/resilient-java-microservices-with-istio)

# Enable your Java microservices with advanced resiliency features leveraging Istio

*Read this in other languages: [한국어](README-ko.md).*

Building and packaging Java microservice is one part of the story. How do we make them resilient? How do we introduce health checks, timeouts, retries, ensure request buffering or reliable communication between microservices? Some of these features are coming built in microservices framework, but often they are language specific, or you have to accommodate for it in your application code. How do we introduce it without changing the application code? Service-mesh architecture attempts to solve these issues. [Istio](https://istio.io) provides an easy way to create this service mesh by deploying a [control plane](https://istio.io/docs/concepts/what-is-istio/overview.html#architecture) and injecting sidecars containers alongside your microservice.

In this code we demonstrate how to build and deploy your Java [MicroProfile](http://microprofile.io) microservices leveraging Istio service mesh. MicroProfile is a baseline Java platform for a microservices architecture and delivers application portability across multiple MicroProfile runtimes - the initial baseline is JAX-RS plus CDI plus JSON-P. It provides specs for building and packaging Java microservices in a standardized way.

We then show how to configure and use circuit breakers, health checks and timeouts/retries resiliency features for the application.

**Resiliency and fault tolerance**: Istio adds fault tolerance to your application without any changes to code. Some resiliency features it supports are:

 - Retries/Timeouts
 - Circuit breakers
 - Health checks
 - Control connection pool size and request load
 - Systematic fault injection

We use the sample MicroProfile web application for managing a conference and it is based on a number of discrete microservices. The front end is written in Angular; the backing microservices are in Java. All run on WebSphere Liberty, in Docker containers managed by Kubernetes.

MicroProfile Fault Tolerance, adding application-specific capabilities such as failback functions that can work in conjunction with, or independently from, Istio capabilities will be the subject of a future update.

![MicroProfile-Istio](images/microprofile-istio.png)

## Included Components
- [MicroProfile](https://microprofile.io)
- [Istio (0.8)](https://istio.io/)
- [Kubernetes Clusters (1.9+)](https://console.ng.bluemix.net/docs/containers/cs_ov.html#cs_ov)
- [Cloudant](https://www.ibm.com/analytics/us/en/technology/cloud-data-services/cloudant/)
- [Bluemix DevOps Toolchain Service](https://console.ng.bluemix.net/catalog/services/continuous-delivery)
- [WebSphere](https://developer.ibm.com/wasdev/websphere-liberty)

# Prerequisite
- Create a Kubernetes cluster with either [Minikube](https://kubernetes.io/docs/getting-started-guides/minikube) for local testing, with [IBM Cloud Private](https://github.com/IBM/deploy-ibm-cloud-private/blob/master/README.md), or with [IBM Bluemix Container Service](https://console.bluemix.net/docs/containers/container_index.html#clusters) to deploy in cloud. The code here is regularly tested against [Kubernetes Cluster from Bluemix Container Service](https://console.ng.bluemix.net/docs/containers/cs_ov.html#cs_ov) using Travis.
- You will also need Istio service mesh installed on top of your Kubernetes cluster. Please follow the instructions, [Istio Quick Start](https://istio.io/docs/setup/kubernetes/quick-start.html), to get Istio mesh installed on Kubernetes.

# Steps

## Part A: Building microservices and enabling ingress traffic

1. [Get and build the application code](#1-get-and-build-the-application-code)
2. [Deploy application microservices and Istio envoys](#2-deploy-application-microservices-and-istio-envoys)

## Part B: Explore Istio resiliency features: Circuit Breakers and Fault Injection

3. [Circuit Breakers - Maximum connections and pending requests](#3-circuit-breakers---maximum-connections-and-pending-requests)
4. [Circuit Breakers - Load balancing pool ejection](#4-circuit-breakers---load-balancing-pool-ejection)
5. [Timeouts and Retries](#5-timeouts-and-retries)

#### [Troubleshooting](#troubleshooting-1)


## Part A: Building microservices and enabling ingress traffic
## 1. Get and build the application code

> If you don't want to build your own images, you can use our default images and move on to [Step 2](#2-deploy-application-microservices-and-istio-envoys).

Before you proceed to the following instructions, make sure you have [Maven](https://maven.apache.org/install.html) and [Docker](https://www.docker.com/community-edition#/download) installed on your machine.

First, clone and get in our repository to obtain the necessary yaml files and scripts for downloading and building your applications and microservices.

```shell
git clone https://github.com/IBM/resilient-java-microservices-with-istio.git
cd resilient-java-microservices-with-istio
```

Now, make sure you login to Docker first before you proceed to the following step.

> **Note:** For the following steps, you can get the code and build the package by running
> ```shell
> ./scripts/get_code_linux.sh [docker username] #For Linux users
> ./scripts/get_code_osx.sh [docker username] #For Mac users
> ```
>Then, you can move on to [Step 2](#2-deploy-application-microservices-and-istio-envoys).

  `git clone` and `mvn clean package` the following projects:
   * [Web-App](https://github.com/WASdev/sample.microservices.web-app)
   ```shell
      git clone https://github.com/WASdev/sample.microservices.web-app.git
  ```
   * [Schedule](https://github.com/WASdev/sample.microservices.schedule)
   ```shell
      git clone https://github.com/WASdev/sample.microservices.schedule.git
  ```
   * [Speaker](https://github.com/WASdev/sample.microservices.speaker)
   ```shell
      git clone https://github.com/WASdev/sample.microservices.speaker.git
  ```
   * [Session](https://github.com/WASdev/sample.microservices.session)
   ```shell
      git clone https://github.com/WASdev/sample.microservices.session.git
  ```
   * [Vote](https://github.com/WASdev/sample.microservices.vote)
   ```shell
      git clone https://github.com/WASdev/sample.microservices.vote.git
  ```
* `mvn clean package` in each ../sample.microservices.* projects

Now, use the following commands to build the microservice containers.

Build the web-app microservice container

```shell
docker build -t <docker_username>/microservice-webapp sample.microservices.web-app
docker push <docker_username>/microservice-webapp
```

Build the schedule microservice container

```shell
docker build -t <docker_username>/microservice-schedule sample.microservices.schedule
docker push <docker_username>/microservice-schedule
```

Build the speaker microservice container

```shell
docker build -t <docker_username>/microservice-speaker sample.microservices.speaker
docker push <docker_username>/microservice-speaker
```

Build the session microservice container

```shell
docker build -t <docker_username>/microservice-session sample.microservices.session
docker push <docker_username>/microservice-session
```

Build the vote microservice container

```shell
docker build -t <docker_username>/microservice-vote-cloudant sample.microservices.vote
docker push <docker_username>/microservice-vote-cloudant
```

## 2. Deploy application microservices and Istio envoys


The great thing about Istio is you can deploy your application on Istio without changing any of your files. However, the original MicroProfile example is built on top of the Fabric (an extra infrastructure services on top of Kubernetes). Therefore, you need to deploy the application with the yaml files in this repository.

Before you proceed to the following steps, change the `journeycode` in your yaml files to your own docker username if you want to use your own docker images.
>Note: If you ran the **get_code** script, your docker username is already changed in your yaml files.

Envoys are deployed as sidecars on each microservice. Injecting Envoy into your microservice means that the Envoy sidecar would manage the ingoing and outgoing calls for the service. To inject an Envoy sidecar into an existing microservice configuration, do:
```shell
#First we Create a secret for cloudant credential
kubectl create secret generic cloudant-secret --from-literal=dbUsername=admin --from-literal=dbPassword=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`

kubectl apply -f <(istioctl kube-inject -f manifests/deploy-schedule.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-session.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-speaker.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-cloudant.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-vote.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-webapp.yaml)
```

After a few minutes, you should now have your Kubernetes Pods running and have an Envoy sidecar in each of them alongside the microservice. The microservices are **schedule, session, speaker, vote, cloudant, and webapp**.
```shell
$ kubectl get pods
NAME                                           READY     STATUS      RESTARTS   AGE
cloudant-db-4102896723-6ztmw                   2/2       Running     0          1h
microservice-schedule-sample-971365647-74648   2/2       Running     0          2d
microservice-session-sample-2341329899-2bjhg   2/2       Running     0          2d
microservice-speaker-sample-1294850951-w76b5   2/2       Running     0          2d
microservice-vote-sample-3728755778-5c4vx      2/2       Running     0          1h
microservice-webapp-sample-3875068375-bvp87    2/2       Running     0          2d
```

To access your application, you need to create an Istio Gateway to connect all the microservices and access it. Thus, do:

```shell
istioctl create -f manifests/istio-gateway.yaml
```

You can check the public IP address of your IBM Cloud cluster through `bx cs workers <your_cluster_name>` and get the NodePort of the istio-ingress service for port 80 through `kubectl get svc -n istio-system | grep istio-ingress`. Or you can also run the following command to output the IP address and NodePort:
```bash
echo $(bx cs workers <your_cluster_name> | grep normal | awk '{ print $2 }' | head -1):$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[0].nodePort}')
# Replace <your_cluster_name> with your cluster name. This should output your IP:NodePort e.g. 184.172.247.2:30344
```

Point your browser to:
`http://<IP:NodePort>` Replace `<IP:NodePort>` with your own IP and NodePort.

Congratulations, you MicroProfile application is running and it should look like [this](microprofile_ui.md).

## Part B: Explore Istio resiliency features: Circuit Breakers and Fault Injection

## 3. Circuit Breakers - Maximum connections and pending requests

Circuit breaking is a critical component of distributed systems. It’s nearly always better to fail quickly and apply back pressure downstream as soon as possible. Envoy enforces circuit breaking limits at the network level as opposed to having to configure and code each application independently.

Now we will show you how to enable circuit breaker for the sample Java microservice application based on maximum connections your database can handle.

Before we move on, we need to understand these different types of Circuit Breaker:
- Maximum Connections: Maximum number of connections to a backend. Any excess connection will be pending in a queue. You can modify this number by changing the `maxConnections` field.
- Maximum Pending Requests: Maximum number of pending requests to a backend. Any excess pending requests will be denied. You can modify this number by changing the `http1MaxPendingRequests` field.

Now take a look at the **circuit-breaker-db.yaml** file in manifests. We set Cloudant's maximum connections to 1 and Maximum pending requests to 1. Thus, if we sent more than 2 requests at once to cloudant, cloudant will have 1 pending request and deny any additional requests until the pending request is processed. Furthermore, it will detect any host that triggers a server error (5XX code) in the Cloudant's Envoy and eject the pod out of the load balancing pool for 15 minutes. You can visit [here](https://istio.io/docs/tasks/traffic-management/circuit-breaking/) to check out more details for each field.

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: db-circuit
  namespace: default
spec:
  host: cloudant-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 1
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 1
    outlierDetection:
      http:
        consecutiveErrors: 1
        interval: 1s
        baseEjectionTime: 15m
        maxEjectionPercent: 100

```

![circuit breaker](images/circuit_breaker.png)


Create a circuit breaker policy on your cloudant service.

```shell
istioctl create -f manifests/circuit-breaker-db.yaml
```

Now point your browser to:  `http://<IP:NodePort>`, enable your **developer mode** on your browser, and click on **network**. Go to Speaker or Session and try to vote 5 times within a second. Then, you should see the last 2 to 3 vote will return a server error because there are more than one pending request get sent to cloudant. Therefore, the circuit breaker will eject the rest of the requests.

> Note: using fault injection or mixer rule won't able to trigger the circuit breaker because all the traffic will be aborted/delayed before it get sent to the cloudant's Envoy.

## 4. Circuit Breakers - Load balancing pool ejection

> Note: We will use the same circuit breaker policy from the previous step.

A load balancing pool is a set of instances that are under the same Kubernetes service, and envoy distributes the traffic across those instances. If some of those instances are broken, the circuit breaker can eject any broken pod in your load balancing pool to avoid any further failure. To demonstrate this, create a new cloudant database instance, cloudant-db pod 2, that listens to the wrong host.

```shell
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-broken-cloudant.yaml)
```

To better test the load balancing pool ejection, you don't want the circuit breaker to eject requests for maximum connection and pending requests. Hence, remove or comment out this block:
```
connectionPool:
      tcp:
        maxConnections: 1
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 1
```
inside **manifests/circuit-breaker-db.yaml** and run

```shell
istioctl replace -f manifests/circuit-breaker-db.yaml
```

Now go to the MicroProfile example on your browser and vote on any session. Then you will see the first vote will return a 500 server error because the cloudant-db pod 2 is broken. However, the circuit breaker will detect that error and eject that broken cloudant pod out of the pool. Thus, if you keep voting within the next 15 minutes, none of that traffic will go to the broken cloudant because it won't return to the pool until 15 minutes later.

![circuit breaker2](images/circuit_breaker2.png)

You can double check the broken cloudant only received the traffic once.
```shell
kubectl get pods # check your cloudant-db-second name
kubectl logs cloudant-db-second-xxxxxxx-xxxxx istio-proxy --tail=150 # You can replace 150 with the number of logs you like to display.
```
As you can see, there will only be one HTTP call within the logs.

Before you move to the next step, please remove the broken cloudant and circuit breaker policy.
```shell
kubectl delete -f manifests/deploy-broken-cloudant.yaml
istioctl delete -f manifests/circuit-breaker-db.yaml
```

## 5. Timeouts and Retries

Here's an example to demonstrate how can you add resiliency via timeouts in your application. First, we want to create a 1-second timeout to the vote service, so the vote service can stop listening if cloudant is not responding within 1-second.

Then, in order to make sure we can trigger and test this, we will inject more than 1-second delay to cloudant, so the vote service will be timeout for each response from cloudant. This process is called Fault Injection, where essentially we are introducing fault injection.

![fault tolerance](images/fault_tolerance.png)

Now take a look at the **timeout-vote** file in manifests.
```yaml
apiVersion: config.istio.io/v1alpha2
kind: RouteRule
metadata:
  name: timeout
  namespace: default
spec:
  destination:
    name: vote-service
  httpReqTimeout:
    simpleTimeout:
      timeout: 1s
```

This rule will timeout all the responses that take more than 1 second in the vote service. You can modify `timeout` to add more time for your timeout. You also can apply retries rule by uncommenting the `httpReqRetries` section and delete/commenting out the `httpReqTimeout` section. Now, let's apply a 1-second timeout on your Vote service.

```shell
istioctl create -f manifests/timeout-vote.yaml
```

In order to test our timeout rule is working properly, we need to apply some fault injections. Thus, take a look at the **fault-injection.yaml** in manifests.
```yaml
apiVersion: config.istio.io/v1alpha2
kind: RouteRule
metadata:
  name: cloudant-delay
  namespace: default
spec:
  destination:
    name: cloudant-service
  httpFault:
    delay:
      percent: 100
      fixedDelay: 1.1s
```

This rule will inject a fixed 1.1-second delay on all the requests going to Cloudant. You can modify `percent` and `fixedDelay` to change the probability and the amount of time for delay. Furthermore, you can uncomment the abort section to inject some abort errors. Now let's apply a 1.1-second delay on the cloudant service to trigger your Vote service timeout.

```shell
istioctl create -f manifests/fault-injection.yaml
```

Now point your browser to:  `http://<IP:NodePort>`

Next, enable your **developer mode** on your browser and click on **network**. Then, click **Vote** on the microprofile site. Now you should able to see a 504 timeout error for the GET request on `http://<IP:NodePort>/vote/rate` since cloudant needs more than one second to response back to the vote service.

# Troubleshooting
* To delete Istio from your cluster, run the following commands in your istio directory
```shell
kubectl delete -f install/kubernetes/istio-rbac-alpha.yaml # or istio-rbac-beta.yaml
kubectl delete -f install/kubernetes/istio.yaml
```
* To delete your microprofile application, run the following commands in this Github repo's main directory
```shell
kubectl delete -f manifests
```

* To delete your route rule or destination policy, run the following commands in this Github repo's main directory
```shell
istioctl delete -f manifests/<filename>.yaml #Replace <filename> with the rule/policy file name you want to delete.
```

* If you have trouble with the maven build, your maven might have some dependency conflicts. Therefore, you need to purge your dependencies and rebuild your application by running the following commands
```shell
mvn dependency:purge-local-repository
mvn clean package
```

* Your microservice vote will use cloudantDB as the database, and it will initialize the database on your first POST request on the application. Therefore, when you vote on the speaker/session for your first time, please only vote once within the first 10 seconds to avoid causing a race condition on creating the new database.


# References
[Istio.io](https://istio.io/docs/tasks/index.html)

This Java MicroProfile codebase is based on WebSphere Liberty's [MicroProfile Showcase Application](https://github.com/WASdev/sample.microservices.docs)

# License
[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)
