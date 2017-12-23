Releasing a New Version
=======================

```bash
# Update translations.
make pot
msgmerge -UN po/fi.po po/poor-maps.pot
emacs po/fi.po
tx push -s
tx push -tf -l fi
tx pull -a --minimum-perc=95
tools/check-translations
tools/check-translations | grep %
git commit -a -m "Update translations"

# Check, test, do final edits and release.
make check; make test
emacs poor/__init__.py rpm/*.spec Makefile
emacs NEWS.md TODO.md
make rpm
rpmvalidation.sh rpm/*.noarch.rpm
pkcon install-local rpm/*.noarch.rpm
tools/release

# Add release notes and RPM on GitHub.
# Update OpenRepos: https://openrepos.net/content/otsaloma/poor-maps
```
