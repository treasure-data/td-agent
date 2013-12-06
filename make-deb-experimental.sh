#!/bin/bash
version=`cat VERSION`
password=`cat PASSWORD`
dst=td-agent-experimental-$version
rev=`cat REVISION`

rm -fR fluentd
git clone git://github.com/fluent/fluentd.git
cd fluentd
git checkout $rev
cd ..
rm -fR $dst*
rm -fR td-agent-experimental_$version*
rm -fR *.dsc
cp -r fluentd $dst
cp -r debian $dst
cp td-agent.conf $dst
cp td-agent.prelink.conf $dst
cp td-agent.logrotate $dst
cp Makefile.am $dst
cp autogen.sh $dst
cp configure.in $dst
tar czf $dst.tar.gz $dst

pushd $dst
yes | dh_make -e k@treasure-data.com --single -f ../$dst.tar.gz
./autogen.sh
dpkg-buildpackage -rfakeroot -us -uc -S
popd

DISTS='lucid precise'
ARCHITECTURES='i386 amd64'

for dist in $DISTS; do
  for arc in $ARCHITECTURES; do
    echo $password | sudo -S ls
    echo td-agent-experimental_$version-1.dsc
    pbuilder-dist $dist $arc build td-agent-experimental_$version-1.dsc &
  done
done

wait

for dist in $DISTS; do
  for arc in $ARCHITECTURES; do
    echo $password | sudo -S ls
    mkdir -p $version/$dist
    cp ~/pbuilder/$dist-${arc}_result/td-agent-experimental_$version-1_$arc.deb $version/$dist
  done
done
cp td-agent-experimental_$version-1.dsc           $version/
cp td-agent-experimental_$version-1.debian.tar.gz $version/
cp td-agent-experimental_$version.orig.tar.gz     $version/

wait

tar czf $version.tar.gz $version
