#!/bin/bash

[[ $# != 1 ]] && echo "SYNTAX: $0 <pcr-name>" && exit

export PCR_NAME="${1:?Undefined}"

read -p "DELETE ${PCR_NAME} !!!?? ARE YOU SURE [y/N]???? " YN

[[ ${YN^^} != Y ]] && exit

set -x
cd $WORKDIR
du -sm ${PCR_NAME}
podman stop ${PCR_NAME}
rm -fr ${PCR_NAME}/registry/data/docker/registry/v2/repositories/*
du -sm ${PCR_NAME}
podman start ${PCR_NAME}
podman exec -it ${PCR_NAME} bin/registry garbage-collect /etc/docker/registry/config.yml 2>&1 >/dev/null
du -sm ${PCR_NAME}
set +x
echo "DONE"

exit


# Method 2 to delete from private registry.
# (a) stop registry.
# (b) delete directory from registry local storage.
# (c) start registry.
# (d) run garbage collection.

cd ${WORKDIR}

export PCR_NAME=pcr-openshift-3

Scripts/repo_sizes.sh
Scripts/repo_sizes.sh ${MODEL_REPOS}

Scripts/curl_private.sh | wc -l
du -sm ${PCR_NAME}
du -sm ${PCR_NAME}/registry/data/docker/registry/v2/repositories/cp/cpd/*{flan,llama,e5}*

podman stop ${PCR_NAME} 

# REMOVE
rm -fr ${PCR_NAME}/registry/data/docker/registry/v2/repositories/*
rm -fr ${PCR_NAME}/registry/data/docker/registry/v2/repositories/cp/cpd/google-flan-t5-xl ${PCR_NAME}/registry/data/docker/registry/v2/repositories/cp/cpd/google-flan-t5-xxl ${PCR_NAME}/registry/data/docker/registry/v2/repositories/cp/cpd/google-flan-ul2

podman start ${PCR_NAME} 

# GARBAGE COLLECTION
podman exec -it ${PCR_NAME} bin/registry garbage-collect /etc/docker/registry/config.yml 2>&1 >/dev/null

#### VERIFY 1

Scripts/repo_sizes.sh
Scripts/curl_private.sh | wc -l
du -sm ${PCR_NAME}
du -sm ${PCR_NAME}/registry/data/docker/registry/v2/repositories/cp/cpd/*{flan,llama,e5}*

#### VERIFY 2

###[root@RaanonD-node-1 CPD_5.1.0]# podman login -u ${PRIVATE_REGISTRY_PUSH_USER} -p ${PRIVATE_REGISTRY_PUSH_PASSWORD} ${PRIVATE_REGISTRY_LOCATION} --tls-verify=false
$PCR_LOGIN
Login Succeeded!
[root@RaanonD-node-1 CPD_5.1.0]# podman pull --tls-verify=false ${PRIVATE_REGISTRY_LOCATION}/cp/cpd/multilingual-e5-large:5.1.0-202411012253
Trying to pull 127.0.0.1:5005/cp/cpd/multilingual-e5-large:5.1.0-202411012253...
[root@RaanonD-node-1 CPD_5.1.0]# podman images
REPOSITORY                                             TAG                                      IMAGE ID      CREATED        SIZE
icr.io/cpopen/cpd/olm-utils-v3                         latest                                   045caafea72c  4 days ago     921 MB
127.0.0.1:5005/cp/cpd/multilingual-e5-large            5.1.0-202411012253                       f9363aa55e00  4 months ago   2.37 GB
docker.io/library/registry                             2.7                                      b8604a3fe854  3 years ago    26.8 MB
[root@RaanonD-node-1 CPD_5.1.0]# podman rmi ${PRIVATE_REGISTRY_LOCATION}/cp/cpd/multilingual-e5-large:5.1.0-202411012253
Untagged: 127.0.0.1:5005/cp/cpd/multilingual-e5-large:5.1.0-202411012253
Deleted: f9363aa55e00fda2a0c172a6e4856c335909937bf36b6ff47bb7b49bd8f3b588

