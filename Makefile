# -*- coding: us-ascii-unix -*-

NAME       = harbour-whogo-maps
VERSION    = 1.0.1
RELEASE    = $(NAME)-$(VERSION)
DESTDIR    =
PREFIX     = /usr
DATADIR    = $(DESTDIR)$(PREFIX)/share/$(NAME)
DESKTOPDIR = $(DESTDIR)$(PREFIX)/share/applications
ICONDIR    = $(DESTDIR)$(PREFIX)/share/icons/hicolor
LANGS      = $(basename $(notdir $(wildcard po/*.po)))
LCONVERT   = $(or $(wildcard /usr/lib/qt5/bin/lconvert),\
                  $(wildcard /usr/lib/*/qt5/bin/lconvert))

define install-translation =
    # GNU gettext translations for Python use.
    mkdir -p $(DATADIR)/locale/$(1)/LC_MESSAGES
    msgfmt po/$(1).po -o $(DATADIR)/locale/$(1)/LC_MESSAGES/whogo-maps.mo
    # Qt linguist translations for QML use.
    mkdir -p $(DATADIR)/translations
    $(LCONVERT) -o $(DATADIR)/translations/$(NAME)-$(1).qm po/$(1).po
endef

check:
	pyflakes geocoders guides poor routers
	find . -name "*.json" -exec jsonlint -qc {} \;

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

dist:
	$(MAKE) clean
	mkdir -p dist/$(RELEASE)
	cp -r `cat MANIFEST` dist/$(RELEASE)
	tar -C dist -cJf dist/$(RELEASE).tar.xz $(RELEASE)

install:
	@echo "Installing Python files..."
	mkdir -p $(DATADIR)/poor
	cp poor/*.py $(DATADIR)/poor
	@echo "Installing QML files..."
	mkdir -p $(DATADIR)/qml
	cp qml/whogo-maps.qml $(DATADIR)/qml/$(NAME).qml
	cp qml/[ABCDEFGHIJKLMNOPQRSTUVXYZ]*.qml $(DATADIR)/qml
	mkdir -p $(DATADIR)/qml/icons
	cp qml/icons/*.png $(DATADIR)/qml/icons
	mkdir -p $(DATADIR)/qml/icons/attribution
	cp qml/icons/attribution/*.png $(DATADIR)/qml/icons/attribution
	mkdir -p $(DATADIR)/qml/icons/navigation
	cp qml/icons/navigation/*.svg $(DATADIR)/qml/icons/navigation
	mkdir -p $(DATADIR)/qml/js
	cp qml/js/*.js $(DATADIR)/qml/js
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
	cp routers/digitransit/*.png $(DATADIR)/routers/digitransit
	@echo "Installing translations..."
	$(foreach lang,$(LANGS),$(call install-translation,$(lang)))
	@echo "Installing desktop file..."
	mkdir -p $(DESKTOPDIR)
	cp data/$(NAME).desktop $(DESKTOPDIR)
	@echo "Installing icons..."
	mkdir -p $(ICONDIR)/86x86/apps
	mkdir -p $(ICONDIR)/108x108/apps
	mkdir -p $(ICONDIR)/128x128/apps
	mkdir -p $(ICONDIR)/256x256/apps
	cp data/whogo-maps-86.png  $(ICONDIR)/86x86/apps/$(NAME).png
	cp data/whogo-maps-108.png $(ICONDIR)/108x108/apps/$(NAME).png
	cp data/whogo-maps-128.png $(ICONDIR)/128x128/apps/$(NAME).png
	cp data/whogo-maps-256.png $(ICONDIR)/256x256/apps/$(NAME).png

pot:
	tools/update-translations

rpm:
	$(MAKE) dist
	mkdir -p $$HOME/rpmbuild/SOURCES
	cp dist/$(RELEASE).tar.xz $$HOME/rpmbuild/SOURCES
	rm -rf $$HOME/rpmbuild/BUILD/$(RELEASE)
	rpmbuild -ba --nodeps rpm/$(NAME).spec
	cp $$HOME/rpmbuild/RPMS/noarch/$(RELEASE)-*.rpm rpm
	cp $$HOME/rpmbuild/SRPMS/$(RELEASE)-*.rpm rpm

test:
	py.test geocoders guides poor routers

.PHONY: check clean dist install pot rpm test
