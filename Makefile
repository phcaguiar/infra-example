.PHONY: init apply

init:
	terraform init -reconfigure

validate:
	terraform validate

plan:
	terraform plan

apply: init
	terraform apply -auto-approve
