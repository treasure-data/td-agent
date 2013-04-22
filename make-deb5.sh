#!/bin/bash
version=`cat VERSION`
password=`cat PASSWORD`
dst=td-agent-$version
rev=`cat REVISION`

rm -fR fluentd
git clone git://github.com/fluent/fluentd.git
cd fluentd
git checkout $rev
cd ..
rm -fR $dst*
rm -fR td-agent_$version*
rm -fR *.dsc
cp -r fluentd $dst
cp -r debian $dst
cp td-agent.conf $dst
cp td-agent.prelink.conf $dst
cp Makefile.am $dst
cp td-agent.logrotate $dst
cp autogen.sh $dst
cp configure.in $dst
tar czf $dst.tar.gz $dst

pushd $dst
yes | dh_make -e k@treasure-data.com --single -f ../$dst.tar.gz
./autogen.sh
dpkg-buildpackage -rfakeroot -us -uc -b
popd
