
DOWNLOAD=${WORKDIR}/Download

mkdir -p ${DOWNLOAD}/operators

OCP_OP_VER=4.17

cat <<EOF > ${DOWNLOAD}/operators/ocp-operators.yaml
apiVersion: mirror.openshift.io/v1alpha2
kind: ImageSetConfiguration
mirror:
  operators:
  - catalog: registry.redhat.io/redhat/redhat-operator-index:v${OCP_OP_VER}
    packages:
    - name: openshift-cert-manager-operator
      channels:
      - name: stable-v1
    - name: rhods-operator
      channels:
      - name: stable-2.13
EOF

oc mirror --config ${DOWNLOAD}/operators/ocp-operators.yaml file:///${DOWNLOAD}/operators

exit

#OCP_RELEASE=4.16.34
OCP_RELEASE=4.17.9
OC_MIRROR_REL=2.0.3
#OC_MIRROR_REL=2.05 # Pre-release
#IBM_PAK_REL=1.16.2
IBM_PAK_REL=1.17.0
CPD_CLI_REL=14.1.1

cat <<EOF > ${DOWNLOAD}/operators/ocp-operators.yaml
apiVersion: mirror.openshift.io/v1alpha2
kind: ImageSetConfiguration
mirror:
  operators:
  - catalog: registry.redhat.io/redhat/redhat-operator-index:v${OCP_OP_VER}
    packages:
    - name: ocs-operator
      channels:
      - name: stable-${OCP_OP_VER}
    - name: mcg-operator
      channels:
      - name: stable-${OCP_OP_VER}
    - name: serverless-operator
      channels:
      - name: stable
    - name: openshift-cert-manager-operator
      channels:
      - name: stable-v1
    - name: rhods-operator
      channel: stable-2.13
EOF

oc import-image odf4/odf-operator-bundle:v4.17.5-3 --from=registry.redhat.io/odf4/odf-operator-bundle:v4.17.5-3 --confirm

WORKDIR=/Install/CPD_5.1.1
PCR_TAR=/Install/CPD_5.1.1/Download/registry.tar
PCR_IMAGE=docker.io/library/registry:2.7
PCR_HOST=127.0.0.1
PCR_PORT=5005
PCR_NAME=cpd-private-registry
PCR_OFFLINE=/Install/CPD_5.1.1/cpd-private-registry
PCR_CERTFILE=cpd_pcr_domain
PCR_LOCATION=127.0.0.1:5005
PCR_PUSH_USER=admin
PCR_PUSH_PASSWORD=password

