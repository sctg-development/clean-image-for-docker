# Clean Runner for Docker Builds

This action cleans unnecessary packages and files from GitHub runners to optimize disk space for Docker multi-architecture builds.

## Features

- Removes large unnecessary packages and tools that are not needed for Docker builds
  - Development tools (compilers, runtimes, build systems)
  - Browser packages and WebDriver tools
  - Database packages (MySQL, PostgreSQL, MongoDB)
  - Cloud tools (Azure CLI, Google Cloud SDK, AWS CLI, etc.)
  - Testing and analysis tools
  - Documentation tools
  - Android SDK and NDK
  - Cached tool versions
- Cleans up package manager cache
- Removes large directories
- Reports disk space saved before and after cleanup
- Fully configurable cleanup options

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `remove-development-tools` | Remove compilers and runtimes (Java, Go, Rust, Haskell, etc.) | `true` |
| `remove-browsers` | Remove browsers and WebDriver tools (Chrome, Firefox, Edge) | `true` |
| `remove-databases` | Remove database packages (MySQL, PostgreSQL, MongoDB) | `true` |
| `remove-cloud-tools` | Remove cloud CLIs and tools | `true` |
| `remove-testing-tools` | Remove testing and analysis tools (newman, packer, yamllint, etc.) | `true` |
| `remove-documentation` | Remove documentation tools (sphinx, texinfo, emoji fonts) | `true` |
| `remove-android` | Remove Android SDK and NDK | `true` |
| `remove-cached-tools` | Remove cached tool versions (Go, Node.js, Python, Ruby) | `true` |
| `show-top-packages` | Show the largest packages before and after cleanup | `true` |

## Outputs

| Output | Description |
|--------|-------------|
| `space-before` | Available disk space before cleaning (in GB) |
| `space-after` | Available disk space after cleaning (in GB) |
| `space-saved` | Disk space saved by cleaning (in GB) |

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Clean runner for Docker builds
        uses: sctg-development/clean-image-for-docker@v2
        # Optional parameters (all default to true)
        with:
          remove-development-tools: 'true'
          remove-browsers: 'true'
          remove-databases: 'true'
          remove-cloud-tools: 'true'
          remove-testing-tools: 'true'
          remove-documentation: 'true'
          remove-android: 'true'
          remove-cached-tools: 'true'
          show-top-packages: 'true'
          relocate-docker-storage: 'true'
          
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

## Example: Selective Cleanup

If you want to keep some tools (for example, keep Java but remove everything else):

```yaml
- name: Clean runner for Docker builds (keep Java)
  uses: sctg-development/clean-image-for-docker@v2
  with:
    remove-development-tools: 'false'  # Keeps Java, Go, Rust, etc.
    remove-browsers: 'true'
    remove-databases: 'true'
    remove-cloud-tools: 'true'
    remove-testing-tools: 'true'
    remove-documentation: 'true'
    remove-android: 'true'
    remove-cached-tools: 'true'
```

## Packages Removed by Category

### Development Tools (remove-development-tools)
- Compilers: GCC, Clang, LLVM, Gfortran
- Runtimes: Java (OpenJDK, Temurin), Golang, Rust, Haskell, Julia, Kotlin, Swift
- Build systems: Maven, Gradle, Ant, Bazel, CMake, Ninja
- Other: Mono, Ruby (gruby)

### Browsers (remove-browsers)
- Google Chrome
- Mozilla Firefox
- Microsoft Edge

### Databases (remove-databases)
- MySQL
- PostgreSQL
- MongoDB

### Cloud Tools (remove-cloud-tools)
- Azure CLI
- Google Cloud SDK
- AWS CLI and SAM CLI
- AzCopy
- Bicep
- Pulumi

### Testing Tools (remove-testing-tools)
- Newman
- Packer
- Yamllint
- Shellcheck
- Xvfb

### Documentation (remove-documentation)
- Sphinx
- Texinfo
- Emoji fonts
- MediaInfo

### Android (remove-android)
- Android SDK
- Android NDK

### Cached Tools (remove-cached-tools)
- Cached Go versions
- Cached Node.js versions
- Cached Python versions
- Cached PyPy versions
- Cached Ruby versions

## Typical Disk Space Savings

On Ubuntu 24.04, typical disk space savings with default settings:
- **Before**: ~23-25 GB available
- **After**: ~35-40+ GB available
- **Saved**: ~12-17 GB

## License

MIT License - See [LICENSE.md](LICENSE.md)
