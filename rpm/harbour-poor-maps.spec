# Prevent brp-python-bytecompile from running.
%define __os_install_post %{___build_post}

# "Harbour RPM packages should not provide anything".
%define __provides_exclude_from ^%{_datadir}/.*$

Name: harbour-poor-maps
Version: 0.19
Release: 1
Summary: An application to display maps and stuff
License: GPLv3+
URL: http://github.com/otsaloma/poor-maps
Source: %{name}-%{version}.tar.xz
BuildArch: noarch
BuildRequires: make
Requires: libkeepalive
Requires: libsailfishapp-launcher
Requires: pyotherside-qml-plugin-python3-qt5 >= 1.2
Requires: qt5-plugin-geoservices-nokia
Requires: qt5-qtdeclarative-import-location
Requires: qt5-qtdeclarative-import-positioning >= 5.2
Requires: sailfishsilica-qt5

%description
Poor Maps is an application for Sailfish OS to display tiled maps
(e.g. OpenStreetMap), places and routes with a flexible selection
of data and service providers.

%prep
%setup -q

%install
make DESTDIR=%{buildroot} PREFIX=/usr install

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
