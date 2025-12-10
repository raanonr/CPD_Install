#!/bin/bash
#===============================================================================
# Raanon: repo_save_model.sh
# To load on target:
# podman load -i $SAVE_DIR/repo-image_multilingual-e5-large_5.1.0-202411012253.tar
# $PCR_LOGIN
# podman push --tls-verify=false 127.0.0.1:5005/cp/cpd/multilingual-e5-large:5.1.0-202411012253
# podman push --tls-verify=false ${PCR_LOCATION}/${MODEL_REPO}/${MODEL_NAME}:${MODEL_VERSION}


[[ $# -lt 1 ]] && echo "$0 [--rmi] <model_name> [version/tag]"
[[ $1 == "--rmi" ]] && RMIMAGE=Y && shift
MODEL_NAME="$1"
MODEL_VERSION="${2:-latest}"
MODEL_REPO="cp/cpd"
MODEL_SAVE="${SAVE_DIR:?Undefined}/repo-image_${MODEL_NAME}_${MODEL_VERSION}.tar"
MODEL_DIR="${WORKDIR}/${PCR_NAME:?Undefined}/registry/data/docker/registry/v2/repositories/${MODEL_REPO}/${MODEL_NAME}"
[[ ! -d ${SAVE_DIR} ]] && echo "SAVE_DIR not found: ${SAVE_DIR}" && exit

${WORKDIR}/Scripts/repo_sizes.sh ${MODEL_REPO}/${MODEL_NAME}
echo ""
#printf "\ndu -sm ${MODEL_SAVE} ${MODEL_DIR}\n"
#du -sm ${MODEL_SAVE} ${MODEL_DIR}
#exit

# Lookup model in private registry
REGISTRY_URL="https://${PCR_LOCATION}/v2"
ARGS="-sS"
AUTH="-k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD}"
HEADER="Accept: application/vnd.docker.distribution.manifest.v2+json"
#tags=$(curl ${ARGS} ${AUTH} "${REGISTRY_URL}/${MODEL_REPO}/${MODEL_NAME}/tags/list" | jq -r '.tags')
#echo $tags
manifest=$(curl ${ARGS} ${AUTH} -H "${HEADER}" "${REGISTRY_URL}/${MODEL_REPO}/${MODEL_NAME}/manifests/${MODEL_VERSION}")
#echo $manifest
[[ $manifest =~ MANIFEST_UNKNOWN ]] && echo "${MODEL_REPO}/${MODEL_NAME}:${MODEL_VERSION}  not found!" && exit

# Pull to local podman images
$PCR_LOGIN
podman pull --tls-verify=false ${PCR_LOCATION}/${MODEL_REPO}/${MODEL_NAME}:${MODEL_VERSION}
echo ""
[[ $? != 0 ]] && exit
podman images | egrep "REPOSITORY|${MODEL_NAME}"

# Save image to tar file
printf "\nSave image to ${MODEL_SAVE}...\n"
[[ -f ${MODEL_SAVE} ]] && \
	echo "Already exists!" && \
	rm -i ${MODEL_SAVE}
[[ ! -f ${MODEL_SAVE} ]] && \
	podman save -o ${MODEL_SAVE} ${PCR_LOCATION}/${MODEL_REPO}/${MODEL_NAME}:${MODEL_VERSION}
printf "\ndu -sm ${MODEL_SAVE} ${MODEL_DIR}\n"
du -sm ${MODEL_SAVE} ${MODEL_DIR}
echo ""

# Remove model from local podman images
yn=""
[[ ${RMIMAGE^^} != Y ]] && read -p "Remove image (podman rmi) [y/N]? " yn
[[ ${RMIMAGE^^} == Y || ${yn^^} == Y ]] && echo "Removing image (podman rmi)..." \
	podman rmi ${PCR_LOCATION}/${MODEL_REPO}/${MODEL_NAME}:${MODEL_VERSION}

