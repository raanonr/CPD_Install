#!/bin/bash
#===============================================================================
# Raanon: repo_sizes.sh
# repo_sizes.sh [--pcr <registry_name> [--port <registry_port>]] [repo-search [repo-search...]]

#export DEBUG="1"

# Allow overriding defaults to create a particular (partial) PCR
if [[ $1 == "--pcr" ]]; then
	export PCR_NAME="$2"
	shift && shift
	if [[ $1 == "--port" ]]; then
		export PCR_PORT="$2"
		shift && shift
	else
		# Get PORT from podman description
		_container=$(podman ps | grep " ${PCR_NAME}$")
		_port=${_container#*0.0.0.0:}
		PCR_PORT=${_port%->*}
	fi
	export PCR_LOCATION="${PCR_HOST}:${PCR_PORT}"
fi

printf "Private Registry container: ${PCR_NAME}"
[[ $(podman ps | grep " ${PCR_NAME}$") == "" ]] && echo " NOT running!" && exit
printf "\n\n"

## Args
REPO_SEARCH="${*:-.}"
echo "REPO_SEARCH = ${REPO_SEARCH// /|}"

echo "curl -sS -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=1000"
REPOS=$(curl -sS -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=1000 | jq -r '.repositories[]' | grep -E "${REPO_SEARCH// /|}")

#==========================================
REGISTRY_URL="https://${PCR_LOCATION}/v2"
ARGS="-sS"
AUTH="-k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD}"
HEADER="Accept: application/vnd.oci.image.manifest.v1+json, application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.v2+json"
TOTAL=0

[[ -n ${REPOS} ]] && \
	printf "%9s : %-50s : %2s : %s\n" "0== MB ==" "====== REPO ========" "VV" "===== TAG ============"

for _repo in ${REPOS}; do
  
  # Get tags for each repo
  [[ -n $DEBUG ]] && echo "TAGS=\$(curl ${ARGS} ${AUTH} -H "${HEADER}" \"${REGISTRY_URL}/${_repo}/tags/list\" | jq -r '.tags')"
  TAGS=$(curl ${ARGS} ${AUTH} -H "${HEADER}" "${REGISTRY_URL}/${_repo}/tags/list" | jq -r '.tags')
  [[ ${TAGS} = null ]] && echo "NO tags for repo: ${_repo}" && continue
  TAGS=$(curl ${ARGS} ${AUTH} -H "${HEADER}" "${REGISTRY_URL}/${_repo}/tags/list" | jq -r '.tags[]')
  
  for _tag in ${TAGS}; do
    
    # Get manifest for each tag
    _manifest=$(curl ${ARGS} ${AUTH} -H "${HEADER}" "${REGISTRY_URL}/${_repo}/manifests/${_tag}")
    [[ $_manifest =~ error ]] && echo "Tag (${_tag}): ERROR: $_manifest" && continue
    [[ -n $DEBUG ]] && echo "Tag (${_tag}):" && echo $_manifest | jq -r .
    
    _mediaType="$(echo $_manifest | jq -r '.mediaType' | tr -d '\r\n ')"
    _mediaVersion="${_mediaType:(-7):(2)}"
    [[ -n $DEBUG ]] && echo "mediaType: ${_mediaType}"

    # Calculate total size

    if [[ "$_mediaType" == "application/vnd.oci.image.index.v1+json" ]]; then
	_mediaVersion="1i"
	DIGESTS=$(echo "$_manifest" | jq -r '.manifests[].digest')

	_total_size=0
	for _digest in $DIGESTS; do
		_digestManifest=$(curl ${ARGS} ${AUTH} -H "${HEADER}" "${REGISTRY_URL}/${_repo}/manifests/${_digest}")
		_digest_size=$(echo $_digestManifest | jq '[.layers[].size] | add')
		[[ -n $DEBUG ]] && echo "$_digest: $_total_size += $_digest_size"
		((_total_size+=_digest_size))
	done
	#_total_size=$(echo $_manifest | jq '[.manifests[].size] | add')

    else # application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json

	_total_size=$(echo $_manifest | jq '[.config.size] + [.layers[].size] | add')

    fi
    _size_mb=$(echo "scale=3; $_total_size / 1024^2" | bc)
    ((TOTAL+=_total_size))
    
    printf "%9.3f : %-50s : %2s : %s\n" ${_size_mb} ${_repo} ${_mediaVersion} ${_tag}
  done
done

#	printf "%9s : %-40s : %s\n" "0== MB ==" "====== REPO ========" "===== TAG ============" && \
[[ -n ${REPOS} ]] && \
	printf "%9s : %-50s : %2s : %s\n" "0== MB ==" "====== REPO ========" "VV" "===== TAG ============" && \
	printf "%10.3f : Total MB\n" $(echo "scale=3; $TOTAL / 1024^2" | bc)
