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

Version: 1.29.0
Release: 1

Summary: Maps and navigation
License: GPLv3+
URL:     https://github.com/rinigus/pure-maps
Source:  %{name}-%{version}.tar.xz
%if !0%{?sailfishos}
Source1: apikeys.py
%endif
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
%if 0%{?sailfishos}
make platform-silica
%else
cp apikeys.py tools/
tools/manage-keys inject . || true
make platform-kirigami
%endif

%install
make DESTDIR=%{buildroot} PREFIX=/usr INCLUDE_GPXPY=yes install

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
#%{_datadir}/applications/%{name}-uri-handler.desktop
#%{_datadir}/dbus-1/services/io.github.rinigus.PureMaps.service
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%if 0%{?sailfishos}
%exclude %{_datadir}/metainfo/%{name}.appdata.xml
%else
%{_datadir}/metainfo/%{name}.appdata.xml
%endif
