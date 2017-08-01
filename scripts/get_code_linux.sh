function mvn_clean() {
  #statements
  cd $1
  mvn clean package
  cd ..
}

if [ $# -ne 1 ]; then
    echo "usage: ./get_code_linux.sh [docker username]"
    exit
fi

git clone https://github.com/WASdev/sample.microservicebuilder.web-app.git
mvn_clean sample.microservicebuilder.web-app
docker build -t $1/microservice-webapp sample.microservicebuilder.web-app
docker push $1/microservice-webapp

git clone https://github.com/WASdev/sample.microservicebuilder.schedule.git
mvn_clean sample.microservicebuilder.schedule
docker build -t $1/microservice-schedule sample.microservicebuilder.schedule
docker push $1/microservice-schedule

git clone https://github.com/WASdev/sample.microservicebuilder.speaker.git
mvn_clean sample.microservicebuilder.speaker
docker build -t $1/microservice-speaker sample.microservicebuilder.speaker
docker push $1/microservice-speaker

git clone https://github.com/WASdev/sample.microservicebuilder.session.git
mvn_clean sample.microservicebuilder.session
docker build -t $1/microservice-session sample.microservicebuilder.session
docker push $1/microservice-session

git clone https://github.com/WASdev/sample.microservicebuilder.vote.git vote-v1
cd vote-v1
git checkout 4bd11a9bcdc7f445d7596141a034104938e08b22
mvn clean package
docker build -t $1/microservice-vote .
docker push $1/microservice-vote
cd ..

git clone https://github.com/WASdev/sample.microservicebuilder.vote.git
mvn_clean sample.microservicebuilder.vote
docker build -t $1/microservice-vote-cloudant sample.microservicebuilder.vote
docker push $1/microservice-vote-cloudant

sed -i s#"journeycode"#$1# manifests/deploy-schedule.yaml
sed -i s#"journeycode"#$1# manifests/deploy-session.yaml
sed -i s#"journeycode"#$1# manifests/deploy-speaker.yaml
sed -i s#"journeycode"#$1# manifests/deploy-vote.yaml
sed -i s#"journeycode"#$1# manifests/deploy-webapp.yaml

echo "All your images are uploaded to your $1 Dockerhub."