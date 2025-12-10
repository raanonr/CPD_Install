#!/bin/bash

export PCR_NAME=${1:-$PCR_NAME}
export TAR_SIZE=${2:-5000} # MB

export TAR_DIR=${SEND_DIR}/${PCR_NAME}_tar
export TAR_PREFIX=${TAR_DIR}/${PCR_NAME}
export _part=00
cd $WORKDIR

function tar_part() {
	local _part=$1
	local _sha_list=$2
	local _sha_count=$3
	local _sum_mb=$4

	local _partStr=$(printf "%02d" "${_part}")

	printf "\n--- Tar part %s: %d MB from %d registry blobs/sha256 prefix directories.\n" "${_partStr}" "${_sum_mb}" "${_sha_count}"
	tar -cf ${TAR_PREFIX}_part${_partStr}.tar ${_sha_list}
	ls -l ${TAR_PREFIX}_part${_partStr}.tar
}

echo "PCR Size (MB)"
du -sh ${PCR_NAME}

printf "\nCreating Tar: ${TAR_PREFIX}_part${_part}.tar ... For registry auth, certs and repositories.\n"
[[ -f ${TAR_PREFIX}_part${_part}.tar ]] && echo " Already exists! Continue to overwrite..."
read -p "Continue [y/N]? " YN
[[ ${YN^^} != Y ]] && exit

mkdir -p ${TAR_DIR}
tar -cf ${TAR_PREFIX}_part${_part}.tar ${PCR_NAME}/registry/{auth,certs} ${PCR_NAME}/registry/data/docker/registry/v2/repositories
ls -l ${TAR_PREFIX}_part${_part}.tar

_sum_mb=0
_sha_list=""
_sha_count=0
while read -ra line; do
	((++_sha_count))
	_sum_mb=$((_sum_mb + ${line[0]}))
	_sha_list="${_sha_list} ${line[1]}"
	#printf "${line[0]} \n"
	#printf "%d %s\n" "${_sum_mb}" "${_sha_list}"
	if [[ ${_sum_mb} -ge $TAR_SIZE ]]; then
		# (10#$) Avoid error: 08: value too great for base (error token is "08")
		_part=$((10#$_part + 1))
		#_part=$(printf "%02d" $((_part = 10#$_part)) )

		tar_part "${_part}" "${_sha_list}" "${_sha_count}" "${_sum_mb}"

		_sha_count=0
		_sum_mb=0
		_sha_list=""
	fi
done < <(du -sm ${PCR_NAME}/registry/data/docker/registry/v2/blobs/sha256/* | sort -n)
#DEBUG: done < <(du -sm ${PCR_NAME}/registry/data/docker/registry/v2/blobs/sha256/* | sort -n | head -15)

if [[ -n ${_sha_list} ]]; then
	printf "\n--- Last Tar ..."
	_part=$((10#$_part + 1))
	tar_part "${_part}" "${_sha_list}" "${_sha_count}" "${_sum_mb}"
fi
