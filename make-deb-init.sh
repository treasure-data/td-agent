#!/bin/bash
password=`cat PASSWORD`

echo $password | sudo -S apt-get install git-core

DISTS='lucid'
ARCHITECTURES='i386 amd64'

for dist in $DISTS; do
  for arc in $ARCHITECTURES; do
    echo $password | sudo -S ls -al
    pbuilder-dist $dist $arc create &
  done
done

wait
