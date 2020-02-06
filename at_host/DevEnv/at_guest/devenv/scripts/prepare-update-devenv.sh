#!/bin/bash

echo "#"
echo "# delete devenv directories and files"
echo "#"

rm -rfv devenv/config/devenv-pki/*    # files and folders
rm -rfv devenv/config/devenv-shells/* # files and folders 
find devenv/config/helm-charts/ -mindepth 1 -maxdepth 1 -type d -exec rm -rfv '{}' \;    # folders only
find devenv/config/kube-manifests/ -mindepth 1 -maxdepth 1 -type d -exec rm -rfv '{}' \; # folders only
rm -rfv devenv/scripts/* # files and folders
echo ""
