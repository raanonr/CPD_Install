#!/bin/bash
#===============================================================================
# Raanon: mirror-images.sh

echo "Syntax: $0 [--case-download] [--list-images]"

unset CASE_DOWN
unset LIST_IMAGES
export PCR_LOCATION="${PRIVATE_REGISTRY_LOCATION:?Undefined}"
while [[ ${1:0:2} == "--" ]]; do
	case "$1" in
		--case-download) export CASE_DOWN="TRUE";;
		--list-images)   export LIST_IMAGES="TRUE";;
		--pcr-location)	 export PCR_LOCATION="${2:?Missing}";;
	esac
	shift
done

echo "CASE download= $CASE_DOWN"
echo "List images  = $LIST_IMAGES"
echo "COMPONENTS   = $COMPONENTS"
echo "MODEL_GROUPS = $MODEL_GROUPS"

[[ "${CASE_DL}${COMPONENTS}${MODEL_GROUPS}" == FALSE ]] && exit
read -p "Hit ENTER to continue..." YN

$CPDM_ENTREG_LOGIN 
$CPDM_PCR_LOGIN

if [[ -z $COMPONENTS ]]; then
	echo "No COMPONENTS defined"
else
	[[ ${CASE_DOWN^^} == TRUE ]] && \
		cpd-cli manage case-download \
		--components=${COMPONENTS} \
		--release=${VERSION}
	read -p "Hit ENTER to continue..." YN


	[[ ${LIST_IMAGES^^} == TRUE ]] && \
		cpd-cli manage list-images \
		--components=${COMPONENTS} \
		--release=${VERSION} \
		--inspect_source_registry=true
	[[ ${LIST_IMAGES^^} == TRUE ]] && \
		cp $WORK/offline/${VERSION}/list_images.csv Out/list_images.${COMPONENTS}.csv && \
		wc -l $WORK/offline/${VERSION}/list_images.csv && \
		grep "level=fatal" $WORK/offline/${VERSION}/list_images.csv


	echo \
		\
	cpd-cli manage mirror-images \
	--components=${COMPONENTS} \
	--release=${VERSION} \
	--target_registry=${PRIVATE_REGISTRY_LOCATION} \
	--arch=${IMAGE_ARCH} \
	--case_download=false

	read -p "Hit ENTER to continue..." YN

	#===============================================================================
	# Mirror all components
	_allStart=$(date +'%Y-%m-%d %H:%M:%S')
	cpd-cli manage mirror-images \
	--components=${COMPONENTS} \
	--release=${VERSION} \
	--target_registry=${PRIVATE_REGISTRY_LOCATION} \
	--arch=${IMAGE_ARCH} \
	--case_download=false

	_allEnd=$(date +'%Y-%m-%d %H:%M:%S')

	printf "Mirror for all components started: ${_allStart}\n"
	printf "Mirror for all components ended  : ${_allEnd}\n\n\n"
fi

#===============================================================================
# Mirror IBM Foundation Models
if [[ -z ${MODEL_GROUPS} ]]; then
	echo "No MODEL_GROUPS defined"
else
	# Note: --groups is a comma seperated list (no spaces) of foundation model groups as they appear in both of these sites:
	# https://www.ibm.com/docs/en/software-hub/5.1.x?topic=registry-mirroring-images-directly-private-container
	# https://www.ibm.com/docs/en/software-hub/5.1.x?topic=install-foundation-models

	_modelStart=$(date +'%Y-%m-%d %H:%M:%S')
	set -x
	cpd-cli manage mirror-images \
	--components=watsonx_ai_ifm \
	--release=${VERSION} \
	--target_registry=${PRIVATE_REGISTRY_LOCATION} \
	--arch=${IMAGE_ARCH} \
	--case_download=false \
	--groups=${MODEL_GROUPS}
	set +x
	_modelEnd=$(date +'%Y-%m-%d %H:%M:%S')

	printf "Mirror for all components started: ${_allStart}\n"
	printf "Mirror for models started: ${_modelStart}\n"
	printf "Mirror for models ended  : ${_modelEnd}\n"
fi

echo "Done!"
