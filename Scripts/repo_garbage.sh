#!/bin/bash
#===============================================================================
# Raanon: repo_garbage.sh

# podman stop ${PCR_NAME}
# rm -fr ${WORKDIR}/${PCR_NAME}/registry/data/docker/registry/v2/repositories/cp/cpd/llama-3-2-3b-instruct

podman start ${PCR_NAME}
podman exec -it ${PCR_NAME} bin/registry garbage-collect /etc/docker/registry/config.yml 1>/dev/null
