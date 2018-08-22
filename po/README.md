Translating Pure Maps
=====================

Translations are available at [Transifex][1]. Please use that to add and
update translations. Try to keep your translation consistent with the
[Sailfish OS translations][2] and [language-specific style guides][3].

[1]: https://www.transifex.com/rinigus/pure-maps/
[2]: https://sailfishos.org/wiki/Translate_the_OS
[3]: https://sailfishos.org/wiki/Translate_the_OS#Style

## Testing Your Translation

If you wish to test your translation (e.g. for context or brevity)
before it's included in a public release, the easiest way is to add your
translation to the Pure Maps source tree, build the RPM and install it.

1. Download your translation from Transifex with the link "Download for
   use". You should find it via the language list, or
   use [this full link][dl-po], replacing `fi` with your language code.

1. Download Pure Maps from GitHub. Usually you'll probably want the
   source code of the latest release, which can be downloaded from
   the [releases][releases] page.

1. Unpack the downloaded source code and place your translation in the
   `po` directory with the correct short language and possibly country
   code, e.g. `fi.po` or `pt_BR.po`.

1. Run command `make rpm` in the source directory. You'll need `make`,
   `rpmbuild`, `gettext` and `qttools`. You'll find the resulting RPM
   under the `rpm` directory. Copy that to your device and install e.g.
   via the File Browser app or `pkcon install-local ...` at a command
   line.

[dl-po]: https://www.transifex.com/rinigus/pure-maps/pure-mapspot/fi/download/for_use/
[releases]: https://github.com/rinigus/pure-maps/releases
