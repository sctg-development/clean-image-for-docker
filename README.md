# Clean Runner for Docker Builds

This action cleans unnecessary packages and files from GitHub runners to optimize disk space for Docker multi-architecture builds.

## Features

- Removes large unnecessary packages and tools that are not needed for Docker builds
- Cleans up package manager cache
- Removes large directories
- Reports disk space saved before and after cleanup
- Configurable cleanup options

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Clean runner for Docker builds
        uses: sctg-development/clean-image-for-docker@v1
        # Optional parameters
        with:
          remove-development-tools: 'true'
          remove-browsers: 'true'
          remove-databases: 'true'
          remove-cloud-tools: 'true'
          show-top-packages: 'true'
          
      - name: Check out the repo
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
        with:
          platforms: "arm64"

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        continue-on-error: true
        with:
          platforms: linux/arm64, linux/amd64
          cache-from: type=gha
          cache-to: type=gha
          push: true
          tags: mydocker/myimage:1.0, mydocker/myimage:latest
```
