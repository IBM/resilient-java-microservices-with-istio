function mvn_clean() {
  #statements
  cd $1
  mvn clean package
  cd ..
}

if [ $# -ne 1 ]; then
    echo "usage: ./get_code_osx.sh [docker username]"
    exit
fi

git clone https://github.com/WASdev/sample.microservices.web-app.git
mvn_clean sample.microservices.web-app
docker build -t $1/microservice-webapp sample.microservices.web-app
docker push $1/microservice-webapp

git clone https://github.com/WASdev/sample.microservices.schedule.git
mvn_clean sample.microservices.schedule
docker build -t $1/microservice-schedule sample.microservices.schedule
docker push $1/microservice-schedule

git clone https://github.com/WASdev/sample.microservices.speaker.git
mvn_clean sample.microservices.speaker
docker build -t $1/microservice-speaker sample.microservices.speaker
docker push $1/microservice-speaker

git clone https://github.com/WASdev/sample.microservices.session.git
mvn_clean sample.microservices.session
docker build -t $1/microservice-session sample.microservices.session
docker push $1/microservice-session

git clone https://github.com/WASdev/sample.microservices.vote.git
mvn_clean sample.microservices.vote
docker build -t $1/microservice-vote-cloudant sample.microservices.vote
docker push $1/microservice-vote-cloudant

sed -i '' s#"journeycode"#$1# manifests/deploy-schedule.yaml
sed -i '' s#"journeycode"#$1# manifests/deploy-session.yaml
sed -i '' s#"journeycode"#$1# manifests/deploy-speaker.yaml
sed -i '' s#"journeycode"#$1# manifests/deploy-vote.yaml
sed -i '' s#"journeycode"#$1# manifests/deploy-webapp.yaml

echo "All your images are uploaded to your $1 Dockerhub."