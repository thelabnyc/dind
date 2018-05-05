# Docker-in-Docker

Docker image based on [ubuntu](https://hub.docker.com/_/ubuntu/) which includes python, common python utilities (pip, ipython, pytz, flake8), docker, docker-compose, and git pre-installed. Mainly designed to be used as a runner image in Gitlab CI, when building, testing, and deploying other docker-based services.

## Usage

Using docker inside this image requires the docker daemon to be running elsewhere. This can be accomplished by including the Docker daemon service inside your `.gitlab-ci.yml` file:

```yaml
variables:
  DOCKER_DRIVER: overlay2
  DOCKER_HOST: tcp://docker:2375

services:
  - docker:dind

test:
  script:
    - docker run hello-world
```

You can also accomplish the same thing without the (rather slow)docker-in-docker service by having Gitlab CI runner mount the runner host's Docker socket inside the test container. This can be done by including the following configuration inside the Gitlab CI runner's config.toml file.

```toml
[runners.docker]
    image = "thelab/dind:latest"
    privileged = false
    volumes = [
        "/var/run/docker.sock:/var/run/docker.sock",
    ]
```

This method has definite security implications. For example, it gives the dind container full access to the host machines docker daemon and, therefore, any other docker containers running on the host. But, if your CI runner only runs jobs from trusted authors and your security model allows for it, this option is significantly faster than the docker-in-docker service option.
