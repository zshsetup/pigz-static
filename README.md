# pigz-static

Portable builds of [pigz](https://zlib.net/pigz/), the parallel implementation of gzip, with
[zlib](https://zlib.net/) linked in statically, built with [zig](https://ziglang.org) as the C toolchain.

- Linux glibc: only glibc is linked dynamically, and only symbols up to glibc 2.17, so the
  binaries run on anything from CentOS 7 onwards
- Linux musl (`--static`): fully static, no runtime dependencies at all (e.g. Alpine)
- macOS: only libSystem is dynamic (it ships with macOS, which has no fully static binaries)

## Prerequisites

- `zig`, GNU make (the `make` 3.81 of macOS is enough), `git`

## Installation

Clone the repo with submodules (shallow, the history of the vendored projects is not needed):

```shell
git clone --recurse-submodules --shallow-submodules https://github.com/zshsetup/pigz-static
cd pigz-static
```

## Usage

```shell
./build.sh
```

Output is installed under `dist/`:

- `dist/bin/pigz`, `dist/bin/unpigz`: the binary and a copy that decompresses by default;
  copy them anywhere on your `PATH`
- `dist/share/man/man1/pigz.1`: the man page

Pass `--static` for the fully static musl build on Linux (output in `dist-static/`), `--clean` to
remove previous build output first, and `--jobs N` to control parallelism.

To run the smoke tests against the build:

```shell
./tests/run_smoke_tests.sh            # dist/
./tests/run_smoke_tests.sh --static   # dist-static/
```

## Releases

Publishing a GitHub release tagged like the contents of `VERSION`, the tag checked out in
`vendor/pigz`, builds and attaches `pigz-static-<platform>.tar.gz` for `macos-arm64`,
`linux-amd64`, `linux-arm64`, `linux-musl-amd64`, and `linux-musl-arm64`, together with the sources
they were built from (`pigz-static-sources.tar.gz`).

To update a vendored project, check out a new release tag in its submodule, commit it, and update
`VERSION` if it is the main one, e.g.
`git -C vendor/pigz fetch --depth 1 origin tag v2.7 && git -C vendor/pigz checkout v2.7`.

## Acknowledgments

This repository builds and vendors the following upstream projects, unmodified, as git
submodules under `vendor/`. Credit goes to their respective authors:

- [pigz](https://github.com/madler/pigz) by Mark Adler
- [zlib](https://github.com/madler/zlib) by Jean-loup Gailly and Mark Adler

## License

MIT for the code in this repository. See `NOTICE` for the licenses of the upstream projects and the
resulting binaries, which are the zlib license.
