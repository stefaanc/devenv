#!/bin/bash

CLUSTERNAME=$1
COMMAND=$2
PARAMETER1="$3"
PARAMETER2="$4"
PARAMETER3="$5"

if [ $COMMAND = 'timeout' ] ; then
    echo "#"
    echo "# Set timeout for dashboard"
    echo "#"
    echo "# timout=$PARAMETER1"
    echo "#"

    RESOURCE=$( kubectl get deployment -l "app=kube-dashboard" -n kube-dashboard -o name )
    ARGS=$( kubectl get $RESOURCE -n kube-dashboard -o jsonpath='{.spec.template.spec.containers[0].args}' | sed -e 's/--/\n/g' )
    TOKEN_TTL=$( echo "$ARGS" | awk '/token-ttl=/ {print NR-2}' )
    if ! [ $TOKEN_TTL ] ; then
        OP='add'
        TOKEN_TTL='-'
    else
        OP='replace'
    fi

    kubectl patch $RESOURCE -n kube-dashboard --type json --patch "
- op: $OP
  path: /spec/template/spec/containers/0/args/$TOKEN_TTL
  value: --token-ttl=$PARAMETER1
    "
    echo ""
elif [ $COMMAND = 'banner' ] ; then
    echo "#"
    echo "# Set banner for dashboard"
    echo "#"

    if [ $PARAMETER1 = 'NONE' ] ; then
        PARAMETER1="INFO"
        PARAMETER2=""
    elif [ $PARAMETER1 = 'DEFAULT' ] ; then
        PARAMETER1="INFO"
        PARAMETER2="Kubernetes Dashboard for the <strong>$( echo $CLUSTERNAME | sed -r 's/^./\U&/g' )</strong> cluster"
    fi

    echo "# banner-severity=$PARAMETER1"
    echo "# banner-text=$PARAMETER2"
    echo "#"

    RESOURCE=$( kubectl get deployment -l "app=kube-dashboard" -n kube-dashboard -o name )
    ARGS=$( kubectl get $RESOURCE -n kube-dashboard -o jsonpath='{.spec.template.spec.containers[0].args}' | sed -e 's/--/\n/g' )
    SYSTEM_BANNER_SEVERITY=$( echo "$ARGS" | awk '/system-banner-severity=/ {print NR-2}' )
    if ! [ $SYSTEM_BANNER_SEVERITY ] ; then
        OP1='add'
        SYSTEM_BANNER_SEVERITY='-'
    else
        OP1='replace'
    fi
    SYSTEM_BANNER=$( echo "$ARGS" | awk '/system-banner=/ {print NR-2}' )
    if ! [ $SYSTEM_BANNER ] ; then
        OP2='add'
        SYSTEM_BANNER='-'
    else
        OP2='replace'
    fi

    kubectl patch $RESOURCE -n kube-dashboard --type json --patch "
- op: $OP1
  path: /spec/template/spec/containers/0/args/$SYSTEM_BANNER_SEVERITY
  value: --system-banner-severity=$PARAMETER1
- op: $OP2
  path: /spec/template/spec/containers/0/args/$SYSTEM_BANNER
  value: --system-banner=$PARAMETER2
    "
    echo ""
else
    echo "#"
    echo "# Supported options are:"
    echo "#"
    echo "# <clustername> timeout <nbr of seconds>"
    echo "#"
    echo "# <clustername> banner NONE"
    echo "# <clustername> banner DEFAULT"
    echo "# <clustername> banner INFO \"<text, optionally including simple html tags>\""
    echo "# <clustername> banner WARNING \"<text, optionally including simple html tags>\""
    echo "# <clustername> banner ERROR \"<text, optionally including simple html tags>\""
    echo "#"
    echo ""
fi

