# -*- coding: us-ascii-unix -*-

NAME       = pure-maps
VERSION    = 1.22.0
RELEASE    = $(NAME)-$(VERSION)
DESTDIR    =
PREFIX     = /usr
EXEDIR     = $(DESTDIR)$(PREFIX)/bin
EXE        = $(EXEDIR)/$(NAME)
DATADIR    = $(DESTDIR)$(PREFIX)/share/$(NAME)
DESKTOPDIR = $(DESTDIR)$(PREFIX)/share/applications
ICONDIR    = $(DESTDIR)$(PREFIX)/share/icons/hicolor
METADIR    = $(DESTDIR)$(PREFIX)/share/metainfo
LANGS      = $(basename $(notdir $(wildcard po/*.po)))
LCONVERT   = $(or $(wildcard /usr/lib/qt5/bin/lconvert),\
                  $(wildcard /bin/lconvert),\
                  $(wildcard /usr/bin/lconvert),\
                  $(wildcard /usr/lib/*/qt5/bin/lconvert))

define install-translation =
    # GNU gettext translations for Python use.
    mkdir -p $(DATADIR)/locale/$(1)/LC_MESSAGES
    msgfmt po/$(1).po -o $(DATADIR)/locale/$(1)/LC_MESSAGES/pure-maps.mo
    # Qt linguist translations for QML use.
    mkdir -p $(DATADIR)/translations
    $(LCONVERT) -o $(DATADIR)/translations/$(NAME)-$(1).qm po/$(1).po
endef

check:
	python3 -m pyflakes geocoders guides poor routers
	find . -type f -name "*.json" -exec jsonlint -q {} \;

clean:
	rm -rf dist
	rm -rf */.cache
	rm -rf */*/.cache
	rm -rf */.pytest_cache
	rm -rf */*/.pytest_cache
	rm -rf */__pycache__
	rm -rf */*/__pycache__
	rm -f po/*~
	rm -f rpm/*.rpm
	rm -f */*.qmlc */*/*.qmlc

dist:
	$(MAKE) clean
	mkdir -p dist/$(RELEASE)
	cp -r `cat MANIFEST` dist/$(RELEASE)
	tools/manage-keys inject dist/$(RELEASE)
	tar -C dist -cJf dist/$(RELEASE).tar.xz $(RELEASE)

flathub-install-general:
	tools/manage-keys inject . || true
	$(MAKE) install
	mkdir -p $(PREFIX)/share/applications
	mkdir -p $(PREFIX)/share/appdata
	mkdir -p $(PREFIX)/usr
	install -D packaging/flatpak/io.github.rinigus.PureMaps $(PREFIX)/bin/io.github.rinigus.PureMaps
	install -D packaging/flatpak/osmscout-server $(PREFIX)/bin/osmscout-server
	install -D packaging/flatpak/io.github.rinigus.PureMaps.desktop $(PREFIX)/share/applications
	sed 's/binary>pure-maps/binary>io.github.rinigus.PureMaps/' packaging/pure-maps.appdata.xml > $(PREFIX)/share/appdata/io.github.rinigus.PureMaps.appdata.xml
        # workaround https://github.com/hughsie/appstream-glib/issues/271
	ln -s $(PREFIX)/share $(PREFIX)/usr
	mv $(PREFIX)/share/pure-maps/qml/pure-maps.qml $(PREFIX)/share/pure-maps/qml/io.github.rinigus.PureMaps.qml
	rename pure-maps io.github.rinigus.PureMaps $(PREFIX)/share/pure-maps/translations/*.qm
	mv $(PREFIX)/share/pure-maps $(PREFIX)/share/io.github.rinigus.PureMaps

flathub-install-kirigami: platform-kirigami flathub-install-general
	echo "Kirigami flathub install done"

flathub-install-qtcontrols: platform-qtcontrols flathub-install-general
	echo "QtControls flathub install done"

flatpak-build:
	flatpak-builder --repo=../flatpak --force-clean ../flatpak-build-desktop packaging/flatpak/io.github.rinigus.PureMaps.json

flatpak-bundle: flatpak-build
	flatpak build-bundle ../flatpak pure-maps.flatpak io.github.rinigus.PureMaps

flatpak-debug:
	@echo
	@echo
	@echo "Starting GDB in Flatpak. In GDB, type 'run', all arguments have been taken care of"
	@echo "On crash, GDB may be suspended. Just run 'fg' in your shell to continue"
	@echo
	@echo
	flatpak-builder --run ../flatpak-build-desktop packaging/flatpak/io.github.rinigus.PureMaps.json gdb --args /app/bin/qmlrunner -P /app/share io.github.rinigus.PureMaps

flatpak-dev-install: flatpak-bundle
	flatpak uninstall --user -y io.github.rinigus.PureMaps/x86_64/master || true
	flatpak install --user -y pure-maps.flatpak

flatpak-run:
	flatpak-builder --run ../flatpak-build-desktop packaging/flatpak/io.github.rinigus.PureMaps.json io.github.rinigus.PureMaps

install:
	@echo "Installing Python files..."
	mkdir -p $(DATADIR)/poor
	cp poor/*.py $(DATADIR)/poor
ifeq ($(INCLUDE_GPXPY),yes)
	mkdir -p $(DATADIR)/thirdparty/gpxpy/gpxpy
	cp thirdparty/gpxpy/gpxpy/*.py $(DATADIR)/thirdparty/gpxpy/gpxpy
endif
	mkdir -p $(DATADIR)/poor/openlocationcode
	cp thirdparty/open-location-code/*.py $(DATADIR)/poor/openlocationcode
	mkdir -p $(DATADIR)/poor/astral
	cp thirdparty/astral/*.py $(DATADIR)/poor/astral
	@echo "Installing QML files..."
	mkdir -p $(DATADIR)/qml
	cp qml/pure-maps.qml $(DATADIR)/qml/$(NAME).qml
	cp qml/[ABCDEFGHIJKLMNOPQRSTUVXYZ]*.qml $(DATADIR)/qml
	mkdir -p $(DATADIR)/qml/icons
	cp qml/icons/*.svg qml/icons/*.png qml/icons/*.jpg $(DATADIR)/qml/icons
	mkdir -p $(DATADIR)/qml/icons/attribution
	cp qml/icons/attribution/*.svg $(DATADIR)/qml/icons/attribution
	mkdir -p $(DATADIR)/qml/icons/basemap
	cp qml/icons/basemap/*.svg $(DATADIR)/qml/icons/basemap
	mkdir -p $(DATADIR)/qml/icons/marker
	cp qml/icons/marker/*.png $(DATADIR)/qml/icons/marker
	mkdir -p $(DATADIR)/qml/icons/navigation
	cp qml/icons/navigation/*.svg $(DATADIR)/qml/icons/navigation
	mkdir -p $(DATADIR)/qml/icons/position
	cp qml/icons/position/*.png $(DATADIR)/qml/icons/position
	mkdir -p $(DATADIR)/qml/icons/sailfishos
	cp qml/icons/sailfishos/*.svg $(DATADIR)/qml/icons/sailfishos
	mkdir -p $(DATADIR)/qml/js
	cp qml/js/*.js $(DATADIR)/qml/js
	mkdir -p $(DATADIR)/qml/platform
	cp -L qml/platform/*.qml $(DATADIR)/qml/platform
	@echo "Installing maps..."
	mkdir -p $(DATADIR)/maps
	cp maps/*.json $(DATADIR)/maps
	cp maps/README.md $(DATADIR)/maps
	@echo "Installing geocoders..."
	mkdir -p $(DATADIR)/geocoders
	cp geocoders/*.json $(DATADIR)/geocoders
	cp geocoders/[!_]*.py $(DATADIR)/geocoders
	cp geocoders/README.md $(DATADIR)/geocoders
	@echo "Installing guides..."
	mkdir -p $(DATADIR)/guides
	cp guides/*.json $(DATADIR)/guides
	cp guides/[!_]*.py $(DATADIR)/guides
	cp guides/*.qml $(DATADIR)/guides
	cp guides/README.md $(DATADIR)/guides
	@echo "Installing routers..."
	mkdir -p $(DATADIR)/routers
	cp routers/*.graphql $(DATADIR)/routers
	cp routers/*.json $(DATADIR)/routers
	cp routers/[!_]*.py $(DATADIR)/routers
	cp routers/*.qml $(DATADIR)/routers
	cp routers/README.md $(DATADIR)/routers
	mkdir -p $(DATADIR)/routers/digitransit
	cp routers/digitransit/*.svg $(DATADIR)/routers/digitransit
	@echo "Installing fallback icons..."
	mkdir -p $(DATADIR)/icons
	cp -r qml/icons/fallback/*.svg $(DATADIR)/icons
	@echo "Installing translations..."
	$(foreach lang,$(LANGS),$(call install-translation,$(lang)))
	@echo "Installing desktop file..."
	mkdir -p $(DESKTOPDIR)
	cp data/$(NAME).desktop $(DESKTOPDIR) || true
	@echo "Installing executable file..."
	mkdir -p $(EXEDIR)
	cp data/$(NAME) $(EXE) || true
	sed -i -e 's|INSTALL_PREFIX|$(PREFIX)|g' $(EXE) || true
	@echo "Installing appdata file..."
	mkdir -p $(METADIR)
	cp packaging/pure-maps.appdata.xml $(METADIR)/$(NAME).appdata.xml || true
	@echo "Installing icons..."
	mkdir -p $(ICONDIR)/86x86/apps
	mkdir -p $(ICONDIR)/108x108/apps
	mkdir -p $(ICONDIR)/128x128/apps
	mkdir -p $(ICONDIR)/256x256/apps
	cp data/pure-maps-86.png  $(ICONDIR)/86x86/apps/$(NAME).png
	cp data/pure-maps-108.png $(ICONDIR)/108x108/apps/$(NAME).png
	cp data/pure-maps-128.png $(ICONDIR)/128x128/apps/$(NAME).png
	cp data/pure-maps-256.png $(ICONDIR)/256x256/apps/$(NAME).png

platform-qtcontrols:
	rm qml/platform || true
	ln -s platform.qtcontrols qml/platform

platform-kirigami:
	rm qml/platform || true
	ln -s platform.kirigami qml/platform

platform-silica:
	rm qml/platform || true
	ln -s platform.silica qml/platform

platform-ubports:
	rm qml/platform || true
	ln -s platform.ubports qml/platform

pot:
	tools/update-translations

rpm-silica:
	$(MAKE) NAME=harbour-pure-maps .rpm-silica-imp

.rpm-silica-imp:
	$(MAKE) platform-silica
	$(MAKE) dist
	mkdir -p $$HOME/rpmbuild/SOURCES
	cp dist/$(RELEASE).tar.xz $$HOME/rpmbuild/SOURCES
	rm -rf $$HOME/rpmbuild/BUILD/$(RELEASE)
	rpmbuild -ba --nodeps rpm/$(NAME).spec
	cp $$HOME/rpmbuild/RPMS/noarch/$(RELEASE)-*.rpm rpm
	cp $$HOME/rpmbuild/SRPMS/$(RELEASE)-*.rpm rpm

test:
	py.test geocoders guides poor routers
	py.test poor/test/delayed_test_config.py

.PHONY: check clean dist install pot rpm test
