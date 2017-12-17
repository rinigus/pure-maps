# -*- coding: us-ascii-unix -*-

NAME       = harbour-poor-maps
VERSION    = 0.33
LANGS      = $(basename $(notdir $(wildcard po/*.po)))
POT_FILE   = po/poor-maps.pot

DESTDIR    =
PREFIX     = /usr
DATADIR    = $(DESTDIR)$(PREFIX)/share/$(NAME)
DESKTOPDIR = $(DESTDIR)$(PREFIX)/share/applications
ICONDIR    = $(DESTDIR)$(PREFIX)/share/icons/hicolor

LCONVERT = $(or $(wildcard /usr/lib/qt5/bin/lconvert),\
$(wildcard /usr/lib/*/qt5/bin/lconvert))

check:
	pyflakes geocoders guides poor routers tilesources

clean:
	rm -rf dist
	rm -rf __pycache__ */__pycache__ */*/__pycache__
	rm -rf .cache */.cache */*/.cache
	rm -f po/*~
	rm -f rpm/*.rpm

dist:
	$(MAKE) clean
	mkdir -p dist/$(NAME)-$(VERSION)
	cp -r `cat MANIFEST` dist/$(NAME)-$(VERSION)
	tar -C dist -cJf dist/$(NAME)-$(VERSION).tar.xz $(NAME)-$(VERSION)

define install-translations =
# GNU gettext translations for Python use.
mkdir -p $(DATADIR)/locale/$(1)/LC_MESSAGES
msgfmt po/$(1).po -o $(DATADIR)/locale/$(1)/LC_MESSAGES/poor-maps.mo
# Qt linguist translations for QML use.
mkdir -p $(DATADIR)/translations
$(LCONVERT) -o $(DATADIR)/translations/$(NAME)-$(1).qm po/$(1).po
endef

install:
	@echo "Installing Python files..."
	mkdir -p $(DATADIR)/poor
	cp poor/*.py $(DATADIR)/poor

	@echo "Installing QML files..."
	mkdir -p $(DATADIR)/qml
	cp qml/poor-maps.qml $(DATADIR)/qml/$(NAME).qml
	cp qml/[ABCDEFGHIJKLMNOPQRSTUVXYZ]*.qml $(DATADIR)/qml
	mkdir -p $(DATADIR)/qml/icons/navigation
	cp qml/icons/*.png $(DATADIR)/qml/icons
	cp qml/icons/navigation/*.svg $(DATADIR)/qml/icons/navigation
	mkdir -p $(DATADIR)/qml/js
	cp qml/js/*.js $(DATADIR)/qml/js

	@echo "Installing tilesources..."
	mkdir -p $(DATADIR)/tilesources
	cp tilesources/*.json $(DATADIR)/tilesources
	cp tilesources/[!_]*.py $(DATADIR)/tilesources
	cp tilesources/README.md $(DATADIR)/tilesources

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
	$(foreach lang,$(LANGS),$(call install-translations,$(lang)))

	@echo "Installing desktop file..."
	mkdir -p $(DESKTOPDIR)
	cp data/$(NAME).desktop $(DESKTOPDIR)

	@echo "Installing icons..."
	mkdir -p $(ICONDIR)/86x86/apps
	mkdir -p $(ICONDIR)/108x108/apps
	mkdir -p $(ICONDIR)/128x128/apps
	mkdir -p $(ICONDIR)/256x256/apps
	cp data/poor-maps-86.png  $(ICONDIR)/86x86/apps/$(NAME).png
	cp data/poor-maps-108.png $(ICONDIR)/108x108/apps/$(NAME).png
	cp data/poor-maps-128.png $(ICONDIR)/128x128/apps/$(NAME).png
	cp data/poor-maps-256.png $(ICONDIR)/256x256/apps/$(NAME).png

pot:
	truncate -s0 $(POT_FILE)
	xgettext \
	 --output=$(POT_FILE) \
	 --language=Python \
	 --from-code=UTF-8 \
	 --join-existing \
	 --keyword=_ \
	 --keyword=__ \
	 --add-comments=TRANSLATORS: \
	 --no-wrap \
	 */*.py

	xgettext \
	 --output=$(POT_FILE) \
	 --language=JavaScript \
	 --from-code=UTF-8 \
	 --join-existing \
	 --keyword=tr:1 \
	 --keyword=qsTranslate:2 \
	 --add-comments=TRANSLATORS: \
	 --no-wrap \
	 */*.qml qml/js/*.js

	cat */*.json \
	 | grep '^ *"_' \
	 | sed 's/: *\("[^"]*"\)/: _(\1)/' \
	 | sed 's/\("[^"]*"\)\(,\|]\)/_(\1)\2/g' \
	 | xgettext \
	    --output=$(POT_FILE) \
	    --language=JavaScript \
	    --from-code=UTF-8 \
	    --join-existing \
	    --keyword=_ \
	    --no-wrap \
	    -

rpm:
	$(MAKE) dist
	mkdir -p $$HOME/rpmbuild/SOURCES
	cp dist/$(NAME)-$(VERSION).tar.xz $$HOME/rpmbuild/SOURCES
	rm -rf $$HOME/rpmbuild/BUILD/$(NAME)-$(VERSION)
	rpmbuild -ba --nodeps rpm/$(NAME).spec
	cp $$HOME/rpmbuild/RPMS/noarch/$(NAME)-$(VERSION)-*.rpm rpm
	cp $$HOME/rpmbuild/SRPMS/$(NAME)-$(VERSION)-*.rpm rpm

test:
	py.test geocoders guides poor routers tilesources

.PHONY: check clean dist install pot rpm test
