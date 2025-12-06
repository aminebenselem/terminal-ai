# Terminal AI

> An intelligent terminal assistant with enterprise-grade DevOps infrastructure

Terminal AI is a CLI tool that provides AI-powered command suggestions directly in your terminal, backed by a scalable Go HTTP server and deployed on Kubernetes with full observability via the ELK stack.

## 🚀 Features

- **Intelligent Command Suggestions**: AI-powered terminal assistance integrated into your shell
- **Multi-Shell Support**: Native adapters for Bash, Zsh, and POSIX-compliant shells
- **Lightweight Go Engine**: Fast, compiled binary with minimal dependencies
- **Scalable Backend**: HTTP server ready for production workloads
- **Kubernetes Deployment**: Full K8s manifests for container orchestration
- **Infrastructure as Code**: Terraform configurations for reproducible deployments
- **Complete Observability**: ELK stack (Elasticsearch + Logstash + Kibana) for logs and metrics

## 📁 Project Structure

```
terminal-ai/
├── cli/                         # CLI entrypoint
│   └── terminal-ai              # shell-executable launcher
├── ai-core/                     # AI logic (Go engine)
│   └── engine.go                # input → suggestion logic
├── adapters/                    # shell-specific integration
│   ├── adapter.zsh
│   ├── adapter.bash
│   └── adapter.posix
├── devops/                      # DevOps layer
│   ├── terraform/               # Terraform configs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── k8s/                     # Kubernetes manifests
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── elasticsearch.yaml
│   │   ├── logstash-configmap.yaml
│   │   └── kibana.yaml
│   └── docker/                  # Dockerfiles
│       ├── backend.Dockerfile
│       └── elk.Dockerfile
├── install.sh                   # installs CLI + adapters
├── Makefile                     # build, test, deploy tasks
├── README.md
└── LICENSE
```

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| CLI | Go binary |
| Shell Integration | Bash, Zsh, POSIX |
| Backend | Go HTTP server |
| Container Runtime | Docker |
| Orchestration | Kubernetes (Minikube) |
| IaC | Terraform |
| Observability | ELK Stack (Elasticsearch, Logstash, Kibana) |
| Build System | Makefile |

## 📦 Installation

### Prerequisites

- Go 1.21+
- Docker
- Minikube (for local Kubernetes)
- Terraform 1.5+
- kubectl

### Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/terminal-ai.git
cd terminal-ai

# Build the AI core engine
make build

# Install CLI and shell adapters
make install

# Build Docker images
make docker-build

# Deploy to Kubernetes
make terraform
make k8s-deploy
```

### Manual Installation

```bash
# Build the Go engine
cd ai-core
go build -o terminal-ai-core engine.go
sudo mv terminal-ai-core /usr/local/bin/

# Install shell adapter
./install.sh
```

Restart your shell or run:
```bash
source ~/.zshrc  # for Zsh
source ~/.bashrc # for Bash
```

## 💻 Usage

### CLI Mode

```bash
# Get a command suggestion
terminal-ai "list all files modified today"

# Pass arguments directly
terminal-ai find large files
```

### Interactive Shell Mode

Once the adapter is installed, use the keybinding in your shell:

- **Zsh/Bash**: Press `Tab` after typing a partial command
- The AI suggestion will appear inline

Example:
```bash
$ list files in current dir<TAB>
# Suggestion: ls -la
```

## 🏗️ Architecture

```
┌─────────────┐
│   Terminal  │
│   (Bash/Zsh)│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ CLI Adapter │
└──────┬──────┘
       │
       ▼
┌─────────────┐      ┌──────────────┐
│  AI Core    │─────▶│   Backend    │
│  (Go CLI)   │      │  (Go HTTP)   │
└─────────────┘      └──────┬───────┘
                            │
                            ▼
                     ┌──────────────┐
                     │  Logstash    │
                     └──────┬───────┘
                            │
                            ▼
                     ┌──────────────┐
                     │Elasticsearch │
                     └──────┬───────┘
                            │
                            ▼
                     ┌──────────────┐
                     │   Kibana     │
                     └──────────────┘
```

## 🐳 Docker

### Build Images

```bash
# Build backend image
docker build -f devops/docker/backend.Dockerfile -t terminal-ai-backend:latest .

# Build ELK image (optional, can use official images)
docker build -f devops/docker/elk.Dockerfile -t terminal-ai-elk:latest .
```

### Run Locally

```bash
# Run backend
docker run -p 8080:8080 terminal-ai-backend:latest

# Run with Docker Compose (if configured)
docker-compose up -d
```

## ☸️ Kubernetes Deployment

### Using Terraform

```bash
cd devops/terraform
terraform init
terraform plan
terraform apply
```

### Manual Deployment

```bash
# Create namespace
kubectl create namespace ai-backend

# Deploy backend
kubectl apply -f devops/k8s/backend-deployment.yaml
kubectl apply -f devops/k8s/backend-service.yaml

# Deploy ELK stack
kubectl apply -f devops/k8s/elasticsearch.yaml
kubectl apply -f devops/k8s/logstash-configmap.yaml
kubectl apply -f devops/k8s/kibana.yaml

# Check deployment status
kubectl get pods -n ai-backend
```

### Access Services

```bash
# Port-forward backend
kubectl port-forward -n ai-backend svc/ai-backend 8080:8080

# Access Kibana dashboard
kubectl port-forward -n ai-backend svc/kibana 5601:5601
# Open http://localhost:5601
```

## 📊 Observability

The ELK stack provides comprehensive observability:

- **Elasticsearch**: Stores all application logs and metrics
- **Logstash**: Processes and transforms log data
- **Kibana**: Visualizes logs, creates dashboards, and enables log search

### View Logs in Kibana

1. Access Kibana at `http://localhost:5601`
2. Navigate to **Discover**
3. Create an index pattern: `logstash-*`
4. Query and filter logs from the terminal-ai backend

## 🔧 Development

### Makefile Commands

```bash
make build          # Build Go AI engine
make install        # Install CLI binary and adapters
make docker-build   # Build Docker images
make k8s-deploy     # Deploy to Kubernetes
make terraform      # Run Terraform apply
make test           # Run tests
make clean          # Clean build artifacts
```

### Testing Shell Adapters

```bash
# Test in clean Bash environment
bash --norc

# Test in clean Zsh environment
zsh -f

# Load adapter manually
source adapters/adapter.zsh
```

### Developing the AI Core

```bash
cd ai-core
go run engine.go "your test input"

# Run tests
go test ./...

# Build optimized binary
go build -ldflags="-s -w" -o terminal-ai-core engine.go
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎓 Educational Context

This project demonstrates proficiency in:

- **Go Development**: CLI tools and HTTP servers
- **Shell Scripting**: Cross-shell compatibility (Bash, Zsh, POSIX)
- **Containerization**: Docker multi-stage builds and image optimization
- **Orchestration**: Kubernetes deployments, services, and configmaps
- **Infrastructure as Code**: Terraform for reproducible infrastructure
- **Observability**: ELK stack integration and log aggregation
- **DevOps Best Practices**: CI/CD automation, clean architecture, separation of concerns

## 📞 Support

For questions or issues, please open an issue on GitHub.

---

**Built with ❤️ using Go, Kubernetes, and modern DevOps practices**
