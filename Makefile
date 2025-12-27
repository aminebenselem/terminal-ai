.PHONY: build install docker-build test clean help

# Variables
BINARY_NAME := terminal-ai-core
BACKEND_IMAGE := terminal-ai-backend
VERSION := latest

# Go parameters
GOCMD := go
GOBUILD := $(GOCMD) build
GOTEST := $(GOCMD) test
GOMOD := $(GOCMD) mod

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the AI core engine
	@echo "Building AI core engine..."
	cd ai-core && $(GOBUILD) -ldflags="-s -w" -o $(BINARY_NAME) engine.go
	@echo "Build complete: ai-core/$(BINARY_NAME)"

install: build ## Install CLI binary and shell adapters
	@echo "Running installation script..."
	chmod +x install.sh
	./install.sh

test: ## Run tests
	@echo "Running tests..."
	cd ai-core && $(GOTEST) -v ./...

docker-build: ## Build Docker images
	@echo "Building backend Docker image..."
	docker build -f devops/docker/backend.Dockerfile -t $(BACKEND_IMAGE):$(VERSION) .
	@echo "Docker image built: $(BACKEND_IMAGE):$(VERSION)"

docker-run: ## Run Docker container locally
	@echo "Running backend container..."
	docker run -d -p 8080:8080 --name terminal-ai-backend $(BACKEND_IMAGE):$(VERSION)
	@echo "Backend running on http://localhost:8080"

docker-stop: ## Stop Docker container
	docker stop terminal-ai-backend || true
	docker rm terminal-ai-backend || true

docker-logs: ## View Docker container logs
	docker logs -f terminal-ai-backend

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	rm -f ai-core/$(BINARY_NAME)
	rm -f cli/$(BINARY_NAME)
	@echo "Clean complete"

uninstall: ## Uninstall CLI binary
	@echo "Uninstalling terminal-ai..."
	sudo rm -f /usr/local/bin/terminal-ai
	sudo rm -f /usr/local/bin/$(BINARY_NAME)
	@echo "Uninstall complete"
	@echo "Note: Shell adapter configuration in ~/.bashrc or ~/.zshrc needs to be removed manually"

dev: build ## Build and run in development mode
	./ai-core/$(BINARY_NAME) "list all files"

all: clean build install docker-build ## Build everything
	@echo "All targets completed successfully"
