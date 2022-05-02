Kubernetes Ubuntu Pod Example
=============================
If you need a Kubernetes Pod where you can apply basic simple commands like ping, curl, wget for debug or general purpose, you are at the right place. This simple tutorial will lead you to have a Kubernetes Pod debloyed based on Ubuntu image.

TOC
- [1 Build Pod Image Based on Ubuntu](1-build-pod-image-based-on-ubuntu)
- [2 Push Image To Docker Repository](2-push-image-to-docker-repository)
- [3 Prepare Deployment YAML](3-prepare-deployment-yaml)
- [4 Deploy to Kubernetes Environment](4-deploy-to-kubernetes-environment)


1 Build Pod Image Based on Ubuntu
---------------------------------
First we need to build an image based on Ubuntu. We are going to use the base image as Ubuntu and install followings;

- java
- wget
- curl
- ping
- nmap
- kubectl

So that if we need these tools, we can just connect to the Pod terminal and run them. That's the idea of a debug pod.

We are going to use the following Dockerfile;

```
FROM ubuntu:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install default-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get -y install wget

RUN mkdir /workbench

RUN wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.13.1/opentelemetry-javaagent.jar -P /workbench/

RUN apt-get update && \
    apt-get -y install curl

RUN apt-get update && \
    apt-get install -y iputils-ping

RUN apt-get update && \
    apt-get install -y nmap

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN dir
RUN mv ./kubectl /usr/local/bin
```

Our docker image will be based on this Dockerfile.


[Go back to TOC](#toc)


2 Push Image To Docker Repository
---------------------------------
Then we are going to build it with the following procedure;

```
docker build -t bzdgn/debug-pod:latest -t bzdgn/debug-pod:v1.0 .

docker image tag bzdgn/debug-pod:latest <your-target-custom-image-repository-here>/bzdgn/debug-pod:latest

docker push <your-target-custom-image-repository-here>/bzdgn/debug-pod:latest
```

In the first command we have build the debug pod locally, with two tags, **latest** and **v1.0**.
In the second, we tagged it for our target repository (docker.io, harbor,... can be anything)
In the third command, we push it.

When we push it, we are done. Make sure that your kubernetes environment uses the targer repository. Our deployment file will reference to that image.


[Go back to TOC](#toc)


3 Prepare Deployment YAML
-------------------------
What we are going to do is, just prepare a pod referencing to our image, and also make it stay awake.

Here is our Deployment Yaml file;

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: bzdgn-debug-pod
  labels:
    egress-frontoffice-policy: allow
    my-label: my-label-value
spec:
  imagePullSecrets:
    - name: harbor-puller                                           # This will be your image pull secret
  containers:
    - name: bzdgn-debug-pod-container
      image: <your_image_repository_here>/bzdgn/debug-pod:latest    # This will be your image reference
      command: ["/bin/sleep", "3650d"]                              # We keep the Pod alive for 3650 days
      imagePullPolicy: Always
      resources:
        limits:
          cpu: 500m
          memory: 5Gi
        requests:
          cpu: 100m
          memory: 1Gi
---
```

You have to update at least one commented line, which is;

- spec.containers.image : Image reference

[Go back to TOC](#toc)


4 Deploy to Kubernetes Environment
----------------------------------
Now we have to deploy it with the use of **kubectl** command as below;

```
kubectl apply -f deployment.yaml
```

If you want to delete it;

```
kubectl apply -f deployment.yaml
```

When you deploy it, you can easily connect it via terminal. Here is an example via **OpenShift** environment;

![openshift-terminal](https://github.com/bzdgn/kubernetes-ubuntu-pod/blob/master/openshift_terminal.png)


[Go back to TOC](#toc)
