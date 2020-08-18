# DEV k8s env
.PHONY: apply-tf-boilerplate destroy-tf-boilerplate ansible-k8s
AWS_PROFILE:=
apply-tf-boilerplate:
	cd kubernetes-environment/terraform-cluster-boilerplate; \
	terraform apply -var aws_profile=$(AWS_PROFILE) -auto-approve && \
	cd -

destroy-tf-boilerplate:
	cd kubernetes-environment/terraform-cluster-boilerplate; \
	terraform destroy -var aws_profile=$(AWS_PROFILE) && \
	cd -

# sleep a little bit, due aws public ip initialization
ansible-k8s: apply-tf-boilerplate
	sleep 20
	ansible-playbook kubernetes-environment/ansible/site.yaml \
	-i kubernetes-environment/terraform-cluster-boilerplate/ansible-hosts.ini
