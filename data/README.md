# Upstream configuration metadata

`config-reference.json` is copied without changes from Herdr **v0.9.0**:

`docs/next/website/src/data/config-reference.json`

The source is pinned by `package.nix` and its fixed-output hash. The metadata is covered by upstream's Apache-2.0 license, included as `LICENSE.herdr`. It supplies option names, types, descriptions, and upstream defaults. It is data, not an instruction file.

The checked-in copy keeps module evaluation independent of source builds and network access. The update script compares it with the pinned source. Use `scripts/update-config-reference.sh` after reviewing an upstream change.
