# Prevent brp-python-bytecompile from running.
%define __os_install_post %{___build_post}

# "Harbour RPM packages should not provide anything".
%define __provides_exclude_from ^%{_datadir}/.*$

Name: harbour-poor-maps
Version: 0.26
Release: 1
Summary: Maps and navigation
License: GPLv3+
URL: http://github.com/otsaloma/poor-maps
Source: %{name}-%{version}.tar.xz
BuildArch: noarch
BuildRequires: make
Requires: libkeepalive
Requires: libsailfishapp-launcher
Requires: pyotherside-qml-plugin-python3-qt5 >= 1.2
Requires: qt5-plugin-geoservices-here
Requires: qt5-qtdeclarative-import-location
Requires: qt5-qtdeclarative-import-positioning >= 5.2
Requires: sailfishsilica-qt5

%description
View maps, find places and routes, navigate with turn-by-turn instructions,
search for nearby places by type and share your location.

Poor Maps supports a variety of mainly OpenStreetMap-based providers of maps
and related services, from which you can freely choose depending on your
surroundings, travel mode, etc.

%prep
%setup -q

%install
make DESTDIR=%{buildroot} PREFIX=/usr install

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
