#===============================================================================
# Raanon: approve_all_csr.sh

oc get csr -o name | xargs oc adm certificate approve
