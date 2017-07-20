function mvn_clean() {
  #statements
  cd $1
  mvn clean package
  cd ..
}

bx cr login
export namespace=$(echo $(bx cr namespaces) | awk '{ print $4;exit }')

git clone https://github.com/WASdev/sample.microservicebuilder.web-app.git
mvn_clean sample.microservicebuilder.web-app
docker build -t registry.ng.bluemix.net/$namespace/microservice-webapp sample.microservicebuilder.web-app
docker push registry.ng.bluemix.net/$namespace/microservice-webapp

git clone https://github.com/WASdev/sample.microservicebuilder.schedule.git
mvn_clean sample.microservicebuilder.schedule
docker build -t registry.ng.bluemix.net/$namespace/microservice-schedule sample.microservicebuilder.schedule
docker push registry.ng.bluemix.net/$namespace/microservice-schedule

git clone https://github.com/WASdev/sample.microservicebuilder.speaker.git
mvn_clean sample.microservicebuilder.speaker
docker build -t registry.ng.bluemix.net/$namespace/microservice-speaker sample.microservicebuilder.speaker
docker push registry.ng.bluemix.net/$namespace/microservice-speaker

git clone https://github.com/WASdev/sample.microservicebuilder.session.git
mvn_clean sample.microservicebuilder.session
docker build -t registry.ng.bluemix.net/$namespace/microservice-session sample.microservicebuilder.session
docker push registry.ng.bluemix.net/$namespace/microservice-session

git clone https://github.com/WASdev/sample.microservicebuilder.vote.git vote-v1
cd vote-v1
git checkout 4bd11a9bcdc7f445d7596141a034104938e08b22
mvn clean package
docker build -t registry.ng.bluemix.net/$namespace/microservice-vote .
docker push registry.ng.bluemix.net/$namespace/microservice-vote
cd ..

git clone https://github.com/WASdev/sample.microservicebuilder.vote.git
mvn_clean sample.microservicebuilder.vote
docker build -t registry.ng.bluemix.net/$namespace/microservice-vote-cloudant sample.microservicebuilder.vote
docker push registry.ng.bluemix.net/$namespace/microservice-vote-cloudant

sed -i s#"<namespace>"#$namespace# manifests/deploy-schedule.yaml
sed -i s#"<namespace>"#$namespace# manifests/deploy-session.yaml
sed -i s#"<namespace>"#$namespace# manifests/deploy-speaker.yaml
sed -i s#"<namespace>"#$namespace# manifests/deploy-vote.yaml
sed -i s#"<namespace>"#$namespace# manifests/deploy-webapp.yaml

echo "All your images are uploaded to your $namespace namespace."