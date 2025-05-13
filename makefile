.PHONY: up down

# Minikube
MINIKUBE_PROFILE=paysera

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
