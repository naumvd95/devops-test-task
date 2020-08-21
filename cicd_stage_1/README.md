### Environment

0. Install orchestrator tooling

[terraform  v0.12.25](https://learn.hashicorp.com/tutorials/terraform/install-cli)
[ansible 2.9.12](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

1. K8s cluster with AWS provider support for auto management LB, PVC, etc..

Create:

```bash
make AWS_PROFILE=foo ansible-k8s
```

Manage public kubeconfig file, stored in repository
```bash
kubectl --kubeconfig kubeconfig-public.yaml get nodes
```

Delete:

```bash
make AWS_PROFILE=foo destroy-tf-boilerplate
```

#### Room for improvements
- manage k8s control plane and worker node security groups as separate entities
