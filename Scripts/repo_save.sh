#!/bin/bash
#===============================================================================
# Raanon: repo_save.sh
# Save using * skopeo *
# $0 [--dir REPO_DIR] [--ignore IGNORE_FILE] [--delete]
# --dir: Directory Repos_<date> created there. Default REPO_DIR is $SAVE_DIR.
# --ignore: The repos in this file will be ignored.
# --delete: If the tar file already exists, delete it before writing (otherwise, an error occurs). Default: False.

# To load on target:
# $PCR_LOGIN
# skopeo copy --dest-creds=${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} --dest-tls-verify=false docker-archive:/Install/CPD_5.1.1_Save/Repos_20250324/cp/cpd/fm-detectors-pii__0.4.4.tar docker://${PCR_LOCATION}/test/cp/cpd/fm-detectors-pii:0.4.4


## Args and get repo list
unset DELETE
while [[ ${1:0:2} == "--" ]]; do
	[[ $1 == "--dir" ]] && export REPO_DIR="${2:?Missing dir arg}" && shift
	[[ $1 == "--ignore" ]] && export IGNORE_FILE="${2:?Missing ignore-file arg}" && shift
	[[ $1 == "--delete" ]] && export DELETE="YES"
	shift
done

REPO_SEARCH="${*:-.}"
echo "REPO_SEARCH = ${REPO_SEARCH// /|}"
[[ -n $IGNORE_FILE ]] && echo "IGNORE_FILE = $IGNORE_FILE"
[[ -n $IGNORE_FILE && ! -f $IGNORE_FILE ]] && echo "IGNORE_FILE missing" && exit

[[ -z ${REPO_DIR} ]] && export REPO_DIR="${SAVE_DIR:?Undefined}/Repos_$(date +'%Y%m%d')"
echo "REPO_DIR    = ${REPO_DIR}"

[[ -n $DELETE ]] && echo "Delete tar file, if exists, before writing."

#=============================
function image_size() {
	local _manifest="$1"
	local _mediaType DIGESTS _total_size _digest _digestManifest _digest_size _size_mb

	_mediaType="$(echo $_manifest | jq -r '.mediaType' | tr -d '\r\n ')"

	if [[ "$_mediaType" == "application/vnd.oci.image.index.v1+json" ]]; then
		DIGESTS=$(echo "$_manifest" | jq -r '.manifests[].digest')

		_total_size=0
		for _digest in $DIGESTS; do
			_digestManifest=$(curl ${ARGS} ${AUTH} -H "${HEADER}" "${REGISTRY_URL}/${_repo}/manifests/${_digest}")
			_digest_size=$(echo $_digestManifest | jq '[.layers[].size] | add')
			((_total_size+=_digest_size))
		done
		#_total_size=$(echo $_manifest | jq '[.manifests[].size] | add')

	else # application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json

		_total_size=$(echo $_manifest | jq '[.config.size] + [.layers[].size] | add')

	fi
	_size_mb=$(echo "scale=3; $_total_size / 1024^2" | bc)
	echo $_size_mb
}

#=============================
COUNT=$(curl -sS -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=1000 | jq -r '.repositories[]' | grep -E "${REPO_SEARCH// /|}" | wc -l)

if [[ $COUNT -le 30 ]]; then
	echo curl -sS -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=1000 
	curl -sS -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION:?Undefined}/v2/_catalog?n=1000 | jq -r '.repositories[]' | grep -E "${REPO_SEARCH// /|}"
else
	echo "Search returns $COUNT repos."
fi

## Confirm
read -p "Confirm list of repos [y/N]? " YN
[[ ${YN^^} != Y ]] && exit

REPOS=$(curl -sS -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=1000 | jq -r '.repositories[]' | grep -E "${REPO_SEARCH// /|}")

REGISTRY_URL="https://${PCR_LOCATION}/v2"
ARGS="-sS"
AUTH="-k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD}"
HEADER="Accept: application/vnd.docker.distribution.manifest.v2+json"

#=============================
for repo in ${REPOS}; do
 
  [[ -n $IGNORE_FILE ]] && grep -q $repo $IGNORE_FILE && echo "SKIPPING $repo ... Found in ignore-file" && continue

  # Get tags for each repo
  tags=$(curl ${ARGS} ${AUTH} "${REGISTRY_URL}/${repo}/tags/list" | jq -r '.tags')
  [[ ${tags} = null ]] && echo "NO tags for repo: ${repo}" && continue

  tags=$(curl ${ARGS} ${AUTH} "${REGISTRY_URL}/${repo}/tags/list" | jq -r '.tags[]')
  
  for tag in ${tags}; do
    
    # Get manifest for each tag
    manifest=$(curl ${ARGS} ${AUTH} -H "${HEADER}" "${REGISTRY_URL}/${repo}/manifests/${tag}")
    # Calculate total size
    size_mb=$(image_size "$manifest")
    
    SAVE_NAME="${REPO_DIR:?Undefined}/${repo}__${tag}.tar"
    mkdir -p ${REPO_DIR}/${repo%/*}
    [[ -f $SAVE_NAME && -z $DELETE ]] && echo "SKIPPING $SAVE_NAME ... Already exists" && ls -l $SAVE_NAME && continue
    [[ -f $SAVE_NAME && -n $DELETE ]] && echo "Deleting existing tar file..." && rm -f $SAVE_NAME
    printf "Save (>%s MB) to %s\n" "${size_mb}" "${SAVE_NAME}"

    # echo touch ${SAVE_NAME}
    skopeo copy --src-creds=${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} --src-tls-verify=false \
	    docker://${PCR_LOCATION}/${repo}:${tag} \
	    docker-archive:${SAVE_NAME}
    RC=$?
    ls -l ${SAVE_NAME}
    [[ $RC != 0 ]] && echo "Aborting..." && exit
  done
done
