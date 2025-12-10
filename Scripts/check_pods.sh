#===============================================================================
# Raanon: check_pods.sh

oc get pods -A | egrep -v -e "(.+)/\1" -e Completed

oc get pods -A -o=custom-columns=":spec.nodeName,STATUS:.status.phase" --no-headers | sed -E 's/Running|Succeeded/OK/' | sort | uniq -c

#oc get pods -A -o custom-columns="STATUS:.status.phase" --no-headers | sort | uniq -c

#oc get pods -A -o=custom-columns=":spec.nodeName" --no-headers | sort | uniq -c
