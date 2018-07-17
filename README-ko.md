[![Build Status](https://travis-ci.org/IBM/resilient-java-microservices-with-istio.svg?branch=master)](https://travis-ci.org/IBM/resilient-java-microservices-with-istio)

# Istio 를 활용하여 Java 애플리케이션의 향상된 회복 탄력 기능을 확보하세요 

*다른 언어로 보기: [English](README.md).*

Java 마이크로 서비스를 빌드하고 패키지하는 것은 이 이야기의 한 부분입니다. 이 마이크로 서비스들이 어떻게 회복 탄력성을 갖도록 할 수 있을까요? 마이크로 서비스간 헬스 체크(health check), 타임아웃, 재시도, 요청 버퍼링이나 신뢰도 높은 통신의 도입은 어떻게 할까요? 이에 대한 일부 기능이 마이크로 프레임워크에서 내장될 것이라 하지만, 특정 언어에 국한되어 있거나 이를 애플리케이션 코드에서 처리해야 하는 경우가 많습니다. 애플리케이션 코드의 변경 없이 이와 같은 기능을 도입하려면 어떻게 해야 할까요? 서비스 메쉬(service-mesh) 아키텍쳐가 이와 같은 이슈를 해결하고자 합니다. [Istio](https://istio.io)는 [컨트롤 플레인(control plane)](https://istio.io/docs/concepts/what-is-istio/overview.html#architecture)을 배포하고 대상 마이크로 서비스 옆에서 실행되는 사이드카(sidecar) 컨테이너를 주입하여 손쉽게 서비스 메쉬를 생성할 수 있도록 합니다. 

이 코드에는  Istio 서비스 메쉬를 활용한 Java [MicroProfile](http://microprofile.io) 마이크로 서비스의 빌드 및 배포하는 방법을 시연합니다. MicroProfile은 마이크로 서비스 아키텍쳐를 위한 Java 플랫폼 베이스라인이며 다중 MicroProfile 런타임에 대한 애플리케이션 이식성을 제공합니다 - 초기 베이스라인은 JAX-RS, CDI 그리고 JSON-P가 더해진 형태입니다. 이는 표준화된 방법으로 Java 마이크로 서비스를 빌드하고 패키지하기 위한 규격을 제공합니다. 

그다음에는, 애플리케이션에 대한 서킷 브레이커 (circuit breaker), 헬스 체크 그리고 타임아웃/재시도 등의 회복 탄력 기능을 어떻게 설정하고 사용하는지 보여줍니다.

**회복 탄력 기능 및 내결함성**: Istio는 애플리케이션의 어떠한 코드 변경 없이 내결함성을 추가 합니다. Istio가 지원하는 회복 탄력 기능 중 일부는 다음과 같습니다: 

 - 재시도/타임아웃(retry/timeout)
 - 서킷 브레이커(circuit breaker)
 - 헬스 체크(health check)
 - 연결 풀(pool) 크기 및 요청 부하(request load) 조정
 - 시스템적인 실패 주입(fault injection)

컨퍼런스 관리를 위한 MicroProfile 웹 애플리케이션 예제는 몇 개의 분리된 마이크로 서비스들로 구성되어 있습니다. 프론드엔드는 Angular로 작성되었고; 백엔드 마이크로 서비스는 Java로 되어 있습니다. 모두 쿠버네티스로 관리되는 Docker 컨테이너의 WebSphere Liberty에서 실행됩니다.

MicroProfile 내결함성 즉, Istio 기능과 함께 혹은 독립적으로 동작할 수 있는 failback 함수와 같은 애플리케이션에 특화 기능을 추가하는 것은 향후 업데이트 포함될 예정입니다.

![MicroProfile-Istio](images/microprofile-istio.png)

## 포함된 구성 요소
- [MicroProfile](https://microprofile.io)
- [Istio](https://istio.io/)
- [Kubernetes Clusters](https://console.ng.bluemix.net/docs/containers/cs_ov.html#cs_ov)
- [Cloudant](https://www.ibm.com/analytics/us/en/technology/cloud-data-services/cloudant/)
- [Bluemix DevOps Toolchain Service](https://console.ng.bluemix.net/catalog/services/continuous-delivery)
- [WebSphere](https://developer.ibm.com/wasdev/websphere-liberty)

# 전제 조건
- 로컬 테스트를 위해 [Minikube](https://kubernetes.io/docs/getting-started-guides/minikube)를 사용하거나 [IBM Bluemix Container Service](https://github.com/IBM/container-journey-template)를 클라우드에 배치하여 쿠버네티스 클러스터를 생성하십시오. 이곳의 코드는 [Bluemix Container 서비스의 쿠버네티스 클러스터](https://console.ng.bluemix.net/docs/containers/cs_ov.html#cs_ov)에 대해 Travis를 사용하여 정기적으로 테스트됩니다.
- 또한, 생성한 쿠버네티스 클러스터에 Istio 서비스 메쉬를 설치해야 합니다. 다음 지침을 따라 쿠버네티스에 Istio 서비스 메시를 설치하십시오. [Istio 시작하기 ](https://github.com/IBM/Istio-getting-started).

# Bluemix에 배포하기
Java MicroProfile 앱을 Bluemix에 직접 배포하고자 한다면 'Deploy to Bluemix' 버튼을 클릭하여 예제를 위한 [Bluemix DevOps service toolchain and pipeline](https://console.ng.bluemix.net/docs/services/ContinuousDelivery/toolchains_about.html#toolchains_about)를 생성하십시오 그렇지 않으면 다음 [단계](#단계)로 이동하십시오.

> 쿠버네티스 클러스터를 먼저 생성하며, Bluemix 계정에 완전히 배포되어야 합니다.

[![Create Toolchain](https://github.com/IBM/container-journey-template/blob/master/images/button.png)](https://console.ng.bluemix.net/devops/setup/deploy/)

툴체인과 파이프 라인을 완료하려면 [Toolchain 지침](https://github.com/IBM/container-journey-template/blob/master/Toolchain_Instructions_new.md)을 따르십시오.

# 단계

## 파트 A: 마이크로 서비스 빌드와 ingress 트래픽 활성화 하기

1. [애플리케이션 코드 확보 및 빌드하기](#1-애플리케이션-코드-확보-및-빌드하기)
2. [애플리케이션 마이크로 서비스와 Istio envoy 배포하기](#2-애플리케이션-마이크로-서비스와-istio-envoy-배포하기)

## 파트 B: Istio 회복 탄력 기능 알아보기: 서킷 브레이커와 실패 주입

3. [서킷 브레이커 - 연결 및 요청 보류에 대한 최대 값](#3-서킷-브레이커---연결-및-요청-보류에-대한-최대-값)
4. [서킷 브레이커 - 부하 분산 풀 사출](#4-서킷-브레이커---부하-분산-풀-사출)
5. [타임아웃과 재시도](#5-타임아웃과-재시도)

#### [문제 해결](#문제-해결)


## 파트 A: 마이크로 서비스 빌드와 ingress 트래픽 활성화 하기
## 1. 애플리케이션 코드 확보 및 빌드하기

> 자신만의 이미지를 빌드하는 것을 원하지 않는다면 기본으로 제공하는 이미지를 사용 할 수 있습니다. [단계 2](#2-애플리케이션-마이크로-서비스와-istio-envoy-배포하기)로 진행하십시오.

아래 지침을 수행하기 전에, [Maven](https://maven.apache.org/install.html)과 [Docker](https://www.docker.com/community-edition#/download)가 여러분 머신에 설치되어 있어야 합니다.

먼저, 이 저장소를 복제하여 애플리케이션과 마이크로 서비스의 다운로드 및 빌드에 필수적인 yaml 파일과 스크립트를 얻으십시오.

```shell
git clone https://github.com/IBM/resilient-java-microservices-with-istio.git 
cd resilient-java-microservices-with-istio
```

아래 단계를 진행하기 전에 먼저 Docker에 로그인 해야 합니다.

> **참고:** 아래 명령을 실행하여 코드를 얻고 패키지를 빌드 할 수 있습니다 
> ```shell
> ./scripts/get_code_linux.sh [docker username] #Linux 사용자용
> ./scripts/get_code_osx.sh [docker username] #Mac 사용자용
> ```
>그러면, [단계 2](#2-deploy-application-microservices-and-istio-envoys)로 진행 할 수 있습니다.

  아래 프로젝트들에 대해 각각 `git clone` 과 `mvn clean package` 를 실행하십시오:
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
* 각각의 ../sample.microservices.* 프로젝트에서 `mvn clean package` 를 실행하십시오.

이제, 아래 명령들을 사용하여 마이크로 서비스 컨테이너를 빌드하십시오.

web-app 마이크로 서비스 컨테이너 빌드하기

```shell
docker build -t <docker_username>/microservice-webapp sample.microservices.web-app
docker push <docker_username>/microservice-webapp
```

schedule 마이크로 서비스 컨테이너 빌드하기

```shell
docker build -t <docker_username>/microservice-schedule sample.microservices.schedule
docker push <docker_username>/microservice-schedule
```

speaker 마이크로 서비스 컨테이너 빌드하기

```shell
docker build -t <docker_username>/microservice-speaker sample.microservices.speaker
docker push <docker_username>/microservice-speaker
```

session 마이크로 서비스 컨테이너 빌드하기

```shell
docker build -t <docker_username>/microservice-session sample.microservices.session
docker push <docker_username>/microservice-session
```

vote 마이크로 서비스 컨테이너 빌드하기

```shell
docker build -t <docker_username>/microservice-vote-cloudant sample.microservices.vote
docker push <docker_username>/microservice-vote-cloudant
```

## 2. 애플리케이션 마이크로 서비스와 Istio envoy 배포하기


Istio의 훌륭한 기능은 애플리케이션 파일 변경 없이 Istio에 배포 할 수 있다는 점입니다. 그러나, 오리지널 MicroProfile 예제가 Fabric(쿠버네티스 위에 놓여있는 추가적인 인프라 서비스)에 구축된 예제인지라, 이 저장소에 있는 yaml 파일로 애플리케이션을 배포해야 합니다.

아래 단계를 진행하기 전에, 여러분만의 고유한 docker 이미지를 사용하고자 한다면 yaml 파일 안의 `journeycode` 를 여러분의 docker username으로 변경해야 합니다.
>참고: **get_code** 스크립트를 실행했다면, yaml 파일에 docker username이 이미 변경되어 있을 겁니다.

Envoy는 각 마이크로 서비스에 사이드카로 배치됩니다. Envoy를 마이크로 서비스에 주입한다는 것은 Envoy 사이드카가 서비스에 대한 들어오고 나가는 연결을 관리한다는 것을 의미합니다. 기존 마이크로 서비스 구성에 Envoy 사이드카를 주입하려면 다음과 같이 하십시오:
```shell
kubectl apply -f manifests/deploy-job.yaml #cloudant 신임 정보를 위한 secret을 생성합니다
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-schedule.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-session.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-speaker.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-cloudant.yaml --includeIPRanges=172.30.0.0/16,172.20.0.0/16)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-vote.yaml)
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-webapp.yaml)
```

몇 분 후, 쿠버네티스 Pod의 마이크로 서비스 옆에서 실행되는 각자의 Envoy 사이드카를 볼 수 있게 됩니다. 해당 마이크로 서비스는 **schedule, session, speaker, vote-v1, vote-v2, cloudant 및 webapp** 입니다. 
```shell
$ kubectl get pods
NAME                                           READY     STATUS      RESTARTS   AGE
cloudant-db-4102896723-6ztmw                   2/2       Running     0          1h
istio-egress-3946387492-5wtbm                  1/1       Running     0          2d
istio-ingress-4179457893-clzjf                 1/1       Running     0          2d
istio-mixer-2598054512-bm3st                   1/1       Running     0          2d
istio-pilot-2676867826-z63pq                   2/2       Running     0          2d
microservice-schedule-sample-971365647-74648   2/2       Running     0          2d
microservice-session-sample-2341329899-2bjhg   2/2       Running     0          2d
microservice-speaker-sample-1294850951-w76b5   2/2       Running     0          2d
microservice-vote-sample-3728755778-5c4vx      2/2       Running     0          1h
microservice-webapp-sample-3875068375-bvp87    2/2       Running     0          2d   
```

애플리케이션에 접근하기 위해, 여러분은 모든 마이크로 서비스로 연결하는 ingress를 생성하고 istio ingress를 통해 접근하고자 할 것입니다. 다음과 같이 실행 하십시오:

```shell
kubectl create -f manifests/ingress.yaml
```

`bx cs workers <your_cluster_name>`을 통해 클러스터의 공용 IP 주소를 확인하고 `kubectl get svc | grep istio-ingress`으로 포트 80에 대한 istio-ingress 서비스의 NodePort를 얻을 수 있습니다. 아니면 다음 명령을 실행하여 IP 주소와 NodePort를 출력할 수도 있습니다:
```bash
echo $(bx cs workers <your_cluster_name> | grep normal | awk '{ print $2 }' | head -1):$(kubectl get svc istio-ingress -o jsonpath={.spec.ports[0].nodePort})
# <your_cluster_name> 을 여러분의 클러스터 이름으로 교체하십시오. 이는 여러분 머신에 대한 IP:NodePort를 출력합니다. 예시. 184.172.247.2:30344
```

브라우저에서 다음 주소로 접근하십시오:  
`http://<IP:NodePort>` `<IP:NodePort>`를 여러분의 IP 및 NodePort로 교체하십시오.

축하합니다, 여러분의 MicroProfile 애플리케이션이 실행되어 [이것](microprofile_ui.md)과 같은 모습인 것을 볼 수 있을 것입니다.

## 파트 B: Istio 회복 탄력 기능 알아보기: 서킷 브레이커와 실패 주입

## 3. 서킷 브레이커 - 연결 및 요청 보류에 대한 최대 값

서킷 브레이커는 분산 시스템의 매우 중요한 요소입니다. 빨리 실패하고 가능한 빠르게 백엔드에 대한 배압(back pressure downstream)을 적용하는 것이 거의 항상 더 낫습니다. Envoy는 각각의 애플리케이션에서 독립적인 설정 및 코딩을 하는 것과 달리 네트워크 레벨에서 서킷 브레이크 제한을 강제합니다. 

이제, 데이터 베이스가 처리 할 수 있는 최대 연결 수를 기반으로 Java 마이크로 서비스 예제 애플리케이션에 서킷 브레이커를 적용하는 방법을 보여주고자 합니다.

그전에 아래와 같은 서킷 브레이커 종류의 차이를 이해할 필요가 있습니다:
- 최대 연결: 백엔드로 연결 가능한 최대 수. 이를 초과하는 연결은 큐(Queue)에서 대기 상태가 됩니다. `maxConnections` 필드 값을 수정하여 이 값을 조정할 수 있습니다.
- 최대 요청 보류: 벡엔드로의 요청 보류에 대한 최대 수. 이를 초과하는 요청의 경우 거부됩니다. `httpMaxPendingRequests` 필드 값을 수정하여 이 값을 조정할 수 있습니다.

이제, manifests에 있는 **circuit-breaker-db.yaml** 파일을 살펴봅시다. Cloudant의 최대 연결 수를 1 그리고 최대 요청 보류 수를 1로 설정했습니다. 그렇기에, Cloudant에 한 번에 두 개 이상 연결하면 하나는 보류되고 나머지는 보류된 요청이 처리되기까지 거부됩니다. 거기에 더해, Cloudant의 Envoy에서 서버 오류 (5XX 코드)를 발생시키는 호스트를 탐지하게 되고 해당 pod를 분산 풀(pool)에서 15분 동안 빼놓게 됩니다. [여기](https://istio.io/docs/reference/config/traffic-rules/destination-policies.html#simplecircuitbreakerpolicy)를 방문하면 이에 대한 각각의 필드를 상세하게 알아 볼 수 있습니다. 

```yaml
type: destination-policy
name: db-circuit
spec:
  destination: cloudant-service.default.svc.cluster.local
  policy:
    - circuitBreaker:
        simpleCb:
          maxConnections: 1
          httpMaxPendingRequests: 1
          httpConsecutiveErrors: 1     
          sleepWindow: 15m             #required field
          httpDetectionInterval: 1s    #required field   
          httpMaxEjectionPercent: 100  
```

![circuit breaker](images/circuit_breaker.png)


Cloudant 서비스에 대한 서킷 브레이커 정책을 생성하십시오.

```shell
istioctl create -f manifests/circuit-breaker-db.yaml
```

이제 브라우저로 `http://<IP:NodePort>`를 접속하여 브라우저의 **개발자 모드**를 활성화 한 후 **네트워크** 항목을 클릭합니다. Speaker나 Session으로 이동해서 투표(vote)를 1초 동안 5회 시도합니다. 그러면, Cloudant에 보내져 보류된 요청 수가 하나보다 많게 되어 마지막 2, 3개의 투표가 서버 오류를 얻게 되는 것을 볼 수 있습니다. 따라서, 해당 서킷 브레이커는 나머지 요청들을 차단하게 됩니다.

> 참고: 실패 주입(fault injection)이나 mixer 규칙(rule)을 이용하는 것은 서킷 브레이커 실행을 유발하지 못합니다. 왜냐하면 모든 트래픽이 Cloudant Envoy에 도달하기 전에 취소되거나 지연되기 때문입니다.

## 4. 서킷 브레이커 - 부하 분산 풀 사출

> 참고: 앞 단계의 서킷 브레이커와 동일한 것을 사용하게 됩니다.

부하 분산 풀(pool)은 같은 쿠버네티스 서비스 아래 있는 인스턴스들의 집합이며, Envoy가 이 인스턴스들에 대해 트래픽을 분산합니다. 만약 이런 인스턴스 중 일부가 동작하지 않는 경우, 서킷 브레이커는 이 동작하지 않는 인스턴스들이 나중에 문제를 일으키는 것을 피하기 위해 부하 분산 풀에서 제거할 수 있습니다. 이를 시연하기 위해 잘못된 호스트를 기다리는 새로운 Cloudant 데이터 베이스 인스턴스(cloudant-db pod 2)를 생성하십시오.

```shell
kubectl apply -f <(istioctl kube-inject -f manifests/deploy-broken-cloudant.yaml --includeIPRanges=172.30.0.0/16,172.20.0.0/16)
```

부하 분산 풀 사출을 쉽게 테스트 할 수 있도록 
최대 연결 및 최대 요청 보류에 관한 서킷 브레이커 기능은 원하지 않을 것입니다. 따라서, **manifests/circuit-breaker-db.yaml** 에서 `maxConnections: 1` 과 `httpMaxPendingRequests: 1` 를 삭제하고 다음을 실행합니다

```shell
istioctl replace -f manifests/circuit-breaker-db.yaml
```

이제 브라우저에서 MicroProfile 예제로 접속하여 아무 세션(Session)에 투표(vote)하십시오. 그러면, cloudant-db pod 2의 오류로 인해 첫 번째 투표에서 500 서버 에러가 발생하는 것을 볼 수 있게 됩니다. 그렇지만, 서킷 브레이커가 오류를 탐지하고 오류가 발생한 cloudant pod를 풀에서 제거하게 됩니다. 따라서, 이후 15분이 지날 때까지는 오류가 발생하는 cloudant가 풀로 되돌아가지 않게되므로, 15분 동안은 계속 투표해도 해당 cloudant로 전달되는 트래픽이 없게 됩니다.


![circuit breaker2](images/circuit_breaker2.png)

오류가 발생한 Cloudant가 단 한 번의 트래픽을 받았다는 것을  이중으로 확인 할 수 있습니다. 
```shell
kubectl get pods # 두 번째 cloudant-db 의 이름을 확인 합니다
kubectl logs cloudant-db-second-xxxxxxx-xxxxx proxy --tail=150 # 화면에 표시될 로그 메시지 라인 수 조정을 위해 150 값을 변경 할 수 있습니다.
```
보시다시피, 로그에는 오직 한 번의 HTTP 호출만 볼 수 있을겁니다.

다음 단계로 이동하기 전에, 오류가 발생하는 cloudant와 서킷 브레이커 정책을 삭제해 주십시오.
```shell
kubectl delete -f manifests/deploy-broken-cloudant.yaml
istioctl delete -f manifests/circuit-breaker-db.yaml
```

## 5. 타임아웃과 재시도

여기는 애플리케이션에 타임아웃을 통한 회복 탄력성을 추가하는 방법을 시연하게 됩니다. 먼저, vote 서비스에 1초 타임아웃을 발생하여, cloudant 서비스가 1초 이내에 응답이 없는 경우 vote 서비스의 수신을 중단할 수 있게 합니다.

그러면, 이를 반드시 발생하고 테스트 할 수 있도록, 1초 이상의 지연을 cloudant에 주입하고, cloudant로 부터의 각각의 응답에 대해 타임아웃이 되도록 합니다. 이 단계는 앞으로 소개 할 실패 주입(fault injection)이라고 불립니다.

![내결함성](images/fault_tolerance.png)

이제 manifests에 있는 **timeout-vote** 파일을 살펴 봅시다.
```yaml
type: route-rule
name: timeout
spec:
  destination: vote-service.default.svc.cluster.local
  httpReqTimeout:
    simpleTimeout:
      timeout: 1s
  # httpReqRetries:
  #   simpleRetry:
  #     attempts: 3
  #     perTryTimeout: 1s
```

이 규칙(rule)은 vote 서비스에서 1초 보다 오래 걸리는 모든 것에 대한 응답으로 타임아웃을 발생 시킵니다. `timeout`에 값을 더해 여러분만의 타임아웃을 지정 할 수 있습니다. 또한 `httpReqRetries` 영역의 코멘트를 제거하거나 `httpReqTimeout`를 삭제 또는 코멘트 처리하는 방법으로 재시도 규칙을 반영 할 수 있습니다. 이제 1초 타임아웃을 여러분의 Vote 서비스에 적용 해 봅니다.

```shell
istioctl create -f manifests/timeout-vote.yaml
```

타임아웃 규칙이 잘 동작하는지 확인하기 위해, 몇 개의 실패를 주입해야 합니다. 그러므로, manifests에 있는 **fault-injection.yaml** 를 살펴 보십시오. 
```yaml
type: route-rule
name: cloudant-delay
spec:
  destination: cloudant-service.default.svc.cluster.local
  precedence: 2
  httpFault:
    delay:
      percent: 100
      fixedDelay: 1.1s
    # abort:
    #   percent: 10
    #   httpStatus: 503
```

이 규칙은 수정된 1.1초 지연을 Cloudant로 가는 모든 요청에 주입하게 됩니다.  `percent`와 `fixedDelay`를 수정하여 지연에 대한 확률이나 시간을 변경 할 수 있습니다. 게다가, abort 영역을 코멘트 해제하여 몇몇 오류들을 주입 할 수도 있습니다. 이제, Vote 서비스의 타임아웃을 발생시키도록 1.1초 지연을 Cloudant 서비스에 반영해 봅시다.

```shell
istioctl create -f manifests/fault-injection.yaml
```

브라우저에서 `http://<IP:NodePort>` 에 접속합니다.

다음으로, 브라우저의 **개발자 모드**를 활성화 하고 **네트워크**를 클릭합니다. 그리고, MicroProfile 사이트에서 **Vote**를 클릭합니다. 이제 cloudant가 vote 서비스로 응답을 주는데 1초보다 더 많이 필요하기에 `http://<IP:NodePort>/vote/rate`에 대한 요청에 대해 504 타임아웃 에러가 발생하는 것을 볼 수 있게 됩니다.

# 문제 해결
* 클러스터에서 Istio를 삭제하려면, istio 디렉토리에서 아래 명령을 실행하십시오
```shell
kubectl delete -f install/kubernetes/istio-rbac-alpha.yaml # or istio-rbac-beta.yaml
kubectl delete -f install/kubernetes/istio.yaml
```
* MicroProfile 애플리케이션을 삭제하려면, Github 저장소의 main 디렉토리에서 아래 명령을 실행하십시오
```shell
kubectl delete -f manifests
```

* 경로 규칙(규칙route rule)이나 대상 정책을 삭제하려면, Github 저장소의 main 디렉토리에서 아래 명령을 실행하십시오
```shell
istioctl delete -f manifests/<filename>.yaml #Replace <filename> with the rule/policy file name you want to delete.
```

* maven 빌드에 문제가 발생한다면, maven이 필요로하는 의존 정보가 충돌하기 때문입니다. 따라서, 기존 의존 정보를 삭제하고 아래 명령으로 애플리케이션을 다시 빌드 하십시오
```shell
mvn dependency:purge-local-repository
mvn clean package
```

* vote 마이크로 서비스는 데이터 베이스로 cloudantDB를 사용하게 되며 애플리케이션의 첫 번째 POST 요청시 데이터 베이스를 초기화 합니다. 따라서, Speaker나 Session에 처음 투표 할 때 , 새로운 데이터 베이스를 만드는데 경쟁 조건이 발생하지 않도록 10초 이내에 한 번만 실행해 주십시오.

# 참조
[Istio.io](https://istio.io/docs/tasks/index.html)

Java MicroProfile 코드는 WebSphere Liberty의 [Microprofile Showcase Application](https://github.com/WASdev/sample.microservices.docs)을 기반으로 하고 있습니다.

# 라이센스
[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)

