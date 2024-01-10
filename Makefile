tf-docs:
	terraform-docs -c terraform-docs.yml . > README.md

tf-init:
	terraform init

tf-plan:
	terraform plan

tf-apply:
	terraform apply