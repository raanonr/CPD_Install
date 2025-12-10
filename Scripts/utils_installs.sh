#!/bin/bash

DOWNLOAD=${WORKDIR}/Download
RPMS="False"

CPD_CLI_REL=14.1.1

# Assumed: podman
PACKAGES="jq htpasswd openssl trust update-ca-trust unzip tmux bc nc"

for pkg in $PACKAGES; do
	orig_pkg=$pkg
	which $pkg 2>/dev/null && continue
	which $pkg 2>/dev/null || echo "$pkg NOT FOUND"
	[[ $RPMS != "True" ]] && continue
	[[ $pkg == "htpasswd" ]] && pkg="httpd-tools"
	[[ $pkg == "trust" ]]    && pkg="p11-kit-trust"
	[[ $pkg == "update-ca-trust" ]] && continue ## pkg=???
	# TODO: verify rpm File.
	echo "$pkg ($orig_pkg)"
	if [[ -d $WORKDIR/Download/rpms/${pkg} ]]; then
		rpm -ivh $WORKDIR/Download/rpms/${pkg}/*.rpm
	fi
done

# Extract tools

set -x
[[ -f ${DOWNLOAD}/openshift-client-linux.tar.gz ]] && \
	tar -C ${WORKDIR}/bin -xf ${DOWNLOAD}/openshift-client-linux.tar.gz   oc && \
	chmod +x ${WORKDIR}/bin/oc

[[ -f ${DOWNLOAD}/oc-mirror.tar.gz ]] && \
	tar -C ${WORKDIR}/bin -xf ${DOWNLOAD}/oc-mirror.tar.gz   oc-mirror && \
	chmod +x ${WORKDIR}/bin/oc-mirror

#wget -P $DOWNLOAD "https://github.com/quay/mirror-registry/releases/download/v${OC_MIRROR_REL}/mirror-registry-offline.tar.gz"

[[ -f ${DOWNLOAD}/oc-ibm_pak-linux-amd64.tar.gz ]] && \
	tar -C ${WORKDIR}/bin -xf ${DOWNLOAD}/oc-ibm_pak-linux-amd64.tar.gz   oc-ibm_pak-linux-amd64 && \
	mv ${WORKDIR}/bin/oc-ibm_pak-linux-amd64 ${WORKDIR}/bin/oc-ibm_pak 2>/dev/null && \
	chmod +x ${WORKDIR}/bin/oc-ibm_pak

[[ -f ${DOWNLOAD}/cpd-cli-linux-EE-${CPD_CLI_REL}.tgz ]] && \
	tar -C ${WORKDIR} -xf ${DOWNLOAD}/cpd-cli-linux-EE-${CPD_CLI_REL}.tgz

set +x
