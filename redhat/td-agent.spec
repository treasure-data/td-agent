Summary: td-agent
Name: td-agent
Version: 1.0
License: Apache
Release: 0%{?dist}

Group: Application/Text
Vendor: Vendor
URL: URL
Source: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)

Requires: /usr/sbin/useradd /usr/sbin/groupadd
Requires: /sbin/chkconfig
Requires: openssl readline
Requires(pre): shadow-utils
Requires(build): gcc gcc-c++ pkgconfig libtool openssl-devel readline-devel

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
make install DESTDIR=$RPM_BUILD_ROOT INSTALL="install -p"

%clean
rm -rf $RPM_BUILD_ROOT

%post
echo "adding 'td-agent' group..."
getent group td-agent >/dev/null || /usr/sbin/groupadd -r td-agent
echo "adding 'td-agent' user..."
getent passwd td-agent >/dev/null || \
  /usr/sbin/useradd --home-dir /home/td-agent/ --no-create-home -r -g td-agent -c 'td-agent' td-agent

%files
%defattr(-,root,root)
/

%changelog
* Mon Aug 01 2011 Kazuki Ohta <kazuki.ohta@gmail.com> - 1.0.0
- initial packaging for Scientific Linux 6
