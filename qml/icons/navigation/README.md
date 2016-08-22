Navigation icons are borrowed from Mapbox's [directions-icons][1],
available under the CC0 license. Icons are used as-is except for simple
renaming and color-inversion.

```bash
rename "s/_/-/g" *.svg
sed -i "s/#000000/#ffffff/g" *.svg
```

[1]: https://github.com/mapbox/directions-icons
