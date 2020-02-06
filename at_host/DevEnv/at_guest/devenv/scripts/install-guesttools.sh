#!/bin/bash

echo "#"
echo "# install jq"
echo "#"

yum -y install jq
echo ""

echo "#"
echo "# install yq"
echo "#"

yum -y install python-pip
pip install --upgrade pip
pip install yq
echo ""
