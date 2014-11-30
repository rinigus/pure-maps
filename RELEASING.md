Releasing a New Version
=======================

 * Do final quality checks
   - `pyflakes3 geocoders guides poor routers`
   - `py.test-3 poor`
 * Bump version numbers
   - poor/__init__.py
   - rpm/*.spec
   - Makefile
 * Update NEWS.md and TODO.md
 * Build tarball and RPM
   - `make dist`
   - `make rpm`
 * Install RPM and check that it works
   - `pkcon install-local rpm/*.noarch.rpm`
 * Commit changes
   - `git commit -a -m "RELEASE X.Y.Z"`
   - `git tag -s poor-maps-X.Y.Z`
   - `git push`
   - `git push --tags`
 * Build final tarball and RPM
   - `make dist`
   - `make rpm`
   - `pkcon install-local rpm/*.noarch.rpm`
 * Upload and announce
