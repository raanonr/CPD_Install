#!/bin/bash
#===============================================================================
# Raanon: mirror_appconnect.sh
# [PCR_HOST:PORT]
# On internet bastion, PCR argument to override PRIVATE_REGISTRY_LOCATION.
# Only run on airgapped if the images aren't already in the PRIVATE_REGISTRY_LOCATION.

export TEMP_PCR_LOC="$1"

cat <<EOCAT
On the internet bastion, this downloads the ibm-appconnect CASE file and then mirrors to the target registry.
On the airgapped bastion, only use this to copy from a temporary registry to the PRIVATE_REGISTRY_LOCATION.
SYNTAX: $0 [PCR_HOST:PORT]
EOCAT

if [[ $BASTION_TYPE == "internet" ]]; then
	export REGISTRY="${TEMP_PCR_LOC:-${PRIVATE_REGISTRY_LOCATION}}"
	unset  FINAL
	export MAPPING="images-mapping.txt"
else # airgapped
	export REGISTRY="${TEMP_PCR_LOC:?Missing}"
	export FINAL="--final-registry ${PRIVATE_REGISTRY_LOCATION}"
	export MAPPING="images-mapping-from-registry.txt"
fi

cat <<EOCAT
	AC_CASE_VERSION=$AC_CASE_VERSION
	Registry = ${REGISTRY}   ${FINAL}
	MAPPING = ${MAPPING}

EOCAT

read -p "Hit ENTER to continue... (Abort if something missing)" YN

#===============================================================================
# Login
if [[ $BASTION_TYPE == "internet" ]]; then
	$CPDM_ENTREG_LOGIN
else # airgapped
	$CPDM_PCR_LOGIN
fi

cpd-cli manage login-private-registry ${REGISTRY} ${PCR_PUSH_USER} ${PCR_PUSH_PASSWORD}

#cpd-cli manage login-private-registry ${PCR_LOCATION} ${PCR_PUSH_USER} ${PCR_PUSH_PASSWORD}
#[root@RaanonD-node-1 Scripts]# cpd-cli manage login-private-registry 127.0.0.1:5007 admin password


#===============================================================================
#cat <<EOF | podman exec --interactive olm-utils-v3 sh
#[[ ! -d ${IBMPAK_HOME}/.ibm-pak/data/cases/ibm-appconnect/${AC_CASE_VERSION} ]] && \

cat <<EOF | podman exec --interactive olm-utils-play-v3 bash
set -x
export IBMPAK_HOME="/tmp/work/offline/${VERSION}/"

[[ $BASTION_TYPE == internet ]] && \
	oc ibm-pak get ibm-appconnect \
	--version ${AC_CASE_VERSION} \
	--disable-top-level-images-mode

oc ibm-pak generate mirror-manifests ibm-appconnect ${REGISTRY} ${FINAL} \
--version ${AC_CASE_VERSION}

oc image mirror -f /tmp/work/offline/${VERSION}/.ibm-pak/data/mirror/ibm-appconnect/${AC_CASE_VERSION}/${MAPPING} \
--max-per-registry=1 \
--skip-multiple-scopes=true \
--continue-on-error=true \
--filter-by-os '.*' \
--insecure=true \
-a /opt/ansible/.airgap/secrets/config.json

set +x
EOF

#--dry-run=true \
# ADDED: --insecure=true \
