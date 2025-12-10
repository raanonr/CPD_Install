#!/bin/bash
#===============================================================================
## Raanon: env.sh

## set BASTION_TYPE="<internet|airgapped>" or pass as optional argument
export BASTION_TYPE="${1:-airgapped}"
[[ ! ${BASTION_TYPE} =~ internet|airgapped ]] && echo "Error: Set BASTION_TYPE or pass <internet|airgapped>" && return

## Setup WORKDIR environment.
export WORKDIR="$(readlink -f $(dirname "${BASH_SOURCE[0]}"))"
export WORKDIR="${WORKDIR/\/Scripts/}"
export CPD_CLI_PATH="$(ls -d ${WORKDIR}/cpd-cli-linux* | tail -1)"
export SAVE_DIR="${WORKDIR}_Save"

mkdir -p ${WORKDIR}/{Scripts,Download,bin}
mkdir -p ${WORKDIR}/{Bak,Out,Yaml}

## Append to the PATH.
[[ ! $PATH =~ ${WORKDIR}/bin ]] && export PATH=${WORKDIR}/bin:${WORKDIR}/Scripts:${PATH}
[[ ! $PATH =~ cpd-cli ]]        && export PATH=${CPD_CLI_PATH}:${PATH}

## Unset (clean) all variables.
source ${WORKDIR}/Scripts/cpd_vars_clean.sh

#===============================================================================
## EDIT THIS
## Define variables which are use-case specific for a customer
## For multiple iterations with different COMPONENTS, use multiple workspaces and/or multiple private registries (PCR)
## (If using an Intermediate Registry, use multiple workspaces.)
#===============================================================================
#export COMPONENTS_THIS=""
#export COMPONENTS_THIS=watsonx_ai,watsonx_orchestrate,watsonx_data
#export COMPONENTS_THIS=watsonx_ai
#export COMPONENTS_THIS=watsonx_orchestrate
export COMPONENTS_THIS=watsonx_data

export WORKSPACE=${WORKDIR}/cpd-cli-workspace
#export WORKSPACE=${WORKDIR}/cpd-cli-workspace-xai
#export WORKSPACE=${WORKDIR}/cpd-cli-workspace-xorch
#export WORKSPACE=${WORKDIR}/cpd-cli-workspace-xdata

# Private Container Registry
#export PCR_PORT="5005" && export PCR_NAME="cpd-private-registry"
export PCR_PORT="5006" && export PCR_NAME="cpd-priv-reg-xdata"

export CPD_CLI_MANAGE_WORKSPACE=${WORKSPACE}/olm-utils-workspace
export WORK="${CPD_CLI_MANAGE_WORKSPACE}/work"
export OLM_UTILS_IMAGE="icr.io/cpopen/cpd/olm-utils-v3:latest"
export OLM_UTILS_LAUNCH_ARGS=" --network=host"

#===============================================================================
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
## Some Private Container Registry (PCR) variables
export PCR_TAR="${WORKDIR}/Download/registry.tar"
export PCR_IMAGE="docker.io/library/registry:2.7"
#export PCR_HOST="$(hostname -f)"
export PCR_HOST="127.0.0.1"
export PCR_PORT="${PCR_PORT:-5005}"
export PCR_NAME="${PCR_NAME:-cpd-private-registry}"
export PCR_CERTFILE="cpd_pcr_domain"
export PCR_OFFLINE="${WORKDIR}/${PCR_NAME}"
export USE_SKOPEO=true

export PCR_LOCATION="${PCR_HOST}:${PCR_PORT}"
export PCR_PUSH_USER="ZZZZZ"
export PCR_PUSH_PASSWORD="ZZZZZ"
export PCR_PULL_USER="ZZZZZ"
export PCR_PULL_PASSWORD="ZZZZZ"

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

	## Set KUBECONFIG if you have it.
	export KUBECONFIG=${WORKDIR}/ocp_20250225-conf_kubeconfig_download.conf

	## OCP variables
	export OCP_URL="api.ZZZZZZZZZ.techzone.ibm.com:ZZZZ"
	export OCP_USERNAME="ZZZZZZZZZ"
	export OCP_PASSWORD="ZZZZZZZZZZZZZZZZZZ"

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
	# export NOOBAA_ACCOUNT_CREDENTIALS_SECRET=ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
	# export NOOBAA_ACCOUNT_CERTIFICATE_SECRET=ZZZZZZZZZZZZZZZZZZZZZZ

	## When NOT installing as the Cluster Administrator, define the user and role.
	export ROLE_NAME="cpdsched-role"
	export ROLE_NAME="cpdrole"
	export SCHEDULING_ADMIN="cpdadmin1"
	export INSTANCE_ADMIN="cpdadmin1"
	export INSTANCE_PASSWORD="ZZZZZZZ"
	export OC_LOGIN_INST="eval oc login \${OCP_URL} -u \${INSTANCE_ADMIN} -p \${INSTANCE_PASSWORD}"
	export CPDM_OC_LOGIN_INST="eval cpd-cli manage login-to-ocp \
					\${OCP_URL} -u \${INSTANCE_ADMIN} -p \${INSTANCE_PASSWORD}"
#		--server=\${OCP_URL} --username=\${INSTANCE_ADMIN} --password=\${INSTANCE_PASSWORD}"

	source ${WORKDIR}/Scripts/cpd_vars_airgapped.sh
fi

