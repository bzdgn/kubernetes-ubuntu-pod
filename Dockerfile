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
