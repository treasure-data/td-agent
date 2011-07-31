#!/bin/bash
version=`cat VERSION`
dst=td-agent-$version

rm -fR fluent
git clone git@github.com:fluent/fluent.git
rm -fR $dst
cp -r fluent $dst
cp -r debian $dst
tar czf $dst.tar.gz $dst

pushd $dst
yes | dh_make -e k@treasure-data.com --single -f ../td-agent-1.0.tar.gz
./autogen.sh
dpkg-buildpackage -rfakeroot -b
popd
