#!/bin/bash
sudo apt-get install git-core

DISTS='squeeze lenny lucid maverick'
ARCHITECTURES='i386 amd64'

sudo ls -al
for dist in $DISTS; do
  for arc in $ARCHITECTURES; do
    pbuilder-dist $dist $arc create &
  done
done

wait