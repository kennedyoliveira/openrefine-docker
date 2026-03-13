# OpenRefine Docker

Docker images for [OpenRefine](https://github.com/OpenRefine/OpenRefine) - a powerful free tool for working with messy data: cleaning it, transforming it from one format to another, extending it with web services, and linking it to databases.

## Purpose

This repository automatically builds and pushes Docker images whenever a new OpenRefine release is published. The images are built for multiple architectures (x64 and ARM) and pushed to both Docker Hub and GitHub Container Registry.

## Features

- **Multi-platform**: Builds for `linux/amd64` and `linux/arm64`
- **Automatic updates**: Monitors OpenRefine GitHub releases daily
- **Manual trigger**: You can manually trigger a build for a specific version
- **Latest tag**: Both `latest` and version-specific tags are pushed

## Image Tags

| Tag      | Description                |
| -------- | -------------------------- |
| `latest` | Most recent stable release |
| `3.10.1` | Specific version           |
| `3.10.0` | Specific version           |

## Usage

```bash
# Pull from Docker Hub
docker pull kennedyoliveira/openrefine:latest

# Run OpenRefine (REQUIRED: mount a volume to persist data)
docker run -p 3333:3333 -v ./data:/data kennedyoliveira/openrefine:latest
```

### With Docker Compose (Recommended)

```yaml
version: '3.8'
services:
  openrefine:
    image: kennedyoliveira/openrefine:latest
    ports:
      - "3333:3333"
    volumes:
      - ./data:/data
```

> **Important**: You must mount a volume to `/data` to persist your OpenRefine projects. Without this, all data will be lost when the container is removed.

## Workflows

### Check Release (`check-release.yml`)
Runs daily to check for new OpenRefine releases. If a new version is found, it triggers the build workflow.

### Build and Push (`build-push.yml`)
Builds the Docker image for multiple architectures and pushes to:
- GitHub Container Registry (`ghcr.io/`)
- Docker Hub (`kennedyoliveira/openrefine`)

Can be triggered manually with a specific version:
```bash
gh workflow run build-push.yml -f version=3.10.1
```

## Building Locally

### Build Arguments

| Argument                  | Description                                  | Default                     |
| ------------------------- | -------------------------------------------- | --------------------------- |
| `OPENREFINE_VERSION`      | OpenRefine version to build (e.g., `3.10.1`) | (required)                  |
| `OPENREFINE_DOWNLOAD_URL` | Override the download URL                    | Auto-generated from version |

```bash
# Build specific version
docker build --build-arg OPENREFINE_VERSION=3.10.1 -t openrefine:3.10.1 .

# Build with custom download URL
docker build --build-arg OPENREFINE_VERSION=3.10.1 \
  --build-arg OPENREFINE_DOWNLOAD_URL=https://example.com/custom.tar.gz \
  -t openrefine:custom .
```

### Environment Variables

These can be set when running the container:

| Variable            | Description                  | Default  |
| ------------------- | ---------------------------- | -------- |
| `JAVA_TOOL_OPTIONS` | JVM options (e.g., `-Xmx4G`) | `-Xmx2G` |

```bash
# Run with more memory
docker run -p 3333:3333 -v ./data:/data \
  -e JAVA_TOOL_OPTIONS="-Xmx4G" \
  kennedyoliveira/openrefine:latest
```

## License

This project is not affiliated with OpenRefine. Docker images are built from OpenRefine's official releases.
