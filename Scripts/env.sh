#!/bin/bash
#===============================================================================
## Raanon: env.sh

## set BASTION_TYPE="<internet|airgapped>" or pass as optional argument
export BASTION_TYPE="${1:-airgapped}"
[[ ! ${BASTION_TYPE} =~ internet|airgapped ]] && echo "Error: Set BASTION_TYPE or pass <internet|airgapped>" && return

## Setup WORKDIR environment.
export WORKDIR="$(readlink -f $(dirname "${BASH_SOURCE[0]}"))"
export WORKDIR="${WORKDIR/\/Scripts/}"
export CPD_CLI_PATH="$(ls -d ${WORKDIR}/cpd-cli-linux* | tail -1)" # This may fail the first time run, before installing...

export SAVE_DIR="${WORKDIR}_Save"
export SEND_DIR="${WORKDIR}_ToSend"

mkdir -p ${WORKDIR}/{Scripts,Download,bin}
mkdir -p ${WORKDIR}/{Bak,Out,Yaml}

## Append to the PATH.
[[ ! $PATH =~ ${WORKDIR}/bin ]] && export PATH=${WORKDIR}/bin:${WORKDIR}/Scripts:${PATH}
[[ -n ${CPD_CLI_PATH} && ! $PATH =~ ${CPD_CLI_PATH} ]] && export PATH=${CPD_CLI_PATH}:${PATH}

## Unset (clean) all variables.
source ${WORKDIR}/Scripts/cpd_vars_clean.sh

#===============================================================================
## EDIT THIS ## Define variables which are use-case specific for a customer
## LLM Models
## Note: --groups is a comma seperated list (no spaces) of foundation model groups as they appear in both of these sites:
## https://www.ibm.com/docs/en/software-hub/5.1.x?topic=registry-mirroring-images-directly-private-container
## https://www.ibm.com/docs/en/software-hub/5.1.x?topic=install-foundation-models
export MODEL_GROUPS="ibmwxMultilingualE5Large\
,ibmwxLlama3170bInstruct\
"
#,ibmwxLlama3370BInstruct\
#,ibmwxLlama3211bVisionInstruct\
#export MODEL_REPOS=$(printf "cp/cpd/%s " \
#	multilingual-e5-large \
#	llama-3-1-70b-instruct-part1 \
#	llama-3-1-70b-instruct-part2 \
#	llama-3-1-70b-instruct-part3 \
#	llama-3-1-70b-instruct-part4 
#)
#	llama-3-2-11b-vision-instruct \
#	llama-3-2-1b-instruct \
#	llama-3-2-3b-instruct

#===============================================================================
## EDIT THIS ## Define variables which are use-case specific for a customer
## For multiple iterations with different COMPONENTS, use multiple workspaces and/or multiple private registries (PCR)
## (If using an Intermediate Registry, use multiple workspaces.)
## Decide how to set COMPONENTS.
#===============================================================================
#export COMPONENTS_ADD=""
###export COMPONENTS_ADD=watsonx_ai,watsonx_orchestrate,watsonx_data
#export COMPONENTS_ADD=watsonx_ai,watsonx_orchestrate
export COMPONENTS_ADD=watsonx_ai
#export COMPONENTS_ADD=watsonx_orchestrate
#export COMPONENTS_ADD=watsonx_data
# Uncomment the next line to ONLY install COMPONENTS_ADD, and NOT append it to the base CPD components
export COMPONENTS="${COMPONENTS_ADD}"
# Uncomment the next line to ONLY mirror the components and NOT the watsonx_ai_ifm component with MODEL_GROUPS.
#unset MODEL_GROUPS

export WORKSPACE=${WORKDIR}/cpd-cli-workspace
#export WORKSPACE=${WORKDIR}/cpd-cli-workspace-xai
#export WORKSPACE=${WORKDIR}/cpd-cli-workspace-xorch
#export WORKSPACE=${WORKDIR}/cpd-cli-workspace-xdata

# Private Container Registry
#export PCR_PORT="5000" && export PCR_NAME="pcr-openshift"
###export PCR_PORT="5005" && export PCR_NAME="cpd-private-registry"
#export PCR_PORT="5005" && export PCR_NAME="pcr-cpd-base"
#export PCR_PORT="5006" && export PCR_NAME="cpd-priv-reg-xdata"
#export PCR_PORT="5007" && export PCR_NAME="cpd-reg-appconnect"
#export PCR_PORT="5008" && export PCR_NAME="pcr-watsonx-ai"
#export PCR_PORT="5009" && export PCR_NAME="pcr-watsonx-orch"
export PCR_PORT="5010" && export PCR_NAME="pcr-wx-ai-fm"

export VERSION=5.1.1
export CPD_CLI_MANAGE_WORKSPACE=${WORKSPACE}/olm-utils-workspace
export WORK="${CPD_CLI_MANAGE_WORKSPACE}/work"
export OLM_UTILS_IMAGE="icr.io/cpopen/cpd/olm-utils-v3:${VERSION}"
export OLM_UTILS_LAUNCH_ARGS=" --network=host"

#===============================================================================
## Private Container Registry (PCR) variables
#export PCR_HOST="$(hostname -f)"
export PCR_HOST="127.0.0.1"
export PCR_HOST_EXTERNAL="159.122.90.43"
export PCR_LOCATION="${PCR_HOST}:${PCR_PORT}"
export PCR_PUSH_USER="admin"
export PCR_PUSH_PASSWORD="password"
export PCR_PULL_USER="admin"
export PCR_PULL_PASSWORD="password"
# HIDE: export PCR_PUSH_USER="ZZZZZ"
# HIDE: export PCR_PUSH_PASSWORD="ZZZZZ"
# HIDE: export PCR_PULL_USER="ZZZZZ"
# HIDE: export PCR_PULL_PASSWORD="ZZZZZ"

export PCR_LOGIN="eval podman login \${PCR_LOCATION} -u \${PCR_PUSH_USER} -p \${PCR_PUSH_PASSWORD} --tls-verify=false"
export CPDM_PCR_LOGIN="eval cpd-cli manage login-private-registry \
					\${PCR_LOCATION} \${PCR_PUSH_USER} \${PCR_PUSH_PASSWORD}"

#===============================================================================
## Define variables which are not included in the cpd_vars template script or are private (URLs, passwords, etc.)
## Then call the appropriate cpd_vars_ script.
if [[ ${BASTION_TYPE} == "internet" ]]; then

	# MY_IBM_ENTITLEMENT_KEY must be defined(!), but elsewhere (~/.bashrc)
	export IBM_ENTITLEMENT_KEY="${MY_IBM_ENTITLEMENT_KEY:?Undefined\!}"
	export CPDM_ENTREG_LOGIN="eval cpd-cli manage login-entitled-registry \${IBM_ENTITLEMENT_KEY}"

	source ${WORKDIR}/Scripts/cpd_vars_internet.sh

#===============================================================================
else    # ${BASTION_TYPE} == "airgapped" 

	## To make sure that external sites are not accessed, add the following to /etc/hosts
	## 127.0.0.1    github.com icr.io cp.icr.io # Cut off access to simulate air-gapped
	## 127.0.0.1    cdn.redhat.com subscription.rhn.redhat.com registry.access.redhat.com registry.redhat.io quay.io

	## Set KUBECONFIG if you have it.
	export KUBECONFIG=${WORKDIR}/ocp-20250427_conf_kubeconfig_download.conf

	## OCP variables
	export OCP_URL="api.680de5ed519c003021b2e718.eu1.techzone.ibm.com:6443"
	export OCP_USERNAME="kubeadmin"
	export OCP_PASSWORD="g9YL3-5CANr-3kbaE-Ts56H"
	#export OCP_URL="c115-e.eu-de.containers.cloud.ibm.com:30257"
	#export OCP_TOKEN="${MY_OCP_TOKEN:-sha256~uHf96qcTATm_I2PC8eA9ohec9ddSwCK_3i8tZZudPlQ}"
	# HIDE: export OCP_URL="api.ZZZZZZZZZ.techzone.ibm.com:ZZZZ"
	# HIDE: export OCP_USERNAME="ZZZZZZZZZ"
	# HIDE: export OCP_PASSWORD="ZZZZZZZZZZZZZZZZZZ"
	# HIDE: export OCP_TOKEN="ZZZZZZZZZ"
	# export LOGIN_ARGUMENTS="--username=${OCP_USERNAME} --password=${OCP_PASSWORD}"
	export LOGIN_ARGUMENTS="--token=${OCP_TOKEN}"

	## These are needed to create a cpd-cli profile, which is needed to manage instances (wd) and users.
#	export CPD_ADMIN_USER=cpadmin
#	export CPD_LOCAL_USER="cpdcli_admin"
#	export CPD_PROFILE_NAME="cpdcli_admin_profile"

	## These are needed to create the Watson Discovery instance.
#	export INSTANCE_NAME="watson_discovery_1"
#	export INSTANCE_VERSION="5.0.0"
#	export PAYLOAD_FILE=${WORKDIR}/Yaml/discovery-instance.json
	# export BACKING_STORE=noobaa-default-backing-store
	# export ACCOUNT_NAME=watson-discovery-noobaa-account
	# export NOOBAA_ACCOUNT_CREDENTIALS_SECRET=noobaa-account-watson-discovery-noobaa-account
	export NOOBAA_ACCOUNT_CREDENTIALS_SECRET=noobaa-admin
	export NOOBAA_ACCOUNT_CERTIFICATE_SECRET=noobaa-s3-serving-cert
	# # HIDE: export NOOBAA_ACCOUNT_CREDENTIALS_SECRET=ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
	# # HIDE: export NOOBAA_ACCOUNT_CERTIFICATE_SECRET=ZZZZZZZZZZZZZZZZZZZZZZ

	## When NOT installing as the Cluster Administrator, define the user and role.
	export ROLE_NAME="cpdsched-role"
	export ROLE_NAME="cpdrole"
	export SCHEDULING_ADMIN="cpdadmin1"
	export INSTANCE_ADMIN="cpdadmin1"
	export INSTANCE_PASSWORD="password"
	# HIDE: export INSTANCE_PASSWORD="ZZZZZZZ"
	export OC_LOGIN_INST="eval oc login \${OCP_URL} -u \${INSTANCE_ADMIN} -p \${INSTANCE_PASSWORD}"
	export CPDM_OC_LOGIN_INST="eval cpd-cli manage login-to-ocp \
					\${OCP_URL} -u \${INSTANCE_ADMIN} -p \${INSTANCE_PASSWORD}"
#		--server=\${OCP_URL} --username=\${INSTANCE_ADMIN} --password=\${INSTANCE_PASSWORD}"

	source ${WORKDIR}/Scripts/cpd_vars_airgapped.sh
fi

