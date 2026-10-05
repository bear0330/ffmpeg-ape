# FFmpeg and FFprobe for Cosmopolitan APE

This project publishes the complete superconfigure overlay for two portable
media command-line tools:

- `ffmpeg.com` converts and processes a deliberately curated set of local
  media formats.
- `ffprobe.com` inspects media streams and container metadata.

Both outputs are fat Cosmopolitan Actually Portable Executables with x86_64
and aarch64 slices. They do not need a host FFmpeg installation when run.

The repository contains the actual `cli/ffmpeg` and `cli/ffprobe` build
recipes, patches, source checksums, and validation scripts—not just a pointer
to another repository. Superconfigure supplies the shared build framework,
Cosmopolitan toolchain, and dependency recipes.

## Install the overlay

[`superconfigure.lock`](superconfigure.lock) pins the released superconfigure
base validated with this overlay: `z0.0.66`. With no argument, the installer
clones that base into this project's `superconfigure/` directory, then adds
FFmpeg, FFprobe, dav1d, the CLI fattening helper, and the required
parent-catalog entries:

```sh
./scripts/install-overlay.sh
```

To install into an existing matching checkout instead, pass its path:

```sh
./scripts/install-overlay.sh /path/to/superconfigure
```

The installer checks the commit and backs up replaced recipe trees under
`.ape-overlay-backups/`. It does not build anything itself.

## Synchronize from SuperConfigure

This repository is the standalone copy of the FFmpeg/FFprobe overlay maintained
in SuperConfigure. After making a compatible update there, refresh this copy
without overwriting local overlay changes:

```sh
./scripts/sync-from-superconfigure.sh /path/to/superconfigure
```

Use `--force` only when replacing local changes intentionally. The sync owns
`cli/ffmpeg`, `cli/ffprobe`, `cli/fatten`, `lib/dav1d`, and `config/rules.mk`.

## Build

On WSL, clone into the Linux filesystem (for example `~/src`), not a
`/mnt/c` or `/mnt/d` Windows mount: Cosmocc launches nested APE programs that
DrvFs cannot run reliably. Then disable the default 8 MiB shell stack limit;
Cosmopolitan's large Makefile needs an unlimited stack:

```sh
ulimit -s unlimited
```

```sh
cd /path/to/superconfigure
./.github/scripts/setup
./.github/scripts/cosmo
MAXPROC=4 bash ./.github/scripts/collectbuild cli/ffmpeg
MAXPROC=4 bash ./.github/scripts/collectbuild cli/ffprobe
```

`setup` and `cosmo` clone Cosmopolitan and generate the matching Cosmocc
toolchain. The overlay deliberately does not download a separate Cosmopolitan
archive or legacy Cosmocc package; dav1d provisions its pinned Meson source
automatically.

The results are `results/bin/ffmpeg.com` and `results/bin/ffprobe.com`.
The profile uses pinned FFmpeg n9.0.1 and dav1d 1.5.4 sources. It enables
file/pipe input, selected common demuxers, codecs, muxers, filters, and AV1
decoding through dav1d; networking and automatic host-library detection are
disabled.

## Python, Node, and Java bindings

The `bindings/python`, `bindings/node`, and `bindings/java` packages bundle
both portable executables. They are intentionally thin: FFmpeg's CLI remains
the API, while APEBind supplies reliable subprocess launching, output capture,
error handling, and portable package-data handling.

```python
from ffmpeg_ape import probe, run

run('-i', 'input.wav', '-c:a', 'aac', 'output.mp4')
info = probe('output.mp4')
```

```js
import { probe, run } from 'ffmpeg-ape';

await run('-i', 'input.wav', '-c:a', 'aac', 'output.mp4');
const info = await probe('output.mp4');
```

```java
import apebind.generated.ffmpeg_ape.FFmpeg;
import java.nio.file.Path;

FFmpeg.run("-i", "input.wav", "-c:a", "aac", "output.mp4");
var info = FFmpeg.probe(Path.of("output.mp4"));
```

For arbitrary CLI arguments, use Python's `ffmpeg([...])` / `ffprobe([...])`,
Node's corresponding functions, or Java's `FFmpeg.ffmpeg(List.of(...))` /
`FFmpeg.ffprobe(List.of(...))`. They return the APEBind process result.
`probe(path)` is only the JSON convenience helper for
`-show_format -show_streams -of json`.

[`ffmpeg.apebind.yaml`](ffmpeg.apebind.yaml) is the reviewed APEBind contract
for the generated FFmpeg raw-argv runtime. Regenerate its base package from an
available build output, then restore the small dual-binary convenience layer:

```sh
apebind validate ffmpeg.apebind.yaml
apebind generate ffmpeg.apebind.yaml --ape /path/to/ffmpeg.com --lang python -o bindings/python
apebind generate ffmpeg.apebind.yaml --ape /path/to/ffmpeg.com --lang node -o bindings/node
apebind generate ffmpeg.apebind.yaml --ape /path/to/ffmpeg.com --lang java -o bindings/java
```

The additional `ffprobe.com` binary and `run`/`probe` helpers are deliberate
package-local additions because one APEBind schema represents one executable.
All three packages include the FFmpeg LGPL-2.1-or-later license text and
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## Use

```sh
./results/bin/ffmpeg.com -i input.mp4 -c:v mpeg4 -c:a aac output.mp4
./results/bin/ffprobe.com -v error -show_format -show_streams input.mp4
```

Run `-formats`, `-codecs`, or `-filters` to see the intentionally limited
feature set included by this portable profile.

## Tested

The standard `collectbuild cli/ffmpeg` path was rebuilt from the pinned archive
on 2026-09-25. Its `validate-fixtures.sh` test passed: it decoded the bundled
H.264 and AV1 fixtures to raw video. The matching FFprobe recipe was previously
validated through the standard collection build and includes fixture and
portability validation scripts:

```sh
./cli/ffmpeg/validate-fixtures.sh ./results/bin/ffmpeg.com
./cli/ffprobe/validate-fixtures.sh ./results/bin/ffprobe.com
./cli/ffprobe/validate-portability.sh ./results/bin/ffprobe.com /path/to/native/ffprobe
```
