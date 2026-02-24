# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repo builds a **Docker-in-Docker (dind)** image based on Ubuntu. The image bundles Python 3, common Python utilities, Docker (client + daemon), Docker Compose plugin, and Git. It is primarily used as a GitLab CI runner image for building, testing, and deploying other Docker-based services.

## Build

```bash
# Local build (reads defaults from .env)
make build
# — or equivalently —
./bin/build.sh
```

`bin/build.sh` loads variables from `.env`, then runs `docker build`. Key build args: `BASE_IMAGE`, `UBUNTU_VERSION`, `DOCKER_VERSION`, `OUTPUT_TAG_NAME`. In CI these are set by the `.gitlab-ci.yml` matrix; locally they come from `.env`.

## CI/CD

GitLab CI (`.gitlab-ci.yml`) builds two matrix variants:
- **Ubuntu 22.04** with Docker 24.x
- **Ubuntu 24.04** with Docker 27.x (tagged as `latest`)

On the default branch, images are pushed to both the GitLab registry and Docker Hub (`thelab/dind`). MR builds get a `-mr<IID>` tag suffix.

## Dependency Management

- **Renovate** auto-updates base image digests via a custom regex manager (see `renovate.json`). Major Ubuntu version bumps are disabled.
- Docker image references in `.gitlab-ci.yml` and `Dockerfile` use pinned `sha256` digests.

## Pre-commit Hooks

Configured in `.pre-commit-config.yaml`: copyright year update, JSON/YAML/TOML validation, merge-conflict detection, trailing whitespace, and end-of-file fixer.
