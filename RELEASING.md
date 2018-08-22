Releasing a New Version
=======================

```bash
# Update translations.
make pot
msgmerge -UN po/fi.po po/pure-maps.pot
emacs po/fi.po
tx push -s
tx push -tf --no-interactive -l fi
tx pull -a --minimum-perc=95
sed -i "s/charset=CHARSET/charset=UTF-8/" po/*.po
tools/check-translations
tools/check-translations | grep %
git add po/*.po po/*.pot; git status
git commit -m "Update translations"

# Check, test, do final edits and release.
make check test
emacs poor/__init__.py rpm/*.spec Makefile
emacs NEWS.md TODO.md
make rpm
rpmvalidation.sh rpm/*.noarch.rpm
install-rpm-on-jolla rpm/*.noarch.rpm
tools/release
```
