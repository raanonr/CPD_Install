#!/bin/bash

DOWNLOAD=${WORKDIR}/Download
RPMS="False"

#OCP_RELEASE=4.16.34
OCP_RELEASE=4.17.9
OC_MIRROR_REL=2.0.3
#OC_MIRROR_REL=2.05 # Pre-release
#IBM_PAK_REL=1.16.2
IBM_PAK_REL=1.17.0
CPD_CLI_REL=14.1.1

# Assumed: podman tar
PACKAGES="jq htpasswd openssl trust update-ca-trust unzip tmux bc nc"

# Install yum-utils
#which yumdownloader 2>/dev/null || yum install -y yum-utils
which yumdownloader 2>/dev/null || echo yum install -y yum-utils

for pkg in $PACKAGES; do
	orig_pkg=$pkg
	which $pkg 2>/dev/null || echo "$pkg NOT FOUND"
	[[ $RPMS != "True" ]] && continue
	[[ $pkg == "htpasswd" ]] && pkg="httpd-tools"
	[[ $pkg == "trust" ]]    && pkg="p11-kit-trust"
	[[ $pkg == "update-ca-trust" ]] && continue ## pkg=???
	echo "$pkg ($orig_pkg)"
	if [[ ! -d $WORKDIR/Download/rpms/${pkg} ]]; then
		# Create necessary directories
		mkdir -p $WORKDIR/Download/rpms/${pkg}
		# Download packages
		yumdownloader $pkg --resolve --destdir="$WORKDIR/Download/rpms/${pkg}"
	fi
done

# Download tools

## curl -k "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$OCP_RELEASE/openshift-install-linux.tar.gz" | tar -xz -C "$LOCAL_PATH/tools/openshift" openshift-install

#https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.17.9/openshift-client-linux.tar.gz
#https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.17.9/oc-mirror.tar.gz
#https://github.com/IBM/ibm-pak/releases/download/v1.17.0/oc-ibm_pak-linux-amd64.tar.gz

set -x
OCP_OPTIONAL=Y
if [[ $OCP_OPTIONAL == Y ]]; then
  wget -P $DOWNLOAD "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/openshift-client-linux.tar.gz"
  wget -P $DOWNLOAD "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/oc-mirror.tar.gz"
  wget -P $DOWNLOAD "https://github.com/quay/mirror-registry/releases/download/v${OC_MIRROR_REL}/mirror-registry-offline.tar.gz"
  #curl -k --output-dir $DOWNLOAD -O "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/openshift-client-linux.tar.gz"
  #curl -k --output-dir $DOWNLOAD -O "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/oc-mirror.tar.gz"
  #curl -Lk --output-dir $DOWNLOAD -O "https://github.com/quay/mirror-registry/releases/download/v${OC_MIRROR_REL}/mirror-registry-offline.tar.gz"
fi

wget -P $DOWNLOAD "https://github.com/IBM/ibm-pak/releases/download/v${IBM_PAK_REL}/oc-ibm_pak-linux-amd64.tar.gz"
#curl -Lk --output-dir $DOWNLOAD -O "https://github.com/IBM/ibm-pak/releases/download/v${IBM_PAK_REL}/oc-ibm_pak-linux-amd64.tar.gz"
wget -P $DOWNLOAD "https://github.com/IBM/cpd-cli/releases/download/v${CPD_CLI_REL}/cpd-cli-linux-EE-${CPD_CLI_REL}.tgz"

curl --output-dir ${DOWNLOAD} -sSLO "https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-appconnect/${AC_CASE_VERSION}/ibm-appconnect-${AC_CASE_VERSION}.tgz"

set +x
