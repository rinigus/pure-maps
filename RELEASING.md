Releasing a New Version
=======================

```bash
# Update translations.
make pot
tx push -s
tx pull -a --minimum-perc=95
sed -i "s/charset=CHARSET/charset=UTF-8/" po/*.po
tools/check-translations
tools/check-translations | grep %
git add po/*.po po/*.pot; git status
git commit -m "Update translations"

# Check, test, do final edits and release.
tools/manage-keys inject .
make check test
tools/manage-keys strip .
git status
emacs poor/__init__.py rpm/*.spec Makefile
emacs NEWS.md TODO.md
make rpm-silica
make flatpak
git status
```
