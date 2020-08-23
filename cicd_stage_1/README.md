### Environment

0. Install orchestrator tooling

[terraform  v0.12.25](https://learn.hashicorp.com/tutorials/terraform/install-cli)
[ansible 2.9.12](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

1. K8s cluster with AWS provider support for auto management LB, PVC, etc..

Create:

```bash
make AWS_PROFILE=foo ansible-k8s
```

Verify cluster:

```bash
kubectl --kubeconfig kubeconfig-public.yaml get nodes
```

Manage public kubeconfig file as secret `kubeconfig_ervcp_dev` in your CICD (github actions).

Delete:

```bash
make AWS_PROFILE=foo destroy-tf-boilerplate
```
⚠️  Warning: cleanup all application releases from k8s cluster before `Delete` operation.
ERVCP applications uses AWS ELB, that's creates dynamically through AWS cloud provider,
Terraform will hang on vpc deleting operation because of unknown LB dependencies.

#### Room for improvements
- manage k8s control plane and worker node security groups as separate entities
