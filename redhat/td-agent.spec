Summary: td-agent
Name: td-agent
Version: 1.1.8
License: APL2
Release: 0%{?dist}

Group: System Environment/Daemons
Vendor: Treasure Data, Inc.
URL: http://treasure-data.com/
Source: %{name}-%{version}.tar.gz
Source1: %{name}.init
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
install -m 755 %{S:1} $RPM_BUILD_ROOT/etc/init.d/%{name}
# create log dir
mkdir -p $RPM_BUILD_ROOT/var/log/%{name}

%clean
rm -rf $RPM_BUILD_ROOT

%post
echo "adding 'td-agent' group..."
getent group td-agent >/dev/null || /usr/sbin/groupadd -r td-agent
echo "adding 'td-agent' user..."
getent passwd td-agent >/dev/null || \
  /usr/sbin/useradd -r -g td-agent -d %{_localstatedir}/lib/td-agent -s /sbin/nologin -c 'td-agent' td-agent
chown -R td-agent:td-agent /var/log/%{name}
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
/usr
/etc/td-agent
/etc/init.d/td-agent
/var/log/td-agent

%changelog
* Mon Jul 23 2012 Kazuki Ohta <k@treasure-data.com>
- fluentd v0.10.25
- fix critical problem of duplicate daemon launching

* Mon Jun 11 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.7
- bson_ext v1.6.4
- bson v1.6.4
- mongo v1.6.4
- fluent-plugin-td v0.10.7
- td v0.10.25 (new)
- install /usr/bin/td (new)

* Sun May 20 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.6
- remove ruby package dependency
- fluent-plugn-flume v0.1.1 (new)

* Wed May 02 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.5.1
- fluentd v0.10.22

* Tue May 01 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.5
- ruby v1.9.3-p194 (security fix)
- fluentd v0.10.21
- add --with-libyaml-dir to ruby's configure options

* Mon Apr 23 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.4.4
- depends on td-libyaml for both RHEL5 and RHEL6

* Sat Apr 17 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.4
- use ruby-1.9.3-p125
- use jemalloc v2.2.5, to avoid memory fragmentations
- fluentd v0.10.19
- fluent-plugin-mongo v0.6.7
- fluent-plugin-td v0.10.6

* Sat Mar 25 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.3.1
- fix not to start td-agent daemon, when installing. thx @moriyoshi.
- various fix for CentOS 4 (prelink & status). thx @riywo.

* Sun Mar 10 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.3
- fluent-plugin-mongo v0.6.6

* Wed Feb 22 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.2.2
- fix package dependency

* Tue Feb 21 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.2.1
- fix not to remove prelink file, when updating the package

* Wed Feb 08 2012 Kazuki Ohta <k@treasure-data.com>
- v1.1.2
- fluentd v0.10.10
- fluent-plugin-td v0.10.5
- fluent-plugin-scribe v0.10.7
- fluent-plugin-mongo v0.6.3

* Mon Jan 23 2012 Kazuki Ohta <k@treasure-data.com>
- fluentd v0.10.9
- fluent-plugin-scribe v0.10.6
- fluent-plugin-mongo v0.6.2
- fluent-plugin-s3 v0.2.2 (new)
- fix /var/run/td-agent/ creation in init.d script
- fix Ruby interpreter breakinb by prelink, on 32-bit platform

* Fri Nov 11 2011 Kazuki Ohta <k@treasure-data.com>
- fluentd v0.10.6
- fluent-plugin-td v0.10.2
- fluent-plugin-scribe v0.10.3
- fluent-plugin-mongo v0.4.0 (new)
- prevent Ruby interpreter breaking by prelink

* Mon Oct 10 2011 Kazuki Ohta <k@treasure-data.com>
- fix gem installation order

* Mon Oct 05 2011 Kazuki Ohta <k@treasure-data.com>
- fix posinst

* Mon Oct 01 2011 Kazuki Ohta <k@treasure-data.com>
- fluent v0.9.16
- fluent-plugin-scribe v0.9.10

* Mon Sep 20 2011 Kazuki Ohta <k@treasure-data.com>
- fluent v0.9.14
- fluent-plugin-td v0.9.10

* Mon Sep 20 2011 Kazuki Ohta <k@treasure-data.com>
- fluent v0.9.13

* Mon Sep 16 2011 Kazuki Ohta <k@treasure-data.com>
- fluent v0.9.10
- fluent-plugin-scribe v0.9.8

* Mon Sep 05 2011 Kazuki Ohta <k@treasure-data.com>
- fluent v0.9.9
- add fluent-plugin-scribe gem

* Sun Aug 18 2011 Kazuki Ohta <k@treasure-data.com>
- fluent v0.9.8

* Sun Aug 07 2011 Kazuki Ohta <k@treasure-data.com>
- fix calling undefined function in daemon mode

* Sun Aug 07 2011 Kazuki Ohta <k@treasure-data.com>
- fluent v0.9.7, with fluent-plugin-td gem

* Mon Aug 01 2011 Kazuki Ohta <k@treasure-data.com>
- fluent v0.9.5. initial packaging for Scientific Linux 6
