#!/bin/bash
#===============================================================================
# Raanon: repo_delete.sh

# STOP. Don't use this method to delete. See repo_delete.txt.
# (a) stop registry. (b) delete directory from registry local storage. (c) start registry. (d) run garbage collection.

exit

REGISTRY_URL="https://${PCR_LOCATION}/v2"
AUTH="-k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD}"
ARGS="-sS"
HEADER="Accept: application/vnd.docker.distribution.manifest.v2+json"

# Get all repositories
#repos=$(curl ${AUTH} "${REGISTRY_URL}/_catalog" | jq -r '.repositories[]')
repos="$*"

for repo in ${repos}; do
  
  # Get tags for each repo
  tags=$(curl ${ARGS} ${AUTH} "${REGISTRY_URL}/${repo}/tags/list" | jq -r '.tags')
  [[ ${tags} = null ]] && echo "NO tags for repo: ${repo}" && continue
  tags=$(curl ${ARGS} ${AUTH} "${REGISTRY_URL}/${repo}/tags/list" | jq -r '.tags[]')
  
  for tag in ${tags}; do
    
    # Get manifest for each tag
    digest=$(curl -I ${ARGS} ${AUTH} -H "${HEADER}" "${REGISTRY_URL}/${repo}/manifests/${tag}" | \
	     grep -i "Docker-Content-Digest" | awk '{print $2}' | tr -d '\r')
    
    echo "DELETING... ${repo} : ${tag} : $digest"

    echo curl ${AUTH} -X DELETE ${REGISTRY_URL}/${repo}/manifests/${digest}
    curl ${AUTH} -X DELETE ${REGISTRY_URL}/${repo}/manifests/${digest}

  done
done

