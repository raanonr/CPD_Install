#===============================================================================
# Raanon: cpd_vars_clean.sh
# https://www.ibm.com/docs/en/software-hub/5.1.x?topic=information-setting-up-installation-environment-variables

## These come from env.sh
#unset BASTION_TYPE
#unset WORKDIR
#unset CPD_CLI_PATH
#unset CPD_VER
unset KUBECONFIG

	unset CPDM_ENTREG_LOGIN

	unset PCR_TAR
	unset PCR_HOST
	unset PCR_PORT
	unset PCR_NAME
	unset PCR_OFFLINE
	unset USE_SKOPEO

	unset PCR_LOCATION
	unset PCR_PUSH_USER
	unset PCR_PUSH_PASSWORD
	unset PCR_PULL_USER
	unset PCR_PULL_PASSWORD

	unset CPDM_PCR_LOGIN

	## These are needed to create a cpd-cli profile, which is needed to manage instances (wd) and users.
	unset CPD_ADMIN_USER
	unset CPD_LOCAL_USER
	unset CPD_PROFILE_NAME

	## These are needed to create the Watson Discovery instance.
	unset INSTANCE_NAME
	unset INSTANCE_VERSION
	unset PAYLOAD_FILE
	# unset BACKING_STORE
	# unset ACCOUNT_NAME
	# unset NOOBAA_ACCOUNT_CREDENTIALS_SECRET
	# unset NOOBAA_ACCOUNT_CERTIFICATE_SECRET

	## When NOT installing as the Cluster Administrator, define the user and role.
	unset ROLE_NAME
	unset ROLE_NAME
	unset SCHEDULING_ADMIN
	unset INSTANCE_ADMIN
	unset INSTANCE_PASSWORD
	unset OC_LOGIN_INST
	unset CPDM_OC_LOGIN_INST

unset WORKSPACE
unset WORK
unset OLM_UTILS_IMAGE
unset OLM_UTILS_LAUNCH_ARGS

#===============================================================================
# IBM Software Hub installation variables
#===============================================================================

# ------------------------------------------------------------------------------
# Client workstation 
# ------------------------------------------------------------------------------
# Set the following variables if you want to override the default behavior of the IBM Software Hub CLI.
#
# To export these variables, you must uncomment each command in this section.

unset CPD_CLI_MANAGE_WORKSPACE
unset OLM_UTILS_LAUNCH_ARGS


# ------------------------------------------------------------------------------
# Cluster
# ------------------------------------------------------------------------------

unset OCP_URL
unset OPENSHIFT_TYPE
unset IMAGE_ARCH
unset OCP_USERNAME
unset OCP_PASSWORD
unset OCP_TOKEN
unset SERVER_ARGUMENTS
unset LOGIN_ARGUMENTS
unset LOGIN_ARGUMENTS
unset CPDM_OC_LOGIN
unset OC_LOGIN


# ------------------------------------------------------------------------------
# Proxy server
# ------------------------------------------------------------------------------

unset PROXY_HOST
unset PROXY_PORT
unset PROXY_USER
unset PROXY_PASSWORD
unset NO_PROXY_LIST


# ------------------------------------------------------------------------------
# Projects
# ------------------------------------------------------------------------------

## The next two project names are recommended/default values.
unset PROJECT_CERT_MANAGER
unset PROJECT_LICENSE_SERVICE
## There is no default value.  You can use any Red Hat OpenShift project; however, it is strongly recommended that you use ibm-cpd-scheduler. Do not co-locate the scheduling service with other software.
unset PROJECT_SCHEDULING_SERVICE
## watsonx Assistant or watsonx Orchestrate users only. The project where you want to install the IBM Events Operator or the project where a cluster-wide instance of the IBM Events Operator is already installed.
unset PROJECT_IBM_EVENTS
unset PROJECT_PRIVILEGED_MONITORING_SERVICE
unset PROJECT_CPD_INST_OPERATORS
unset PROJECT_CPD_INST_OPERANDS
unset PROJECT_CPD_INSTANCE_TETHERED
unset PROJECT_CPD_INSTANCE_TETHERED_LIST



# ------------------------------------------------------------------------------
# Storage
# ------------------------------------------------------------------------------

unset STG_CLASS_BLOCK
unset STG_CLASS_FILE

# ------------------------------------------------------------------------------
# IBM Entitled Registry
# ------------------------------------------------------------------------------

unset IBM_ENTITLEMENT_KEY


# ------------------------------------------------------------------------------
# Private container registry
# ------------------------------------------------------------------------------
# Set the following variables if you mirror images to a private container registry.
#
# To export these variables, you must uncomment each command in this section.

unset PRIVATE_REGISTRY_LOCATION
unset PRIVATE_REGISTRY_PUSH_USER
unset PRIVATE_REGISTRY_PUSH_PASSWORD
unset PRIVATE_REGISTRY_PULL_USER
unset PRIVATE_REGISTRY_PULL_PASSWORD


# ------------------------------------------------------------------------------
# IBM Software Hub version
# ------------------------------------------------------------------------------

unset VERSION


# ------------------------------------------------------------------------------
# Components
# ------------------------------------------------------------------------------

unset COMPONENTS
unset COMPONENTS_TO_SKIP
unset COMPONENTS_ADD


# ------------------------------------------------------------------------------
# watsonx Orchestrate
# ------------------------------------------------------------------------------
unset PROJECT_IBM_APP_CONNECT
unset AC_CASE_VERSION
unset AC_CHANNEL_VERSION
