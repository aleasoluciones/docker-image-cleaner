# =============================================================================
# Variables
# =============================================================================
GO_VERSION     := 1.25.14
BINARY_NAME    := docker-image-cleaner
PACKAGE_NAME   := bifer-docker-image-cleaner

# Timestamp version (recalculated each time)
VERSION        := $(shell date -u +%Y%m%d%H%M%S)
CWD            := $(shell pwd)
CONTAINER_ROOT := /go/src/docker-image-cleaner

# Debian repository upload
REPOS_SERVER   := deb.alea-soluciones.com
REPOS_PORT     := 6922
REPOS_USER     := asur
REPO_NAME      := bos-repo
REPO_BINARY_DIR := /dataraid/debrepo/$(REPO_NAME)/binary

# =============================================================================
# Phony targets
# =============================================================================
.PHONY: help check compile package test_package package-deb-upload clean

# =============================================================================
# Help
# =============================================================================
help:
	@echo "Docker Image Cleaner Build System"
	@echo "=================================="
	@echo ""
	@echo "Available targets:"
	@echo "  check          - Run linters (fmt, vet, staticcheck)"
	@echo "  compile        - Build binary (depends on check)"
	@echo "  package        - Create .deb package (depends on compile)"
	@echo "  test_package   - Test .deb installation"
	@echo "  package-deb-upload - Upload local .deb to $(REPO_NAME) on $(REPOS_SERVER)"
	@echo "  clean          - Remove build artifacts"
	@echo ""
	@echo "Variables:"
	@echo "  GO_VERSION     - Go version (default: $(GO_VERSION))"
	@echo "  VERSION        - Package version (default: timestamp)"

# =============================================================================
# Code quality checks
# =============================================================================
check: $(BINARY_NAME).go go.mod go.sum
	sudo docker run --rm -v $(CWD):$(CONTAINER_ROOT) -w $(CONTAINER_ROOT) \
		golang:$(GO_VERSION) bash -c '\
		go fmt $(BINARY_NAME).go && \
		go vet $(BINARY_NAME).go && \
		go install honnef.co/go/tools/cmd/staticcheck@2025.1.1 && \
		staticcheck $(BINARY_NAME).go'

# =============================================================================
# Compile - depends on check to avoid duplicate work
# =============================================================================
compile: check
	sudo docker run --rm -v $(CWD):$(CONTAINER_ROOT) -w $(CONTAINER_ROOT) \
		golang:$(GO_VERSION) bash -c '\
		go mod tidy && \
		CGO_ENABLED=0 go build -ldflags="-s -w" -o $(BINARY_NAME) $(BINARY_NAME).go'

# =============================================================================
# Package (deb)
# =============================================================================
package: compile
	sudo docker build --build-arg GO_VERSION=$(GO_VERSION) --build-arg VERSION=$(VERSION) -o . .

# =============================================================================
# Test package installation
# =============================================================================
test_package: package
	sudo docker run --rm -v $(CWD):/stuff:ro debian:bookworm-slim \
		bash -c 'dpkg -i /stuff/$(PACKAGE_NAME)_*.deb'

# =============================================================================
# Upload .deb to the Debian repository (run from local machine)
# =============================================================================
package-deb-upload:
	@ls $(PACKAGE_NAME)_*.deb >/dev/null 2>&1 || { echo "No $(PACKAGE_NAME)_*.deb found. Run 'make package' first."; exit 1; }
	scp -P$(REPOS_PORT) $(PACKAGE_NAME)_*.deb $(REPOS_USER)@$(REPOS_SERVER):/home/$(REPOS_USER)/
	ssh -p$(REPOS_PORT) $(REPOS_USER)@$(REPOS_SERVER) "sudo mv /home/$(REPOS_USER)/$(PACKAGE_NAME)_*.deb $(REPO_BINARY_DIR)/"
	ssh -p$(REPOS_PORT) $(REPOS_USER)@$(REPOS_SERVER) "sudo chown root:root $(REPO_BINARY_DIR)/$(PACKAGE_NAME)_*.deb"
	ssh -p$(REPOS_PORT) $(REPOS_USER)@$(REPOS_SERVER) "sudo /usr/sbin/repo2old $(REPO_NAME)"

# =============================================================================
# Clean
# =============================================================================
clean:
	rm -f $(BINARY_NAME) $(PACKAGE_NAME)_*.deb