#!/bin/bash
# https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-cpdctl_install

DOWNLOAD=${WORKDIR}/Download

platform=$(uname -s | tr '[A-Z]' '[a-z]')
arch=$(uname -m | sed 's/x86_64/amd64/')
TARFILE="cpdctl_${platform}_${arch}.tar.gz"

# version="latest/download" # "download/v1.7.16"
version="download/v1.6.95" # For wxd 2.1.1
# https://github.com/IBM/cpdctl/releases/download/v1.7.16/cpdctl_linux_amd64.tar.gz
# https://github.com/IBM/cpdctl/releases/download/v1.6.95/cpdctl_linux_amd64.tar.gz

echo curl --output-dir $DOWNLOAD -LOs "https://github.com/IBM/cpdctl/releases/${version}/${TARFILE}"
curl --output-dir $DOWNLOAD -LOs "https://github.com/IBM/cpdctl/releases/${version}/${TARFILE}"
ls -l ${DOWNLOAD}/${TARFILE}
[[ -f ${DOWNLOAD}/${TARFILE} ]] && \
	tar -C ${WORKDIR}/bin -xvf ${DOWNLOAD}/${TARFILE}   cpdctl && \
	chmod +x ${WORKDIR}/bin/cpdctl && \
	ls -l ${WORKDIR}/bin/cpdctl


exit
###################################

# https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-cpdctl_install
# watsonx.data version 		cpdctl version
# v2.1.1			v1.6.95 and later
# v2.1.1 (Developer edition)	1.6.104 and later
# v2.1.2			v1.7.0 and later

[root@RaanonD-node-2 CPD_5.1.1]# repo_sizes.sh --pcr cpd-priv-reg-xdata watsonx-data
Private Registry container: cpd-priv-reg-xdata

REPO_SEARCH = watsonx-data
curl -sS -k -u admin:password https://127.0.0.1:5006/v2/_catalog?n=1000
0== MB == : ====== REPO ========                               : VV : ===== TAG ============
   55.505 : cp/watsonx-data/ibm-lh-cas                         : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  304.153 : cp/watsonx-data/ibm-lh-ces                         : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  601.590 : cp/watsonx-data/ibm-lh-control-plane-prereq        : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  387.851 : cp/watsonx-data/ibm-lh-cpg                         : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
   83.209 : cp/watsonx-data/ibm-lh-etcd                        : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  408.656 : cp/watsonx-data/ibm-lh-kafka                       : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
 1402.902 : cp/watsonx-data/ibm-lh-mds-rest                    : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
 1366.673 : cp/watsonx-data/ibm-lh-mds-thrift                  : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
 1671.142 : cp/watsonx-data/ibm-lh-milvus                      : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
   97.724 : cp/watsonx-data/ibm-lh-minio                       : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  108.566 : cp/watsonx-data/ibm-lh-otelcollector               : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  241.354 : cp/watsonx-data/ibm-lh-prestissimo                 : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
 4627.668 : cp/watsonx-data/ibm-lh-presto                      : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  467.129 : cp/watsonx-data/ibm-lh-qhmm                        : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
 1159.388 : cp/watsonx-data/ibm-lh-tools                       : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
 1251.246 : cp/watsonx-data/ibm-lh-validator                   : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  183.008 : cp/watsonx-data/lhconsole-api                      : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  192.151 : cp/watsonx-data/lhconsole-nodeclient               : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
  177.414 : cp/watsonx-data/lhconsole-ui                       : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
 1329.193 : cp/watsonx-data/lhingestion-api                    : v2 : 2.1.1-353-20250207-091522-onprem-v2.1.1
0== MB == : ====== REPO ========                               : VV : ===== TAG ============
 16116.532 : Total MB

