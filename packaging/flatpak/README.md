The included flatpak configuration that requires API keys to be
available when packaging. Place API keys in `tools/apikeys.py` by
making a copy of `tools/apikeys_dummy.py` and filling in the keys.

If you wish to use Pure Maps without API keys, you could just avoid
filling the keys.

For building flatpak package, run

```
flatpak-builder --repo=../flatpak --force-clean ../build-dir packaging/flatpak/io.github.rinigus.PureMaps.json
```

from the source cloned source directory. Replace repo and build-dir, if needed.
