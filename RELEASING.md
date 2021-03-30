Releasing a New Version
=======================

```bash
# Update translations.
tools/update-translations
tx push -s
tx pull -a --minimum-perc=85
sed -i "s/charset=CHARSET/charset=UTF-8/" po/*.po
tools/check-translations
git add po/*.po po/*.pot; git status
git commit -m "Update translations"

# Check, test, do final edits and release.
tools/manage-keys inject .
make -f Makefile.test
tools/manage-keys strip .
git status
emacs rpm/*.spec pure-maps.pro packaging/click/manifest.json
emacs NEWS.md packaging/pure-maps.appdata.xml
git add NEWS.md packaging/click/manifest.json packaging/pure-maps.appdata.xml pure-maps.pro rpm/harbour-pure-maps.spec
git status
```

Make a release at Github and generate corresponding vendored archive:

```
PM_VERSION=2.6.5
git-archive-all -v --prefix=pure-maps-${PM_VERSION} pure-maps-${PM_VERSION}.tar.gz
```

Upload the archive by attaching it to the release.

After that, trigger update at Flathub and OBS.
