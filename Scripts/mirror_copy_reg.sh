#!/bin/bash
#===============================================================================
# Raanon: copy_registry.sh
# [COMPONENTS] [Source-PCR_NAME:PORT]

export COMPONENTS="${1:-$COMPONENTS}"
export SRC_PCR_LOCATION="${2:-127.0.0.1:5006}"

cat <<EOCAT
	COMPONENTS=$COMPONENTS
	Source Registry: ${SRC_PCR_LOCATION}
	Target Registry: ${PRIVATE_REGISTRY_LOCATION}
EOCAT

read -p "Hit ENTER to continue... (Abort if something missing)" YN

set -x
cpd-cli manage mirror-images \
--components=${COMPONENTS} \
--release=${VERSION} \
--source_registry=${SRC_PCR_LOCATION} \
--target_registry=${PRIVATE_REGISTRY_LOCATION} \
--arch=${IMAGE_ARCH} \
--case_download=false
set +x
