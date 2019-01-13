The included flatpak configuration that requires API keys to be
available when packaging. Place API keys in `tools/apikeys.py` by
making a copy of `tools/apikeys_dummy.py` and filling in the keys.

If you wish to use Pure Maps without API keys, you could just avoid
filling the keys.

For up to date Flatpak JSON build configuration, please obtain it from
https://github.com/flathub/io.github.rinigus.PureMaps . 

For building the Pure Maps flatpak package first make sure you have the [Flathub repository installed](https://flatpak.org/setup/).

Then install the runtime and SDK required to build the Pure Maps flatpak from the repository:

```
flatpak install flathub org.kde.Platform/x86_64/5.12 org.kde.Sdk/x86_64/5.12
```

Then finally run the Pure Maps flatpak build:

```
flatpak-builder --repo=../flatpak --force-clean ../build-dir packaging/flatpak/io.github.rinigus.PureMaps.json
```

from the source cloned source directory. Replace repo and build-dir, if needed.
