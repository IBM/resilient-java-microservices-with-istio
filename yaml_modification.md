# Modification of the yaml files for MicroProfile example.

For this Istio example, we modified the following yaml files in the MicroProfile example. All the new yaml files are in [this](manifests) manifests folder. You can click on each following file to view the detailed changes.

- [*deploy-webapp.yaml*](images/webapp_diff.png)
- [*deploy-schedule.yaml*](images/schedule_diff.png)
- [*deploy-speaker.yaml*](images/speaker_diff.png)
- [*deploy-session.yaml*](images/session_diff.png)
- [*deploy-vote.yaml*](images/vote_diff.png)

Since the original MicroProfile example is built on top of the Fabric (an extra infrastructure services on top of Kubernetes), we need to remove all the Microservice Builder dependencies (readinessProbe, livenessProbe, env, volumeMounts, and volumes) from the original yaml files in order to deploy the application without any infrastructure services and on Istio. 

In addition, we added some lables and changed the image names, so users can use their own images and manage all the deployments using the app tag. We also added the target port so the service discovery can do less work and deploy the application much faster. 

Moreover, we break down the *deploy-vote.yaml* in the vote microservice to *deploy-job.yaml*, *deploy-cloudant.yaml*, and *deploy-vote.yaml* since the original *deploy-vote.yaml* puts everything into one yaml file and we want to inject the sidecar differently for the cloudant microservice. Also, since we have 2 version of vote microservice, we added an extra deployment v2 in *deploy-vote.yaml*.

Lastly, since we will use the Istio ingress for our endpoints, we created the `ingress.yaml` to replace all the xxx-ingress.yaml file in each microservice.

> Note: All the other yaml files in this manifests folder are for Istio route rule and destination policy.
