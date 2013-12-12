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
yum install -y wget make rpmbuild gcc gcc-c++ readline-devel openssl-devel libxml2-devel libxslt-devel zlib-devel automake autoconf libtool auto-buildrequires openssl-devel

# setup td-agent-$version.tar.gz from fluentd.git
rm -fR fluentd
git clone git://github.com/fluent/fluentd.git
cd fluentd
git checkout -b $rev # -b: don't show message to suggest 'you are not anywhere' of git
cd ..
rm -fR $dst
mv fluentd $dst
cp td-agent.conf $dst
if [ -f redhat/td-agent.conf.custom ]; then
  cp redhat/td-agent.conf.custom $dst
fi
cp td-agent.prelink.conf $dst
cp Makefile.am $dst
cp autogen.sh $dst
cp configure.in $dst
cp ./td-agent.logrotate $dst
# locate pre-downloaded gems
if [ -d plugin_gems ]; then
  mkdir -p $dst/plugins
  cp plugin_gems/*.gem $dst/plugins
fi
tar czf $dst.tar.gz $dst
rm -fR $dst

# setup rpmbuild env
my_rpmbuild() {
  rpmbuild --define "_topdir $cur/rpmbuild/" "$@"
}
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
# locate customized configuration file
if [ -f ../redhat/td-agent.conf.custom ]; then
  cp ../redhat/td-agent.conf.custom SOURCES
fi
# build
if [ -z "$rpm_dist" ]; then
  my_rpmbuild -v -ba --clean SPECS/td-agent.spec
else
  my_rpmbuild -v -ba --define "dist .${rpm_dist}" --clean SPECS/td-agent.spec
fi
popd
