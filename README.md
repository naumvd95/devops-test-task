# Ataccama DevOps Engineer Technical Challenge

Hello! If you're reading this, you've applied to work with us as a DevOps Engineer. That's great!
As a first round of our hiring process, we want to see your technical ability. Please, read this README carefully, as it contains everything that you neeed to complete the task.

## Goal

This repository contains a little Golang application in `app` folder. You need to set up a complete end-to-end CI/CD pipeline, that will build & deploy an application on every commit to `master` branch.

You can read more about the application and it's dependencies in `app/README.md` file.

Please, clone this repo to your public GitHub, GitLab, BitBucket or other git service and go on from there. After you're done, please send us link to your repository.

You can use any open-source tools to implement this CI/CD pipeline, as well as any way to package and run the application. If you'd like to have a VM or two to work on - shoot us an email, we'll deploy two instances in AWS for you.

## Evaluation criteria

The main evaluation criteria is that the CI/CD pipeline works. Application has to run somewhere and be accessible via web browser. When a change in `master` branch of repository occurs, it should automatically propagate to application.

Apart from that we will evaluate:
* tools that you've picked
* correct usage of said tools
* code readability
* solution flexibility & extensibility

## To sum up

This task is loosely-defined on purpose. With DevOps being a set of practices at best and a buzzword at worst, we want to leave you some creative freedom in how you approach this task. There is no wrong solution, apart from a solution that outright doesn't work, so don't worry about it.

Good luck, and hope to hear back from you soon!

_Ataccama Cloud Solutions team_


## CICD architecture

### stage 1

To provide valid development process we need to prepare at least 2 k8s clusters:
1. Staging/Development - for rolling out dev version of the application
2. Prod - for upgrading existing application with latest release

Need to store kubeconfig of p.1 k8s cluster as secret in your CICD platform (git actions workflow),
on a permanent manner

```bash
cd cicd_stage_1
less README.md
```

Need to store dockerhub credentials as secret in your CICD platform (git actions workflow),
on a permanent manner. Using:

```bash
make DOCKER_USERNAME=your_dockerhub_username DOCKER_PASSWORD=your_dockerhub_pwd image-push
```

### stage 2

Github workflow actions will perform operations for building and testing application.
Similar operations available in Makefile to speedup local development:

Versioning:

```bash
make version
```

Update go dependencies:

```bash
make depend
make depend-update
```


Lint source code & helm chart:

```bash
make infra-lint
```

Build/Push new application image:

```bash
make app-image
make image-push
```

Manage application on predefined k8s cluster:

```bash
make deploy-app
make HELM_ARGS='--upgrade' deploy-app
make cleanup-app
```


## Technology introduction

### Why golang?

Shortly:
It's pretty easy to operate w/ binaries while you decide to follow microservice architecture.
Packing code into binaries, moving it inside containers and run over the container orchestrator

### Why binaries?

Shortly:
User can operate that binary w/o installation tons of dependencies. Just `wget` to your local machine and run.
Simple. From the other hand you may pack binaries in containers and run as cloud-native app.

### Why containers?

Shortly:
Get rid of all dependencies, you need only docker. Own safe sandbox with separate cgroups/namespaces for your experiments.
Check applicaition against multiple Operation Systems. Ability to run application in microservices-way. Containers is the best way
to build/test go binaries as well, you don't need to manage complicated go-infra on your CI/CD system

### Why microservices?

Shortly:
Cloud-native applications should be as much agile as possible and have ability to reflect to all code
changes quickly. When your applocation consists of thousands of pieces, it's easier to
change small parts and monitor whole service reflection. It's easier to debug application because each microservice
was developed to perform single, strictly defined goal. It's easier to perform upgrade procedures as well.

### Why Kubernetes?

Shortly:
Best container orchestration system at the current moment (26.04.2020).
- Pretty easy to implement Logging/Monitoring
- Actively develops
- CRD's for application customization
- Simple declarative way to rollout all k8s-objects
- Api customizable
- Customization of cri(docker, containerd), cni(calico, weave), csi(cloud-providers drivers, like cinder csi for OS cloud) interfaces
- AWS cloud provider support for management LB/PVC for applications automatically

### Why Helm?

Shortly:
Good approach for delivering/upgrading application on top of k8s cluster:
- upgrade support
- rollback support
- CICD implementation is simple(helm bin in docker image for example)
- manage application service dependencies as sub-charts

### Why AWS?

Shortly:
Most of companies in 2019-2020 prefer AWS as Cloud Platform for it's products. There is too much to say about differencies between cloud providers, but in our application abstraction level, there is no big difference.

### Why Terraform?

Shortly:
Awesome IaaC service that supports most valuable cloud providers and allow us simply build boilerplate for k8s cluster.
Also, it will be easier to support application testing on multiple cloud providers.
- Immutable infrastructure
- Declarative, not procedural code
- Super portability
- Ease of full-stack deployment

### Why Ansible?

Shortly:
Agile configuration management tool with simple over-ssh client-less architecture. Good solution for quick RnD projects.
Allows to rollout dev k8s cluster against instances boilerplate, made by terraform, that provides ability to automate
testing application daemonset.

### Why Makefile?

Shortly:
Aggegating all logic, needed to build/test/promote apllication in one place in form of simple shell scripts, allows you:
- Simplify development process, ypu may run make targets from your local machine
- Simplify CICD integration, pipelines will use the same make targets to reduce code duplicationg and possible differencies between local development and CI support.
- Trasfer from one CICD system to another is greatly facilitated, because all depedencies and logic hidden in project itslef, not in infra code.

### Why CICD?

Shortly:
Simplify development/testing/promoting processes, reduce human-related errors. Basically it's useless question in 2020.
