# Task 1: Local Application Setup

**Objective**: Initialize the Go module and create the application source code.

## 1.1 Initialize Module

```bash
go mod init github.com/yourorg/myapp
mkdir -p cmd/api internal/handlers internal/health pkg
```

## 1.2 Application Code (`cmd/api/main.go`)

Create the main application entry point with graceful shutdown and version injection.

<details>
<summary>Click to see code</summary>

```go
package main
// ... (content from guide)
```

</details>

## 1.3 Build System (`Makefile`)

Create a Makefile to standardize build, test, and versioning commands.

## 1.4 Local Testing

- Run `make build`
- Run `./bin/myapp -version`
