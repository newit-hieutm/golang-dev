.PHONY: help build test run clean version

# Get version from git
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.0.0-dev")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')

# Build flags
LDFLAGS := -ldflags "\
	-X main.Version=$(VERSION) \
	-X main.Commit=$(COMMIT) \
	-X main.BuildTime=$(BUILD_TIME) \
	-s -w"

help:
	@echo "Available targets:"
	@echo "  make build       - Build the application"
	@echo "  make test        - Run tests"
	@echo "  make run         - Run the application"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make version     - Show version information"

build:
	@echo "Building version $(VERSION)..."
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o bin/myapp cmd/api/main.go
	@echo "Build complete: bin/myapp"

build-local:
	@echo "Building for local platform..."
	go build $(LDFLAGS) -o bin/myapp cmd/api/main.go
	@echo "Build complete: bin/myapp"

test:
	@echo "Running tests..."
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out

run:
	go run cmd/api/main.go

clean:
	rm -rf bin/
	rm -f coverage.out

version:
	@echo "Version: $(VERSION)"
	@echo "Commit: $(COMMIT)"
	@echo "Build Time: $(BUILD_TIME)"
