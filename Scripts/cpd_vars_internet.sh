#===============================================================================
# Raanon: cpd_vars_internet.sh
# https://www.ibm.com/docs/en/software-hub/5.1.x?topic=information-setting-up-installation-environment-variables

#===============================================================================
# IBM Software Hub installation variables
#===============================================================================

# ------------------------------------------------------------------------------
# Client workstation 
# ------------------------------------------------------------------------------
# Set the following variables if you want to override the default behavior of the IBM Software Hub CLI.
#
# To export these variables, you must uncomment each command in this section.

# export CPD_CLI_MANAGE_WORKSPACE=<enter a fully qualified directory>
# export OLM_UTILS_LAUNCH_ARGS=<enter launch arguments>


# ------------------------------------------------------------------------------
# Cluster
# ------------------------------------------------------------------------------

## export OCP_URL=<enter your Red Hat OpenShift Container Platform URL>
## export OPENSHIFT_TYPE=<enter your deployment type>
export IMAGE_ARCH=amd64
# export OCP_USERNAME=<enter your username>
# export OCP_PASSWORD=<enter your password>
# export OCP_TOKEN=<enter your token>
## export SERVER_ARGUMENTS="--server=${OCP_URL}"
# export LOGIN_ARGUMENTS="--username=${OCP_USERNAME} --password=${OCP_PASSWORD}"
# export LOGIN_ARGUMENTS="--token=${OCP_TOKEN}"
## export CPDM_OC_LOGIN="cpd-cli manage login-to-ocp ${SERVER_ARGUMENTS} ${LOGIN_ARGUMENTS}"
## export OC_LOGIN="oc login ${SERVER_ARGUMENTS} ${LOGIN_ARGUMENTS}"


# ------------------------------------------------------------------------------
# Proxy server
# ------------------------------------------------------------------------------

# export PROXY_HOST=<enter your proxy server hostname>
# export PROXY_PORT=<enter your proxy server port number>
# export PROXY_USER=<enter your proxy server username>
# export PROXY_PASSWORD=<enter your proxy server password>
# export NO_PROXY_LIST=<a comma-separated list of domain names>


# ------------------------------------------------------------------------------
# Projects
# ------------------------------------------------------------------------------

## The next two project names are recommended/default values.
export PROJECT_CERT_MANAGER=cert-manager-operator
export PROJECT_LICENSE_SERVICE=ibm-licensing
## There is no default value.  You can use any Red Hat OpenShift project; however, it is strongly recommended that you use ibm-cpd-scheduler. Do not co-locate the scheduling service with other software.
export PROJECT_SCHEDULING_SERVICE=ibm-cpd-scheduler
## watsonx Assistant or watsonx Orchestrate users only. The project where you want to install the IBM Events Operator or the project where a cluster-wide instance of the IBM Events Operator is already installed.
export PROJECT_IBM_EVENTS=ibm-knative-events
# export PROJECT_PRIVILEGED_MONITORING_SERVICE=<enter your privileged monitoring service project>
export PROJECT_CPD_INST_OPERATORS=cpd-swhub-operator
export PROJECT_CPD_INST_OPERANDS=cpd-swhub
# export PROJECT_CPD_INSTANCE_TETHERED=<enter your tethered project>
# export PROJECT_CPD_INSTANCE_TETHERED_LIST=<a comma-separated list of tethered projects>



# ------------------------------------------------------------------------------
# Storage
# ------------------------------------------------------------------------------

## OpenShift Data Foundation
export STG_CLASS_BLOCK=ocs-storagecluster-ceph-rbd
export STG_CLASS_FILE=ocs-storagecluster-cephfs
## NFS (tmp)
## export STG_CLASS_BLOCK=managed-nfs-storage
## export STG_CLASS_FILE=managed-nfs-storage

# ------------------------------------------------------------------------------
# IBM Entitled Registry
# ------------------------------------------------------------------------------

export IBM_ENTITLEMENT_KEY="${IBM_ENTITLEMENT_KEY:?Undefined}"


# ------------------------------------------------------------------------------
# Private container registry
# ------------------------------------------------------------------------------
# Set the following variables if you mirror images to a private container registry.
#
# To export these variables, you must uncomment each command in this section.

export PRIVATE_REGISTRY_LOCATION="${PCR_LOCATION:?Undefined}"
export PRIVATE_REGISTRY_PUSH_USER="${PCR_PUSH_USER:?Undefined}"
export PRIVATE_REGISTRY_PUSH_PASSWORD="${PCR_PUSH_PASSWORD:?Undefined}"
export PRIVATE_REGISTRY_PULL_USER="${PCR_PULL_USER:?Undefined}"
export PRIVATE_REGISTRY_PULL_PASSWORD="${PCR_PULL_PASSWORD:?Undefined}"


# ------------------------------------------------------------------------------
# IBM Software Hub version
# ------------------------------------------------------------------------------

export VERSION=${VERSION:-5.1.1}


# ------------------------------------------------------------------------------
# Components
# ------------------------------------------------------------------------------

## OLD v4.8: export COMPONENTS=ibm-cert-manager,ibm-licensing,scheduler,cpfs,cpd_platform
## If COMPONENTS is defined, use it. If not, use defaults, appending COMPONENTS_ADD, if it's defined.
export COMPONENTS="${COMPONENTS:-ibm-licensing,scheduler,cpfs,cpd_platform${COMPONENTS_ADD:+,${COMPONENTS_ADD}}}"
# export COMPONENTS_TO_SKIP=<component-ID-1>,<component-ID-2>


# ------------------------------------------------------------------------------
# watsonx Orchestrate
# ------------------------------------------------------------------------------
export PROJECT_IBM_APP_CONNECT=ibm-app-connect
export AC_CASE_VERSION=12.5.0
export AC_CHANNEL_VERSION=v12.5
