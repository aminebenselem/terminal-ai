# Multi-stage build for AI backend server
FROM golang:1.24.9-alpine AS builder

WORKDIR /build

# Copy Go module files
COPY ai-core/go.mod ai-core/go.sum* ./
RUN go mod download || true

# Copy source code
COPY ai-core/ ./

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-s -w" -o ai-backend .

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /build/ai-backend .

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run the application
CMD ["./ai-backend"]
