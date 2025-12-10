#===============================================================================
# Raanon: curl_private.sh
# $0 [prc_name [pcr_port [pcr_host] ] ]

[[ -z $PCR_LOCATION ]] && echo "PRIVATE_REGISTRY variables not defined!" && exit

# Allow overriding defaults to create a particular (partial) PCR
if [[ $# > 0 ]]; then
	export PCR_NAME="$1"
	if [[ $# > 1 ]]; then
		export PCR_PORT="$2"
	else
		_container=$(podman ps | grep " ${PCR_NAME}$")
		_port=${_container#*0.0.0.0:}
		PCR_PORT=${_port%->*}
	fi
	[[ $# > 2 ]] && \
		PCR_HOST="$3"

	export PCR_OFFLINE="${WORKDIR}/${PCR_NAME}"
	export PCR_LOCATION="${PCR_HOST}:${PCR_PORT}"
fi

printf "Private Registry container: ${PCR_NAME}"
[[ $(podman ps | grep " ${PCR_NAME}$") == "" ]] && echo " NOT running!" && exit

printf "\ncurl -sS -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=1000 | jq -r .\n"
curl -sS -k -u ${PCR_PUSH_USER}:${PCR_PUSH_PASSWORD} https://${PCR_LOCATION}/v2/_catalog?n=1000 | jq -r .
