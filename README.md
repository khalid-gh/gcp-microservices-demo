# gcp-microservices-demo

[![static-analysis](https://github.com/khalid-gh/gcp-microservices-demo/actions/workflows/workflow.yml/badge.svg?branch=main)](https://github.com/khalid-gh/gcp-microservices-demo/actions/workflows/workflow.yml)
[![Google Cloud](https://img.shields.io/badge/Google%20Cloud-%234285F4.svg?logo=google-cloud&logoColor=white)](https://docs.cloud.google.com/docs)
[![Terraform](https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=fff)](https://developer.hashicorp.com/terraform/docs)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=fff)](https://kubernetes.io/docs/home/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=fff)](https://helm.sh/docs/)
[![Argo CD](https://img.shields.io/badge/Argo%20CD-EF7B4D?logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Istio](https://img.shields.io/badge/Istio-466BB0?logo=istio&logoColor=fff)](https://istio.io/latest/docs/)

Deploying Google Cloud's [Online Boutique microservices demo](https://github.com/googlecloudplatform/microservices-demo) on GKE with Terraform, Helm, Argo CD, and Istio.

## Overview

A personal project exploring GCP infrastructure, Kubernetes, GitOps, and service
meshes. This repository contains the configuration used to deploy the environment
and describes its architecture. It is not intended as a reusable deployment
template or a production reference architecture.

## Architecture

![Private GKE architecture with Argo CD, Istio, Kiali, and Prometheus](diagrams/architecture.drawio.png)

- Terraform manages the GCP infrastructure and Helm releases.
- A private GKE cluster runs Online Boutique on Spot nodes.
- Argo CD deploys Online Boutique from its Helm chart using configuration stored in Git.
- Istio sidecars handle service-to-service traffic.
- Kiali and Prometheus provide service-mesh visualisation and traffic metrics.

## Access and cost considerations

The environment has no public load balancers. Access to the private cluster uses
an IAP tunnel and Privoxy, with localhost port forwarding for Online Boutique,
Argo CD, and Kiali.

Spot nodes reduce compute costs, while Prometheus uses ephemeral storage with
six-hour retention instead of a dedicated persistent disk. Metrics are lost when
the Prometheus pod is replaced. GCP charges still apply for resources such as
GKE nodes and their disks, the Privoxy VM, Cloud NAT, and billable network traffic.
GKE cluster-management fees may apply, depending on free-tier eligibility.
Istio, Kiali, and Prometheus consume node CPU and memory and may cause the node pool to scale up.
