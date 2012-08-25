#!/bin/bash
version=`cat VERSION`
dst=td-agent-$version
rev=`cat REVISION`
cur=`pwd`

# user defined revision
if [ ! -z "$1" ]; then
  rev=$1
  rpm_dist=$(echo $rev | cut -c1-10)
fi

# install required packages
yum install -y zlib-devel automake autoconf libtool auto-buildrequires openssl-devel

# setup td-agent-$version.tar.gz from fluentd.git
rm -fR fluentd
git clone git://github.com/fluent/fluentd.git
cd fluentd
git checkout $rev
cd ..
rm -fR $dst
mv fluentd $dst
cp td-agent.conf $dst
cp td-agent.prelink.conf $dst
cp Makefile.am $dst
cp autogen.sh $dst
cp configure.in $dst
tar czf $dst.tar.gz $dst
rm -fR $dst

# setup rpmbuild env
echo "%_topdir $cur/rpmbuild/" > ~/.rpmmacros
rm -fR rpmbuild
mkdir rpmbuild
pushd rpmbuild
mkdir BUILD RPMS SOURCES SPECS SRPMS
# locate spec
cp ../redhat/td-agent.spec SPECS
# locate source tarball
mv ../$dst.tar.gz SOURCES
# locate init.d script
cp ../redhat/td-agent.init SOURCES
# build
if [ -z "$rpm_dist" ]; then
  rpmbuild -v -ba --clean SPECS/td-agent.spec
else
  rpmbuild -v -ba --define "dist .${rpm_dist}" --clean SPECS/td-agent.spec
fi
popd
