Summary: experimental td-agent
Name: td-agent-experimental
Version: 1.1.18
License: APL2
Release: 0%{?dist}

Group: System Environment/Daemons
Vendor: Treasure Data, Inc.
URL: http://treasure-data.com/
Source: %{name}-%{version}.tar.gz
Source1: td-agent.init
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)

Requires: /usr/sbin/useradd /usr/sbin/groupadd
Requires: /sbin/chkconfig
Requires: openssl readline libxslt libxml2 td-libyaml
Requires(pre): shadow-utils
Requires(post): /sbin/chkconfig
Requires(post): /sbin/service
Requires(preun): /sbin/chkconfig
Requires(preun): /sbin/service
BuildRequires: gcc gcc-c++ pkgconfig libtool openssl-devel readline-devel libxslt-devel libxml2-devel
Obsoletes: td-agent

# 2011/08/01 Kazuki Ohta <kazuki.ohta@gmail.com>
# prevent stripping the debug info.
%define debug_package %{nil}
%define __strip /bin/true

%description

%prep

%setup -q

%build
./autogen.sh

%configure
make %{?_smp_mflags}

%install
# cleanup first
rm -rf $RPM_BUILD_ROOT
# install programs
make install DESTDIR=$RPM_BUILD_ROOT INSTALL="install -p"
# install init.d script
mkdir -p $RPM_BUILD_ROOT/etc/init.d/
install -m 755 %{S:1} $RPM_BUILD_ROOT/etc/init.d/td-agent
# create log dir
mkdir -p $RPM_BUILD_ROOT/var/log/td-agent

%clean
rm -rf $RPM_BUILD_ROOT

%post
echo "adding 'td-agent' group..."
getent group td-agent >/dev/null || /usr/sbin/groupadd -r td-agent
echo "adding 'td-agent' user..."
getent passwd td-agent >/dev/null || \
  /usr/sbin/useradd -r -g td-agent -d %{_localstatedir}/lib/td-agent -s /sbin/nologin -c 'td-agent' td-agent
chown -R td-agent:td-agent /var/log/td-agent
if [ ! -e "/etc/td-agent/td-agent.conf" ]; then
  echo "Installing default conffile $CONFFILE ..."
  cp -f /etc/td-agent/td-agent.conf.tmpl /etc/td-agent/td-agent.conf
fi

# 2011/11/13 Kazuki Ohta <k@treasure-data.com>
# This prevents prelink, to break the Ruby intepreter.
if [ -d "/etc/prelink.conf.d/" ]; then
  echo "prelink detected. Installing /etc/prelink.conf.d/td-agent-ruby.conf ..."
  cp -f /etc/td-agent/prelink.conf.d/td-agent.conf /etc/prelink.conf.d/td-agent-ruby.conf
elif [ -f "/etc/prelink.conf" ]; then
  if [ $(grep '\-b /usr/lib{,64}/fluent/ruby/bin/ruby' -c /etc/prelink.conf) -eq 0 ]; then
    echo "prelink detected, but /etc/prelink.conf.d/ dosen't exist. Adding /etc/prelink.conf ..."
    echo "-b /usr/lib{,64}/fluent/ruby/bin/ruby" >> /etc/prelink.conf
  fi
fi

# 2013/03/04 Kazuki Ohta <k@treasure-data.com>
# Install log rotation script.
if [ -d "/etc/logrotate.d/" ]; then
  cp -f /etc/td-agent/logrotate.d/td-agent.logrotate /etc/logrotate.d/td-agent
fi

# 2011/11/13 Kazuki Ohta <k@treasure-data.com>
# Before td-agent v1.1.0, fluentd has a bug of loading plugin before changing
# to the right user. Then, these directories were created with root permission.
# The following lines fix that problem.
if [ -d "/var/log/td-agent/buffer/" ]; then
  chown -R td-agent:td-agent /var/log/td-agent/buffer/
fi
if [ -d "/tmp/fluent/" ]; then
  chown -R td-agent:td-agent /tmp/fluent/
fi

echo "Configure td-agent to start, when booting up the OS..."
/sbin/chkconfig --add td-agent

# 2011/03/24 Kazuki Ohta <k@treasure-data.com>
# When upgrade, restart agent if it's launched
if [ "$1" = "2" ]; then
  /sbin/service td-agent condrestart >/dev/null 2>&1 || :
fi

%preun
# 2011/02/21 Kazuki Ohta <k@treasure-data.com>
# Just leave this file, because this line could delete td-agent.conf in a
# *UPGRADE* process :-(
# if [ -e "/etc/prelink.conf.d/td-agent-ruby.conf" ]; then
#   echo "Uninstalling /etc/prelink.conf.d/td-agent-ruby.conf ..."
#   rm -f /etc/prelink.conf.d/td-agent-ruby.conf
# fi
if [ $1 = 0 ] ; then
  echo "Stopping td-agent ..."
  /sbin/service td-agent stop >/dev/null 2>&1 || :
  /sbin/chkconfig --del td-agent
fi

%files
%defattr(-,root,root)
/usr/bin/td
/usr/sbin/td-agent
/usr/%{_lib}/fluent
/etc/td-agent
/etc/init.d/td-agent
/var/log/td-agent

%changelog
* Thu Dec 6 2013 Masahiro Nakagawa <masa@treasure-data.com>
- v1.1.18
- jemalloc v3.4.1
- ruby v2.0.0-p353
- bundle v1.3.5
- json 1.8.1
- cool.io v1.2.0
- msgpack v0.5.7
