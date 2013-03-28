#!/bin/bash

CACHE_DIR=~/.tda_cache

mkdir -p ac
mkdir -p $CACHE_DIR
test -f AUTHORS   || touch AUTHORS
test -f COPYING   || touch COPYING
test -f ChangeLog || touch ChangeLog
test -f NEWS      || touch NEWS
test -f NOTICE    || touch NOTICE
test -f README    || cp -f README.rdoc README

function download() {
    if [ ! -f "$2" ];then
        cache_file="$CACHE_DIR/$2"
        if [ -a "$cache_file" ]; then
            cp -f $cache_file .
        else
            wget "$1/$2" -O "$2" || exit 1
            cp -f $2 $cache_file
        fi
    fi
}

mkdir -p deps
mkdir -p deps/jemalloc
mkdir -p deps/ruby
mkdir -p plugins
cd deps
download "http://www.canonware.com/download/jemalloc" "jemalloc-2.2.5.tar.bz2"
download "http://ftp.ruby-lang.org/pub/ruby/1.9" "ruby-1.9.3-p194.tar.bz2"
download "http://rubygems.org/downloads" "bundler-1.2.5.gem"
download "http://rubygems.org/downloads" "json-1.5.2.gem"
download "http://rubygems.org/downloads" "msgpack-0.4.4.gem"
download "http://rubygems.org/downloads" "iobuffer-0.1.3.gem"
download "http://rubygems.org/downloads" "cool.io-1.1.0.gem"
download "http://rubygems.org/downloads" "http_parser.rb-0.5.1.gem"
download "http://rubygems.org/downloads" "yajl-ruby-1.0.0.gem"
download "http://rubygems.org/downloads" "jeweler-1.6.2.gem"
cd ..

echo "#!/bin/sh

##
## Generated by autogen.sh
##

version=\`cat VERSION\`
dst=fluentd-\$version
rm -rf \$dst
mkdir \$dst || exit 1
cp -fpR lib bin \$dst/ || exit 1
mkdir -p \$dst/deps || exit 1
mkdir -p \$dst/pkg || exit 1
cp pkg/fluentd-\$version.gem \$dst/pkg/
cp deps/*.gem deps/ruby-*.tar.bz2 deps/jemalloc-*.tar.bz2 \$dst/deps/
cp README.rdoc README COPYING NEWS ChangeLog AUTHORS INSTALL NOTICE \\
    configure.in Makefile.in Makefile.am configure aclocal.m4 \\
    Rakefile VERSION fluent.conf make_dist.sh \\
    \$dst/ || exit 1
cp -f README.rdoc \$dst/README || exit 1
mkdir -p \$dst/ac || exit 1
cp ac/* \$dst/ac/ || exit 1
tar czvf \$dst.tar.gz \$dst || exit 1
rm -rf \$dst
" > make_dist.sh
chmod 755 make_dist.sh

if [ x`uname` = x"Darwin" ]; then
    glibtoolize --force --copy
else
    libtoolize --force --copy
fi
aclocal
#autoheader
automake --add-missing --copy
autoconf

rmdir deps/jemalloc 2>/dev/null
rmdir deps/ruby 2>/dev/null

