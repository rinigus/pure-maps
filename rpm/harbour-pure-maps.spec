# Define Sailfish as it is absent
%if !0%{?fedora}
%define sailfishos 1
%endif

# Prevent brp-python-bytecompile from running.
%define __os_install_post %{___build_post}

%if 0%{?sailfishos}
# "Harbour RPM packages should not provide anything."
%define __provides_exclude_from ^%{_datadir}/.*$
%endif

%if 0%{?sailfishos}
Name: harbour-pure-maps
%else
Name: pure-maps
%endif

Version: 1.29.2
Release: 1

Summary: Maps and navigation
License: GPLv3+
URL:     https://github.com/rinigus/pure-maps
Source:  %{name}-%{version}.tar.xz
Source1: apikeys.py

BuildArch: noarch

BuildRequires: gettext
BuildRequires: make
Requires: mapboxgl-qml >= 1.7.0

%if 0%{?sailfishos}
BuildRequires: qt5-qttools-linguist
Requires: libkeepalive
Requires: libsailfishapp-launcher
Requires: pyotherside-qml-plugin-python3-qt5 >= 1.5.1
Requires: qt5-qtdeclarative-import-multimedia >= 5.2
Requires: qt5-qtdeclarative-import-positioning >= 5.2
Requires: sailfishsilica-qt5
%else
BuildRequires: qt5-linguist
Requires: kf5-kirigami2
Requires: mapboxgl-qml
Requires: pyotherside
Requires: qt5-qtmultimedia
Requires: qt5-qtlocation
Requires: mimic
Requires: nemo-qml-plugin-dbus-qt5
Requires: qml-module-clipboard
Requires: qmlrunner
Requires: dbus-tools
%endif

%description
View maps, find places and routes, navigate with turn-by-turn instructions,
search for nearby places by type and share your location.

%prep
%setup -q
cp %{SOURCE1} tools/
tools/manage-keys inject . || true

%if 0%{?sailfishos}
%qmake FLAVOR=silica CONFIG+=install_gpxpy
%else
%qmake FLAVOR=kirigami CONFIG+=install_gpxpy
%endif

%build
make

%install
make INSTALL_ROOT=%{buildroot} PREFIX=/usr install

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/applications/%{name}-uri-handler.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%if 0%{?sailfishos}
%exclude %{_datadir}/metainfo/%{name}.appdata.xml
%else
%{_datadir}/metainfo/%{name}.appdata.xml
%endif
