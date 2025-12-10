
PCR="cpd-private-registry"
REPO="cp/watsonx-orchestrate"

REG_PATH="registry/data/docker/registry/v2"

function blob_list() {
	local IMAGE="$(basename ${1:?missing arg})"

	# echo ${PCR}/${REG_PATH}/repositories/${REPO}/${IMAGE}
	for f in ${WORKDIR}/${PCR}/${REG_PATH}/repositories/${REPO}/${IMAGE}/_layers/sha256/* ; do
		blob="$(basename $f)"
		blob_path="/${REG_PATH}/blobs/sha256/${blob:0:2}/$blob"
		### echo ${blob}
		echo ${WORKDIR}/${PCR}/${blob_path}
		### grep -q "${blob_path}" pcr-watsonx-orch_tar.out || \
		### 	echo "MISSING: ${blob}"
	done
}

#######

printf "\nPCR : ${PCR}\n"
printf "REPO: ${REPO}\n\n"

# ls ${WORKDIR}/${PCR}/${REG_PATH}/repositories/${REPO}
# IMAGE="wo-skill-catalog-ui"

for image in ${WORKDIR}/${PCR}/${REG_PATH}/repositories/${REPO}/*; do
	IMAGE="$(basename ${image})"
	# blob_list "${IMAGE}"

	du -ks $(blob_list "${IMAGE}") | awk '{kb+=$1}END{printf "Sum of blobs: %7.2f MB  %s\n", (kb/1024.0), "'${IMAGE}'"}'
done

###
# blob_list "${IMAGE}"
# du -s $(blob_list) | awk '{kb+=$1}END{print "Sum of blobs \"'${IMAGE}'\":", (kb/1024.0), "MB"}'

# tar -cvf ${IMAGE}.tar $(blob_list "${IMAGE}")
