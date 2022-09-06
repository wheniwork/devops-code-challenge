.PHONY: container dev-env deploy help test test-1-version test-2-health test-3-curl test-4-probes todo

default: help

# dev and deploy targets

container: ## build the dev container
	podman build -f Containerfile -t wheniwork/devops-code-challenge .

dev-env: ## launch the dev container and mount the current KUBECONFIG
	podman run -it --rm \
		-v ${KUBECONFIG}:${KUBECONFIG}:ro \
		-e KUBECONFIG=${KUBECONFIG} \
		wheniwork/devops-code-challenge -- bash

deploy: ## apply kubernetes resources using the current KUBECONFIG
	kubectl apply -f kubernetes/namespace.yaml
	kubectl apply -f kubernetes/mysql.yaml
	kubectl apply -f kubernetes/wordpress.yaml

# test targets

test: ## run challenge test scenarios
test: test-1-version test-2-health test-3-curl test-4-probes test-5-endpoints

test-1-version: ## run kubernetes version test
	@echo "running kubernetes version test"
	if kubectl version -o=json | grep minor | tr -d ' ' | grep -qve '"minor":"[2-9][1-9]",'; \
	then \
		echo "version test failed!"; \
		exit 1; \
	else \
		echo "version test passed"; \
	fi

test-2-health: ## run pod health test
	@echo "running pod health test"
	if kubectl -n code-challenge get pods -o=jsonpath='{.items[*].status.phase}' | grep -qvx Running; \
	then \
		echo "health test passed"; \
	else \
		echo "health test failed!"; \
		exit 1; \
	fi

test-3-curl: ## run curl request test
	@echo "running curl test"
	if curl --fail $(shell minikube service wordpress -n code-challenge --url); \
	then \
		echo "curl test passed"; \
	else \
		echo "curl test failed!"; \
		exit 1; \
	fi

test-4-probes: ## run pod probe test
	@echo "running probe test"
	( \
		export IMAGE_COUNT="$(shell kubectl -n code-challenge get pods -o=jsonpath='{range .items[*].spec.containers[*].image}{.}{"\n"}{end}' | wc -l | tr -d ' ')"; \
		export LIVENESS_COUNT="$(shell kubectl -n code-challenge get pods -o=jsonpath='{range .items[*].spec.containers[*].livenessProbe}{.}{"\n"}{end}' | wc -l | tr -d ' ')"; \
		export READINESS_COUNT="$(shell kubectl -n code-challenge get pods -o=jsonpath='{range .items[*].spec.containers[*].readinessProbe}{.}{"\n"}{end}' | wc -l | tr -d ' ')"; \
		if [ $$IMAGE_COUNT -ne $$LIVENESS_COUNT ]; then echo "failed liveness probe test!"; exit 1; fi; \
		if [ $$IMAGE_COUNT -ne $$READINESS_COUNT ]; then echo "failed readiness probe test!"; exit 1; fi; \
		echo "probe test passed"; \
	)

test-5-endpoints:
	@echo "running endpoint test"
	if kubectl -n code-challenge describe svc | grep Endpoints | grep -q '<none>'; \
	then \
		echo "service endpoint test failed!"; \
		exit 1; \
	else \
		echo "endpoint test passed"; \
	fi

# helper targets

# from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## print this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
		| sed 's/^.*\/\(.*\)/\1/' \
		| awk 'BEGIN {FS = ":( ##)?"}; {printf "\033[36m%-32s\033[0m %-80s (%s)\n", $$2, $$3, $$1}' \
		| sort

todo: ## print any remaining TODOs
	@echo "Remaining tasks:"
	@echo ""
	@grep -i "todo" -r "$(shell dirname $(firstword $(MAKEFILE_LIST)))" || true
