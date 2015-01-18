# -*- coding: us-ascii-unix -*-

name       = harbour-poor-maps
version    = 0.16
DESTDIR    =
PREFIX     = /usr/local
datadir    = $(DESTDIR)$(PREFIX)/share/$(name)
desktopdir = $(DESTDIR)$(PREFIX)/share/applications
icondir    = $(DESTDIR)$(PREFIX)/share/icons/hicolor/86x86/apps

.PHONY: clean dist install rpm

clean:
	rm -rf dist
	rm -rf __pycache__ */__pycache__ */*/__pycache__
	rm -f rpm/*.rpm

dist:
	$(MAKE) clean
	mkdir -p dist/$(name)-$(version)
	cp -r `cat MANIFEST` dist/$(name)-$(version)
	tar -C dist -cJf dist/$(name)-$(version).tar.xz $(name)-$(version)

install:
	@echo "Installing Python files..."
	mkdir -p $(datadir)/poor
	cp poor/*.py $(datadir)/poor

	@echo "Installing QML files..."
	mkdir -p $(datadir)/qml
	cp qml/poor-maps.qml $(datadir)/qml/$(name).qml
	cp qml/[ABCDEFGHIJKLMNOPQRSTUVXYZ]*.qml $(datadir)/qml
	mkdir -p $(datadir)/qml/icons
	cp qml/icons/*.png $(datadir)/qml/icons
	mkdir -p $(datadir)/qml/js
	cp qml/js/*.js $(datadir)/qml/js

	@echo "Installing tilesources..."
	mkdir -p $(datadir)/tilesources
	cp tilesources/*.json $(datadir)/tilesources
	cp tilesources/*.py $(datadir)/tilesources

	@echo "Installing geocoders..."
	mkdir -p $(datadir)/geocoders
	cp geocoders/*.json $(datadir)/geocoders
	cp geocoders/*.py $(datadir)/geocoders
	cp geocoders/README.md $(datadir)/geocoders

	@echo "Installing guides..."
	mkdir -p $(datadir)/guides
	cp guides/*.json $(datadir)/guides
	cp guides/*.py $(datadir)/guides
	cp guides/*.qml $(datadir)/guides
	cp guides/README.md $(datadir)/guides

	@echo "Installing routers..."
	mkdir -p $(datadir)/routers
	cp routers/*.json $(datadir)/routers
	cp routers/*.py $(datadir)/routers
	cp routers/*.qml $(datadir)/routers
	cp routers/README.md $(datadir)/routers
	mkdir -p $(datadir)/routers/hsl
	cp routers/hsl/*.png $(datadir)/routers/hsl

	@echo "Installing desktop file..."
	mkdir -p $(desktopdir)
	cp data/$(name).desktop $(desktopdir)

	@echo "Installing icon..."
	mkdir -p $(icondir)
	cp data/poor-maps.png $(icondir)/$(name).png

rpm:
	mkdir -p $$HOME/rpmbuild/SOURCES
	cp dist/$(name)-$(version).tar.xz $$HOME/rpmbuild/SOURCES
	rpmbuild -ba rpm/$(name).spec
	cp $$HOME/rpmbuild/RPMS/noarch/$(name)-$(version)-*.rpm rpm
	cp $$HOME/rpmbuild/SRPMS/$(name)-$(version)-*.rpm rpm
