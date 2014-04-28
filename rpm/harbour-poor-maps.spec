# Prevent brp-python-bytecompile from running.
%define __os_install_post %{___build_post}

Name: harbour-poor-maps
Version: 0.2
Release: 1
Summary: An application to display maps and stuff
License: GPLv3+
URL: https://github.com/otsaloma/poor-maps
Source: %{name}-%{version}.tar.xz
BuildArch: noarch
BuildRequires: make
Requires: libsailfishapp-launcher
Requires: pyotherside-qml-plugin-python3-qt5 >= 1.2
Requires: python3-base
Requires: qt5-plugin-geoservices-nokia
Requires: qt5-qtdeclarative-import-location
Requires: qt5-qtdeclarative-import-positioning
Requires: sailfishsilica-qt5

%description
An application to display maps and stuff.

%prep
%setup -q

%install
make DESTDIR=%{buildroot} PREFIX=/usr install

%files
%doc AUTHORS COPYING NEWS README TODO
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
