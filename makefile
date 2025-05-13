.PHONY: up down tf-apply tf-destroy seed install bench expose backup restore

# Minikube
MINIKUBE_PROFILE=paysera

# Python configuration
PYTHON=python3
PIP=$(PYTHON) -m pip
REQUIREMENTS=utils/requirements.txt

export PGPASSWORD=postgres

## Minikube + MetalLB
up:
	@echo "Starting Minikube with profile: $(MINIKUBE_PROFILE)..."
	minikube start --profile=$(MINIKUBE_PROFILE) --driver=docker --memory=4096 --cpus=2
	@echo "Minikube started."

	# @echo "Enabling MetalLB addon..."
	# minikube addons enable metallb --profile=$(MINIKUBE_PROFILE)

	# @echo "Cluster is ready with MetalLB support."

## Destroy everythings
down:
	@echo "Deleting Minikube cluster and cleaning up..."
	minikube delete --profile=$(MINIKUBE_PROFILE)
	@echo "Cluster deleted."

# Terraform apply
tf-apply:
	@echo "Running Terraform apply..."
	terraform init && terraform apply --auto-approve

# Terraform destroy
tf-destroy:
	@echo "Running Terraform destroy..."
	terraform destroy --auto-approve

## Seed Python dependencies install
install:
	@echo "Installing Python dependencies..."
	$(PIP) install --upgrade pip
	$(PIP) install -r $(REQUIREMENTS)

## Seed
seed: install
	@echo "Seeding the PostgreSQL database with synthetic data..."
	$(PYTHON) utils/seed.py

bench:
	@echo "Running bench test..."
	bash ./utils/bench.sh

# Expose apps
expose:
	@echo "Exposing Prometheus on http://localhost:9090"
	kubectl port-forward svc/prometheus-server 9090:80 -n monitoring &

	@echo "Exposing Grafana on http://localhost:3000"
	kubectl port-forward svc/grafana 3000:80 -n monitoring &

	@echo "Exposing Alertmanager on http://localhost:9093"
	kubectl port-forward svc/prometheus-alertmanager 9093:9093 -n monitoring &

	@echo "Exposing PostgreSQL on localhost:5432"
	kubectl port-forward svc/paysera-postgresql-ha-pgpool 5432:5432 -n paysera &

backup:
	@echo "Backuping postgres database..."
	kubectl exec -it paysera-postgresql-ha-postgresql-0 -n paysera -c postgresql -- env PGPASSWORD='postgres' pg_dumpall -U postgres > backup.sql

restore:
	@echo "Restoring postgres database..."
	kubectl exec -i paysera-postgresql-ha-postgresql-0 -n paysera -c postgresql -- env PGPASSWORD='postgres' psql -U postgres < backup.sql