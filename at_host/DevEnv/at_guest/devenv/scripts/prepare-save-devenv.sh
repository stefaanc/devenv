#!/bin/bash

DISKNAME=$1

rm -f ~/devenv/taints/restored-devenv-$DISKNAME
date > ~/devenv/taints/saved-devenv-$DISKNAME