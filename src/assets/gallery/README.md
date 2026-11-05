# 2026 gallery photos

Every image in this folder appears on the 2026 Gallery page, in filename order.

- Supported: `.jpg`, `.jpeg`, `.png`, `.webp`
- Name them so they sort in the order you want, e.g. `2026-001.jpg`, `2026-002.jpg` …
- Originals can be any size. Around 2400px wide is plenty; the build makes small
  versions for the grid and larger ones for the full-size viewer.

Shrink large originals to 2400px wide before adding them (bigger is never shown, and
keeps the project small). On a Mac, from the project folder:

    find "/path/to/originals" -iname '*.jp*g' -exec sips -Z 2400 -s formatOptions 85 {} --out src/assets/gallery \;

The first build after adding lots of photos takes a few minutes; after that they're cached.
