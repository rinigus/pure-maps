# Note that the paths here are relative to the .pro file!

VERSION=1.8.0

# define target files
qml-common.files = ../qml
qml-common.path = /usr/share/$${TARGET}
INSTALLS += qml-common

geocoders.files = ../geocoders/[a-z]*.py ../geocoders/*.json
geocoders.path = /usr/share/$${TARGET}/geocoders
INSTALLS += geocoders

guides.files = ../guides/[a-z]*.py ../guides/*.json ../guides/*.qml
guides.path = /usr/share/$${TARGET}/guides
INSTALLS += guides

maps.files = ../maps/*.json
maps.path = /usr/share/$${TARGET}/maps
INSTALLS += maps

poor.files = ../poor/*.py
poor.path = /usr/share/$${TARGET}/poor
poor-gpxpy.files = ../poor/gpxpy/*.py
poor-gpxpy.path = /usr/share/$${TARGET}/poor/gpxpy
INSTALLS += poor poor-gpxpy

routers.files = ../routers/[a-z]*.py ../routers/*.json ../routers/*.qml ../routers/*.graphql
routers.path = /usr/share/$${TARGET}/routers
routers-digitransit.files = ../routers/digitransit/*.png
routers-digitransit.path = /usr/share/$${TARGET}/routers/digitransit
INSTALLS += routers routers-digitransit

# Extra targets. These will be available in the generated Makefile
checktarget.target = check
checktarget.commands = cd .. && \
    pyflakes geocoders guides poor routers \
    && find . -name "*.json" -exec jsonlint -q {} \;

extraclean.target = extraclean
extraclean.commands = cd .. && \
    rm -rf dist && \
    rm -rf */.cache && \
    rm -rf */*/.cache && \
    rm -rf */.pytest_cache && \
    rm -rf */*/.pytest_cache && \
    rm -rf */__pycache__ && \
    rm -rf */*/__pycache__ && \
    rm -f po/.*~
clean.depends = extraclean

realdist.target = realdist
realdist.commands = cd .. && \
        mkdir -p dist/$${TARGET}-$${VERSION} && \
        cp -r `cat MANIFEST` dist/$${TARGET}-$${VERSION} && \
        tools/manage-keys inject dist/$${TARGET}-$${VERSION} && \
        tar -C dist -cJf dist/$${TARGET}-$${VERSION}.tar.xz $${TARGET}-$${VERSION}
realdist.depends = clean

pot.target = pot
pot.commands = cd .. && \
    tools/update-translations

test.target = test
test.commands = cd .. && \
    py.test geocoders guides poor routers

QMAKE_EXTRA_TARGETS += checktarget clean extraclean realdist pot test
