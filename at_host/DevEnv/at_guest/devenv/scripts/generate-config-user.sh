#!/bin/bash

CLUSTERNAME=$1
NAMESPACE=$2
SERVERNAME=$3
USERNAME=$4
LOCAL="$5"

if ! [ -d ~/.certs/$USERNAME ] ; then
    mkdir -p ~/.certs/$USERNAME
fi

if ! [ -z $LOCAL ] ; then
    FILENAME=$USERNAME@$SERVERNAME
else 
    FILENAME=$USERNAME@$SERVERNAME.$CLUSTERNAME
fi

echo "#"
echo "# create config"
echo "#"

if [ $SERVERNAME = 'kubernetes' ] ; then
    cp -f ~/devenv/config/devenv-pki/user@kubernetes.$CLUSTERNAME.conf.tpl ~/.certs/$USERNAME/$FILENAME.conf
else
    cp -f ~/devenv/config/devenv-pki/user.conf.tpl ~/.certs/$USERNAME/$FILENAME.conf
fi

sed -i "s/<username>/${USERNAME}/g" ~/.certs/$USERNAME/$FILENAME.conf
sed -i "s/<namespace>/${NAMESPACE}/g" ~/.certs/$USERNAME/$FILENAME.conf

if ! [ -z $LOCAL ] ; then
    IPADDR=$( ifconfig eth0 | grep 'inet ' | awk '{print $2}' )
    sed -i -e "s/<clustername>/kubernetes/g" -e "s+://kubernetes+://$IPADDR+g" ~/.certs/$USERNAME/$FILENAME.conf
 
    CA_DATA=$( base64 -w 0 ~/.certs/$USERNAME/ca@$SERVERNAME.$CLUSTERNAME.crt | sed -e "s/[\/&]/\\\\&/g" ) 
    sed -i "s/certificate-authority/certificate-authority-data/" ~/.certs/$USERNAME/$FILENAME.conf
    sed -i "s/<ca-crt>/${CA_DATA}/" ~/.certs/$USERNAME/$FILENAME.conf
    CC_DATA=$( base64 -w 0 ~/.certs/$USERNAME/$USERNAME@$SERVERNAME.$CLUSTERNAME.crt | sed -e "s/[\/&]/\\\\&/g" ) 
    sed -i "s/client-certificate/client-certificate-data/" ~/.certs/$USERNAME/$FILENAME.conf
    sed -i "s/<client-crt>/${CC_DATA}/" ~/.certs/$USERNAME/$FILENAME.conf
    CK_DATA=$( base64 -w 0 ~/.certs/$USERNAME/$USERNAME@$SERVERNAME.$CLUSTERNAME.key | sed -e "s/[\/&]/\\\\&/g" ) 
    sed -i "s/client-key/client-key-data/" ~/.certs/$USERNAME/$FILENAME.conf
    sed -i "s/<client-key>/${CK_DATA}/" ~/.certs/$USERNAME/$FILENAME.conf
else 
    sed -i "s/<clustername>/${CLUSTERNAME}/g" ~/.certs/$USERNAME/$FILENAME.conf

    sed -i "s+<ca-crt>+../.certs/$USERNAME/ca@$SERVERNAME.$CLUSTERNAME.crt+" ~/.certs/$USERNAME/$FILENAME.conf
    sed -i "s+<client-crt>+../.certs/$USERNAME/$FILENAME.crt+" ~/.certs/$USERNAME/$FILENAME.conf
    sed -i "s+<client-key>+../.certs/$USERNAME/$FILENAME.key+" ~/.certs/$USERNAME/$FILENAME.conf
fi
echo ""

echo "#"
echo "# secure config"
echo "#"

chmod 700 ~/.certs
chmod 700 ~/.certs/$USERNAME
chmod 600 ~/.certs/$USERNAME/$FILENAME.conf

if getent passwd $USERNAME >/bin/null ; then
    if ! [ -d /home/$USERNAME/.certs/$USERNAME ] ; then
        mkdir -p /home/$USERNAME/.certs/$USERNAME
    fi
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs/$USERNAME
    chmod 700 /home/$USERNAME/.certs
    chmod 700 /home/$USERNAME/.certs/$USERNAME

    cp -f ~/.certs/$USERNAME/$FILENAME.conf /home/$USERNAME/.certs/$USERNAME
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs/$USERNAME/$FILENAME.conf

    if ! [ -d /home/$USERNAME/.kube ] ; then
        mkdir -p /home/$USERNAME/.kube
    fi
    chown $USERNAME:$USERNAME /home/$USERNAME/.kube
    chmod 700 /home/$USERNAME/.kube

    cp -f ~/.certs/$USERNAME/$FILENAME.conf /home/$USERNAME/.kube
    chown $USERNAME:$USERNAME /home/$USERNAME/.kube/$FILENAME.conf
fi

echo ""