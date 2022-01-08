# kcd-tekton-sampless

## Prerequisites:

### minikube
``` text
minikube addons enable ingress
minikube addons enable ingress-dns
```
### Kubernetes
* Install and verify nginx.
```text
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/cloud/deploy.yaml
```
```text
kubectl get pods -n ingress-nginx \
  -l app.kubernetes.io/name=ingress-nginx --watch
```

## Tekton installation
```text
kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/previous/v0.53.0/release.yaml
```
```text
https://raw.githubusercontent.com/tektoncd/operator/release-v0.53.x/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml
```
Check the status of Operator:
```text
kubectl get deploy -n tekton-operator
```
After installing dashboard, install the ingress:
```text
kubectl apply -f ingress/dashboard-ingress.yaml
```
```text
kubectl get ingress -n tekton-pipelines
```

## Example Demo
#### Clone the code
```text
git clone https://github.com/savitaashture/devconf-cz-tekton-samples/
```
#### Create Namespace
```text
kubectl create ns demo
```

### Manual Pipeline Creation
#### Create secret
```text
kubectl -n demo create secret docker-registry demo-credentials --docker-server=quay.io --docker-username=savitaashture --docker-password=<password>
```

#### Create Tasks
```text
kubectl -n demo apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/openshift-client/0.1/openshift-client.yaml
```
```text
kubectl -n demo apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/buildah/0.2/buildah.yaml
```
```text
kubectl -n demo apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.4/git-clone.yaml
```

#### Create SA, Roles, Pipeline and PipelineRun
```text
kubectl -n demo create -f samples/
```
### Dynamic pipelinerun creation based on events

```text
kubectl -n demo create -f samples/triggers/
```

#### Create ingress route for EL
```text
kubectl -n demo create -f ingress/el-ingress.yaml
```

#### Get ingress URL and configure in webhook
```text
kubectl get ing -n demo
```

#### Configure EL URL in GitHub webhook
![Webhook Configuration](https://github.com/savitaashture/devconf-cz-tekton-samples/blob/main/image/webhook.png)

Create/reopen a PR for this repository.

```text
kubectl -n demo get pipelinerun | grep build-deploy-api-pipelinerun-
```
to see the created PipelineRun.
