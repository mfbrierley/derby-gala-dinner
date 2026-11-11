# 2026 gallery photos

All the 2026 photos are kept in this folder. The 2026 Gallery page shows only the ones listed at
the top of `src/pages/gallery.astro`, in the order they're listed there. Photos that aren't
listed aren't uploaded to the website.

To add or swap a photo on the page: add an `import` line for it at the top of
`src/pages/gallery.astro`, then add it to the list just below, with a short description.

- Supported: `.jpg`, `.jpeg`, `.png`, `.webp`
- Originals can be any size. Around 2400px wide is plenty; the build makes small
  versions for the grid and larger ones for the full-size viewer.

Shrink large originals to 2400px wide before adding them (bigger is never shown, and
keeps the project small). On a Mac, from the project folder:

    find "/path/to/originals" -iname '*.jp*g' -exec sips -Z 2400 -s formatOptions 85 {} --out src/assets/gallery \;
