#!/bin/bash
#===============================================================================
# Raanon: create_private_registry.sh
# [--y] [--pcr <name> <port>]
# Pull and save a private registry image. NOTE: This NOW requires a license and is no longer allowed.
#   podman pull docker.io/library/registry:2.7
#   podman save docker.io/library/registry:2.7 -o Downloads/registry.tar
# This script will not overwrite anything if it already exists. To make the registry's container use (point to)
# a different location, perhaps to use a different version, just delete (rm) the container and run this script to
# re-create it with the new variable values.

# Allow optional arg --y to answer YES to all prompts
[[ $1 == "--y" ]] && shift && YES_ALL=Y
# Allow overriding defaults to create a partial PCR
if [[ $1 == "--pcr" ]]; then
	[[ $# < 3 ]] && \
		echo "With --pcr, provide a PCR_NAME and PCR_PORT to override the default! " && \
		exit
	export PCR_NAME="$2"
	export PCR_PORT="$3"
	shift && shift && shift
fi
[[ $# > 0 ]] && echo "Unknown arg: $*" && exit

export PCR_TAR="${WORKDIR}/Download/registry.tar"
export PCR_IMAGE="docker.io/library/registry:2.7"
export PCR_PORT="${PCR_PORT:-5005}"
export PCR_NAME="${PCR_NAME:-cpd-private-registry}"
export PCR_LOCATION="${PCR_HOST}:${PCR_PORT}"
#export PCR_CERTFILE="cpd_pcr_domain"
export PCR_CERTFILE="${PCR_NAME}"
export PCR_OFFLINE="${WORKDIR}/${PCR_NAME}"
export USE_SKOPEO=true

cat <<EOCAT
*** Create a Private Container Registry (PCR) ***
Syntax: $0 [--y] [--pcr <name> <port>]
	--y: Answers YES to all prompts
	--pcr: Override default PCR_NAME and PCR_PORT
*** Parameters used: ****
    WORKDIR=${WORKDIR}
    PCR_TAR=${PCR_TAR}
    PCR_IMAGE=${PCR_IMAGE}
    PCR_HOST=${PCR_HOST}
    PCR_PORT=${PCR_PORT}
    PCR_NAME=${PCR_NAME}
    PCR_OFFLINE=${PCR_OFFLINE}
    PCR_CERTFILE=${PCR_CERTFILE}
    PCR_LOCATION=${PCR_LOCATION}
    PCR_PUSH_USER=${PCR_PUSH_USER}
    PCR_PUSH_PASSWORD=${PCR_PUSH_PASSWORD}

EOCAT

[[ ! -f ${PCR_TAR} ]] && echo "${PCR_TAR} NOT Found!!!" && exit

[[ ${YES_ALL^^} != Y ]] && \
	read -p "Hit ENTER to continue... (Abort if something missing)" YN

cd $WORKDIR
export OFFLINE_REGISTRYDIR=${PCR_OFFLINE}/registry


#===============================================================================
[[ $(podman images ${PCR_IMAGE} -q) == "" ]] && \
	echo "Loading podman image: ${PCR_TAR}..." && \
	podman load -i ${PCR_TAR}

#===============================================================================
CREATE_DIR=Y
[[ -d ${PCR_OFFLINE} ]] && \
	echo "The ${PCR_OFFLINE} directory already exists!" && \
	[[ ${YES_ALL^^} != Y ]] && \
		read -p "Delete it and recreate [y/N]? " CREATE_DIR
if [[ ${CREATE_DIR^^} != Y ]]; then
	echo "Skipping re-creation of ${PCR_OFFLINE} directory"
else
	echo "Creating ${PCR_OFFLINE} direcotry..."
###	rm -fr ${PCR_OFFLINE}
	mkdir -p ${PCR_OFFLINE}/{cpd,cpfs,registry}
	mkdir -p ${OFFLINE_REGISTRYDIR}/{auth,certs,data}
fi
echo ""

#===============================================================================
CREATE_AUTH=Y
[[ -f ${OFFLINE_REGISTRYDIR}/certs/${PCR_CERTFILE}.crt ]] && \
	echo "Certificate file already exists!" && \
	[[ ${YES_ALL^^} != Y ]] && \
		read -p "Recreate [y/N]? " CREATE_AUTH
if [[ ${CREATE_AUTH^^} != Y ]]; then
	echo "Skipping creation of self-signed certificates, etc."
else
	echo "*** generate a self-signed certificate for the private registry ***"

	# Generate a username and password
	htpasswd -bBc ${OFFLINE_REGISTRYDIR}/auth/htpasswd ${PCR_PUSH_USER} ${PCR_PUSH_PASSWORD}

	# Generate a self-signed certificate
	openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${OFFLINE_REGISTRYDIR}/certs/${PCR_CERTFILE}.key -x509 -days 3650 -out ${OFFLINE_REGISTRYDIR}/certs/${PCR_CERTFILE}.crt -subj "/CN=${PCR_HOST}" -addext "subjectAltName=IP:${PCR_HOST}"
	echo ""
fi

# Always do this, just to be sure.
[[ -f /etc/pki/ca-trust/source/anchors/${PCR_CERTFILE}.crt ]] && \
	echo "Overwriting /etc/pki/ca-trust/source/anchors/${PCR_CERTFILE}.crt"
/usr/bin/cp -p ${OFFLINE_REGISTRYDIR}/certs/${PCR_CERTFILE}.crt /etc/pki/ca-trust/source/anchors/

update-ca-trust

echo "*** trust generated self-signed certificate ***"
trust list | grep -i ${PCR_HOST}
echo ""

#===============================================================================
CREATE_CONTAINER=Y
if podman ps -a | grep -q " ${PCR_NAME}$" ; then
	echo "Container ${PCR_NAME} already exists"
	podman start ${PCR_NAME} 2>/dev/null
	[[ ${YES_ALL^^} != Y ]] && \
		read -p "Recreate [y/N]? " CREATE_CONTAINER
	if [[ ${CREATE_CONTAINER^^} == Y ]]; then
		podman stop ${PCR_NAME} 2>/dev/null
		podman rm ${PCR_NAME}
	fi
fi
if [[ ${CREATE_CONTAINER^^} != Y ]]; then
	echo "Keeping existing private registry container"
else
	echo "*** start the private registry ***"
	set -x
	podman run --privileged --name ${PCR_NAME} \
		-p ${PCR_PORT}:5000 \
		-v ${OFFLINE_REGISTRYDIR}/data:/var/lib/registry:z \
		-v ${OFFLINE_REGISTRYDIR}/auth:/auth:z \
		-e "REGISTRY_AUTH=htpasswd" \
		-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
		-e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
		-v ${OFFLINE_REGISTRYDIR}/certs:/certs:z \
		-e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/${PCR_CERTFILE}.crt" \
		-e "REGISTRY_HTTP_TLS_KEY=/certs/${PCR_CERTFILE}.key" \
		-e "REGISTRY_STORAGE_DELETE_ENABLED=true" \
		-d ${PCR_IMAGE}
	set +x
fi
echo ""

#===============================================================================
printf "*** test login and query private registry ***\n\n"
sleep 3

echo "podman login --username ${PCR_PUSH_USER} --password ${PCR_PUSH_PASSWORD} ${PCR_LOCATION} --tls-verify=false"
podman login --username ${PCR_PUSH_USER} --password ${PCR_PUSH_PASSWORD} ${PCR_LOCATION} --tls-verify=false

echo "curl -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=6000 | jq -r ."
curl -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=6000 | jq -r .

exit 
###############

echo "*** test login and query private registry ***"
podman pull busybox
podman tag docker.io/library/busybox ${PCR_LOCATION}/zen/busybox
podman images | grep busybox

podman login --username ${PCR_PUSH_USER} --password ${PCR_PUSH_PASSWORD} ${PCR_LOCATION} --tls-verify=false
podman push ${PCR_LOCATION}/zen/busybox --tls-verify=false
echo ""

echo "*** retrieve testing pushed images ***"
curl -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=6000 | jq -r .
echo ""
curl -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/zen/busybox/tags/list | jq -r .
echo ""

