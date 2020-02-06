VERBOSE=$1

INFO="---

"

#
# get info about cluster from kubeadm configmap
#

CLUSTER=$( kubectl get configmap kubeadm-config -n kube-system -o json | jq -r '.data.ClusterConfiguration' | yq -r '.' )
CLUSTER_NAME=$( echo $CLUSTER | jq -r '.clusterName' | sed -r 's/^./\U&/g' )
CLUSTER_SANS=$( echo $CLUSTER | jq -r '.apiServer.certSANs' )

INFO=$INFO"\
cluster:
  name: $CLUSTER_NAME
  services:
"

#
# get info about kubernetes service from apiserver pod
#

KUBERNETES=$( kubectl get pods -n kube-system kube-apiserver-$HOSTNAME -o json )
KUBERNETES_IPADDRESS=$( echo $KUBERNETES | sed -e 's/^.*"--advertise-address=\([^"]*\)".*$/\1/' )
KUBERNETES_PORT=$( echo $KUBERNETES | grep -e '--secure-port=' | sed -e 's/^.*"--secure-port=\([^"]*\)".*$/\1/' )

# we assume that the longest SAN is the FQDN
CLUSTER_HOST=''
for i in `seq 0 $( echo $CLUSTER_SANS | jq -r 'length - 1' )` ; do
    CLUSTER_HOST_CANDIDATE=$( echo $CLUSTER_SANS | jq -r --argjson i $i '.[$i]' )
    CLUSTER_IPADDRESS=$( nslookup $CLUSTER_HOST_CANDIDATE | grep -A 1 "Name:" | grep "Address:" | sed -e 's/^[^0-9]*\([0-9][0-9.]*\).*$/\1/' )
    if [ $CLUSTER_IPADDRESS = $KUBERNETES_IPADDRESS ] && [ ${#CLUSTER_HOST_CANDIDATE} > ${#CLUSTER_HOST} ] ; then
        CLUSTER_HOST=$CLUSTER_HOST_CANDIDATE
    fi
done
if [ $CLUSTER_HOST = '' ] ; then
    CLUSTER_HOST=$KUBERNETES_IPADDRESS
fi

INFO=$INFO"\
  -
    name: Kubernetes
    type: api
    urls:
    - $CLUSTER_HOST:$KUBERNETES_PORT
"

for i in `seq 0 $( echo $CLUSTER_SANS | jq -r 'length - 1' )` ; do
    ALIAS_HOST=$( echo $CLUSTER_SANS | jq -r --argjson i $i '.[$i]' )
    ALIAS_IPADDRESS=$( nslookup $ALIAS_HOST | grep -A 1 "Name:" | grep "Address:" | sed -e 's/^[^0-9]*\([0-9][0-9.]*\).*$/\1/' )
    if [ $ALIAS_IPADDRESS = $KUBERNETES_IPADDRESS ] && [ $ALIAS_HOST != $CLUSTER_HOST ] ; then
    INFO=$INFO"\
    - $ALIAS_HOST:$KUBERNETES_PORT
"
    fi
done
if [ $KUBERNETES_IPADDRESS != $CLUSTER_HOST ] ; then
    INFO=$INFO"\
    - $KUBERNETES_IPADDRESS:$KUBERNETES_PORT
"
fi

#
# get info about api-services from labeled services
#

SERVICES=$( kubectl get services -l 'kubernetes.io/cluster-service=true' --all-namespaces -o json )
for i in `seq 0 $( echo $SERVICES | jq '.items | length - 1' )`; do
    SERVICE_NAMESPACE=$( echo $SERVICES | jq -r --argjson i $i '.items[$i].metadata.namespace' )
    SERVICE_NAME=$( echo $SERVICES | jq -r --argjson i $i '.items[$i].metadata.name' )
    SERVICE_PORT=$( echo $SERVICES | jq -r --argjson i $i '.items[$i].spec.ports[0].name' )
    if [ $SERVICE_PORT = 'null' ] ; then
        SERVICE_PORT=$( echo $SERVICES | jq -r --argjson i $i '.items[$i].spec.ports[0].port' )
    fi
    SERVICE_SCHEME=''
    if [ $SERVICE_PORT = 'http' ] || [ $SERVICE_PORT = '80' ] ; then
        SERVICE_SCHEME='http:'
    elif [ $SERVICE_PORT = 'https' ] || [ $SERVICE_PORT = '443' ] ; then
        SERVICE_SCHEME='https:'
    fi
    SERVICE_DISPLAYNAME=$( echo $SERVICES | jq -r --argjson i $i '.items[$i].metadata.labels["kubernetes.io/name"]' )
    if [ $SERVICE_DISPLAYNAME = 'null' ] ; then
        SERVICE_DISPLAYNAME=$SERVICE_NAME
    fi

    INFO=$INFO"\
  -
    name: $SERVICE_DISPLAYNAME
    type: proxy
    urls:
    - https://$CLUSTER_HOST:$KUBERNETES_PORT/api/v1/namespaces/$SERVICE_NAMESPACE/services/$SERVICE_SCHEME$SERVICE_NAME:$SERVICE_PORT/proxy/
"
done

#
# get info about browser-services from labeled ingresses
#

SERVICES=$( kubectl get services -l 'app=kube-ingress-nginx,component=controller' --all-namespaces -o json )
for i in `seq 0 $( echo $SERVICES | jq '.items | length - 1' )`; do
   LB_IPADDRESS=$( echo $SERVICES | jq -r --argjson i $i '.items[$i].status.loadBalancer.ingress[0].ip' )
   if [ $LB_IPADDRESS != 'null' ] ; then
       break
   fi
done

if [ $LB_IPADDRESS != 'null' ] ; then
    INGRESSES=$( kubectl get ingresses -l 'kubernetes.io/cluster-service=true' --all-namespaces -o json )
else
    INGRESSES="[]"
fi
for i in `seq 0 $( echo $INGRESSES | jq '.items | length - 1' )`; do
    
    # first take the ingresses without 'server-alias' annotation
    ALIAS_ANNOTATION=$( echo $INGRESSES | jq -r --argjson i $i '.items[$i].metadata.annotations["nginx.ingress.kubernetes.io/server-alias"]' )
    if [ "$ALIAS_ANNOTATION" = 'null' ] ; then
        if [ "$( echo $INGRESSES | jq --argjson i $i '.items[$i].spec.tls' )" = 'null' ] ; then 
            SERVICE_SCHEME='http'
        else 
            SERVICE_SCHEME='https'
        fi
        SERVICE_HOST=$( echo $INGRESSES | jq -r --argjson i $i '.items[$i].spec.rules[0].host' )
        SERVICE_PATH=$( echo $INGRESSES | jq -r --argjson i $i '.items[$i].spec.rules[0].http.paths[0].path | capture("^(?<path>[^(]*)").path' )
        SERVICE_DISPLAYNAME=$( echo $INGRESSES | jq -r --argjson i $i '.items[$i].metadata.labels["kubernetes.io/name"]' )
        if [ $SERVICE_DISPLAYNAME = 'null' ] ; then
            SERVICE_DISPLAYNAME=$( echo $SERVICE_HOST | sed -e 's/^\([^.]*\)\..*$/\1/' )
        fi
        
        SERVICE_IPADDRESS=$( nslookup $SERVICE_HOST | grep -A 1 "Name:" | grep "Address:" | sed -e 's/^[^0-9]*\([0-9][0-9.]*\).*$/\1/' )
        if [ $SERVICE_IPADDRESS = $LB_IPADDRESS ] ; then
            INFO=$INFO"\
  -
    name: $SERVICE_DISPLAYNAME
    type: browser
    urls:
    - $SERVICE_SCHEME://$SERVICE_HOST$SERVICE_PATH
"
        else
            continue;
        fi

        # then take the aliases for this service
        for j in `seq 0 $( echo $INGRESSES | jq '.items | length - 1' )`; do
            ALIAS_ANNOTATION=$( echo $INGRESSES | jq -r --argjson j $j '.items[$j].metadata.annotations["nginx.ingress.kubernetes.io/server-alias"]' )
            if [ "$ALIAS_ANNOTATION" != 'null' ] ; then
                ALIAS_HOST=$( echo $INGRESSES | jq -r --argjson j $j '.items[$j].spec.rules[0].host' )
                ALIAS_DISPLAYNAME=$( echo $INGRESSES | jq -r --argjson j $j '.items[$j].metadata.labels["kubernetes.io/name"]' )
                if [ $ALIAS_DISPLAYNAME = 'null' ] ; then
                    ALIAS_DISPLAYNAME=$( echo $ALIAS_HOST | sed -e 's/^\([^.]*\)\..*$/\1/' )
                fi
            
                if [ $ALIAS_DISPLAYNAME = $SERVICE_DISPLAYNAME ] ; then
                    if [ "$( echo $INGRESSES | jq --argjson j $j '.items[$j].spec.tls' )" = 'null' ] ; then 
                        ALIAS_SCHEME='http'
                    else 
                        ALIAS_SCHEME='https'
                    fi
                    ALIAS_PATH=$( echo $INGRESSES | jq -r --argjson j $j '.items[$j].spec.rules[0].http.paths[0].path | capture("^(?<path>[^(]*)").path' )

                    ALIAS_IPADDRESS=$( nslookup $ALIAS_HOST | grep -A 1 "Name:" | grep "Address:" | sed -e 's/^[^0-9]*\([0-9][0-9.]*\).*$/\1/' )
                    if [ $ALIAS_IPADDRESS = $LB_IPADDRESS ] ; then
                        INFO=$INFO"\
    - $ALIAS_SCHEME://$ALIAS_HOST$ALIAS_PATH
"
                    fi

                    # finally add the hosts from the annotation
                    for ALIAS_HOST in $ALIAS_ANNOTATION ; do
                        ALIAS_IPADDRESS=$( nslookup $ALIAS_HOST | grep -A 1 "Name:" | grep "Address:" | sed -e 's/^[^0-9]*\([0-9][0-9.]*\).*$/\1/' )
                        if [ $ALIAS_IPADDRESS = $LB_IPADDRESS ] ; then
                            INFO=$INFO"\
    - $ALIAS_SCHEME://$ALIAS_HOST$ALIAS_PATH
"
                        fi
                    done
                fi
            fi
        done
    fi
done

#
# print collected info
#

if [ $VERBOSE = '-v' ] ; then
    COL_BLACK='\x1b[30;01m'
    COL_RED='\x1b[31;01m'
    COL_GREEN='\x1b[32;01m'
    COL_YELLOW='\x1b[33;01m'
    COL_BLUE='\x1b[34;01m'
    COL_MAGENTA='\x1b[35;01m'
    COL_CYAN='\x1b[36;01m'
    COL_WHITE='\x1b[37;01m'
    
    COL_YELLOWDIM='\x1b[38;5;142m'
    
    COL_RESET='\x1b[39;49;00m'

    echo
    CLUSTER=$( echo "$INFO" | yq -r '.cluster' )
    CLUSTER_NAME=$( echo $CLUSTER | jq -r '.name' )
    echo -e $COL_CYAN"$CLUSTER_NAME"$COL_RESET" cluster"

    LAST_TYPE=''
    for i in `seq 0 $( echo $CLUSTER  | jq -r '.services | length - 1' )` ; do
        SERVICE=$( echo $CLUSTER | jq --argjson i $i '.services[$i]' )
        SERVICE_NAME=$( echo $SERVICE | jq -r '.name' )
        SERVICE_TYPE=$( echo $SERVICE | jq -r '.type' )
        SERVICE_URLS=$( echo $SERVICE | jq -r '.urls' )
        SERVICE_URL=$( echo $SERVICE_URLS | jq -r '.[0]' )
    
        if [ $SERVICE_TYPE != "$LAST_TYPE" ] ; then
            LAST_TYPE=$SERVICE_TYPE
            echo
        fi
        echo -e $COL_GREEN"$SERVICE_NAME"$COL_RESET" is running at:"
        echo -e "        "$COL_YELLOW"$SERVICE_URL"$COL_RESET
        
        if [ $( echo $SERVICE_URLS  | jq -r '. | length' ) -gt 1 ] ; then
            echo -e "        aliases are:"
            for j in `seq 1 $( echo $SERVICE_URLS | jq -r '. | length - 1' )` ; do
                ALIAS_URL=$( echo $SERVICE_URLS | jq -r --argjson j $j '.[$j]' )
                echo -e "        "$COL_YELLOWDIM"$ALIAS_URL"$COL_RESET
            done
        fi
    done
    echo
else
    echo "$INFO"
fi
