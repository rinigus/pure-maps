The included flatpak configuration requires API keys to be available
when packaging. Place API keys in `tools/apikeys.py` by making a copy
of `tools/apikeys_dummy.py` and filling in the keys.

If you wish to use Pure Maps without API keys, you could just avoid
filling the keys.

# Flatpak releases

For up to date Flatpak JSON build configuration, please obtain it from
https://github.com/flathub/io.github.rinigus.PureMaps . The releases
are made from that separate repository.


# Development with Flatpak

The build script in this directory is for the development purposes.

For building the Pure Maps flatpak package, first make sure you have
the [Flathub repository installed](https://flatpak.org/setup/).

Then install the runtime and SDK required to build the Pure Maps
flatpak from the repository:

```
flatpak install flathub org.kde.Platform/x86_64/5.12 org.kde.Sdk/x86_64/5.12
```

The builds are composed using `Makefile` in the root of Pure Maps
source tree. Use them as follows:

* `flatpak-build` - build Flatpak package with the your current source
  tree
  
* `flatpak-bundle` - build Flatpak bundle that you can install. Will
  run `flatpak-build` before making the bundle.

* `flatpak-run` - run Pure Maps from the build made by
  `flatpak-build`. NB! It will not run `flatpak-build` before, you
  would have to do that manually.
  
* `flatpak-debug` - as `flatpak-run`, but in debugger. You would have
  to start application by `run` command of `gdb`.
  
* `flatpak-dev-install` - will build `flatpak-bundle` and install it
  using `--user` environment of flatpak.
