#===============================================================================
# Raanon: curl_intermed.sh

podman exec -it olm-utils-play-v3 bash -c "curl --insecure -sS 'https://127.0.0.1:12443/v2/_catalog?n=1000' | jq -r ."
