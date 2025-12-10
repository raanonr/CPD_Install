# Temporary file for commands - until saving the word document as text.

cpd-cli manage restart-container
cpd-cli manage save-image --from=${OLM_UTILS_IMAGE}
ll cpd-cli-workspace/olm-utils-workspace/work/offline/
ll $WORK/offline

cpd-cli manage case-download \
	--components=${COMPONENTS} \
	--release=${VERSION}

[root@RaanonD-node-1 CPD_5.1.1]# curl --output-dir ${WORKDIR}/Download -sSLO https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-appconnect/${AC_CASE_VERSION}/ibm-appconnect-${AC_CASE_VERSION}.tgz

-rw-r--r-- 1 root root 541737 Mar 20 01:31 ibm-appconnect-12.5.0.tgz

Scripts/create_private_registry.sh --y

cpd-cli manage list-images \
--components=${COMPONENTS} \
--release=${VERSION} \
--inspect_source_registry=true

### IGNORE ws_pipelines (x3)

cpd-cli manage mirror-images \
--components=ws_pipelines \
--release=${VERSION} \
--target_registry=${PRIVATE_REGISTRY_LOCATION} \
--arch=${IMAGE_ARCH} \
--case_download=false \
--groups=ibmwsprbsnossh

cpd-cli manage mirror-images \
--components=ws_pipelines \
--release=${VERSION} \
--target_registry=${PRIVATE_REGISTRY_LOCATION} \
--arch=${IMAGE_ARCH} \
--case_download=false \
--groups=ibmwsppython

cpd-cli manage mirror-images \
--components=ws_pipelines \
--release=${VERSION} \
--target_registry=${PRIVATE_REGISTRY_LOCATION} \
--arch=${IMAGE_ARCH} \
--case_download=false \
--groups=ibmwsprbsnossh,ibmwsppython

