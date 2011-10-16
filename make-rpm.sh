#!/bin/bash
version=`cat VERSION`
dst=td-agent-$version
cur=`pwd`

# install required packages
yum install zlib-devel automake autoconf libtool auto-buildrequires openssl-devel

# setup td-agent-$version.tar.gz from fluentd.git
rm -fR fluentd
git clone git://github.com/fluent/fluentd.git
rm -fR $dst
mv fluentd $dst
cp td-agent.conf $dst
cp Makefile.am $dst
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
rpmbuild -v -bb --clean SPECS/td-agent.spec
popd
