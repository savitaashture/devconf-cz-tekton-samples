# devconf-cz-tekton-sampless

## Prerequisites:
* You have access to the cluster as a user with the cluster-admin role.
* You have installed the kubectl
* You have Ingress running on you cluster if not follow
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
kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/previous/v0.54.0/release.notags.yaml
```
Check the status of Operator:
```text
1. kubectl get deploy -n tekton-operator
    NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
    tekton-operator           1/1     1            1           2m11s
    tekton-operator-webhook   1/1     1            1           2m10s

2. kubectl get deploy -n tekton-pipelines
    NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
    tekton-dashboard                    1/1     1            1           103s
    tekton-operator-proxy-webhook       1/1     1            1           2m36s
    tekton-pipelines-controller         1/1     1            1           2m36s
    tekton-pipelines-webhook            1/1     1            1           2m36s
    tekton-triggers-controller          1/1     1            1           2m6s
    tekton-triggers-core-interceptors   1/1     1            1           2m6s
    tekton-triggers-webhook             1/1     1            1           2m6s

2. kubectl get TektonConfig
    NAME     READY   REASON
    config   True   
```

After installing dashboard, install the ingress:
```text
kubectl apply -f ingress/dashboard-ingress.yaml
```
```text
kubectl get ingress -n tekton-pipelines
NAME               CLASS    HOSTS   ADDRESS        PORTS   AGE
tekton-dashboard   <none>   *       35.193.61.53   80      23s
```
```yaml
access dashboard
http://35.193.61.53/dashboard
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
kubectl -n demo create secret docker-registry demo-credentials --docker-server=docker.io --docker-username=savita3020 --docker-password=<password>
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

verify Task creation
```yaml
kubectl get task -n demo
NAME               AGE
buildah            29s
git-clone          20s
openshift-client   34s
```

#### Create SA, Roles, Pipeline and PipelineRun
```text
kubectl -n demo create -f samples/
```
verify PipelineRun creation
```yaml
kubectl get pipelinerun -n demo
NAME                                 SUCCEEDED   REASON      STARTTIME   COMPLETIONTIME
build-deploy-api-pipelinerun-wqjmc   True        Succeeded   2m32s       57s
```

### Dynamic pipelinerun creation based on events

```text
kubectl -n demo create -f samples/triggers/
```
verify EventListener creation
1. EventListener Object
```yaml
kubectl -n demo get el
NAME                          ADDRESS                                                             AVAILABLE   REASON                     READY   REASON
github-listener-interceptor   http://el-github-listener-interceptor.demo.svc.cluster.local:8080   True        MinimumReplicasAvailable   True
```
2. Get Pod created by EventListener
```yaml
kubectl get pods -n demo
NAME                                              READY   STATUS      RESTARTS   AGE
el-github-listener-interceptor-86cf6d886c-wchmx   1/1     Running     0          5m9s
``` 

#### Create ingress route for EL
```text
kubectl -n demo create -f ingress/el-ingress.yaml
```

#### Get ingress URL and configure in webhook
```text
kubectl get ing -n demo
NAME             CLASS    HOSTS   ADDRESS        PORTS   AGE
tekton-trigger   <none>   *       35.193.61.53   80      33s
```
```yaml
access EventListener
curl http://35.193.61.53/ci/
```

#### Configure EL URL in GitHub webhook
![Webhook Configuration](https://github.com/savitaashture/devconf-cz-tekton-samples/blob/main/image/webhook.png)

Create/reopen a PR for this repository.

```text
kubectl -n demo get pipelinerun | grep build-deploy-api-pipelinerun-
```
to see the created PipelineRun.
