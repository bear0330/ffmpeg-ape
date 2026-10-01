# FFprobe APE

This recipe reproduces the archived functional profile: FFmpeg n9.0.1 with
dav1d 1.5.4, file and pipe protocols, pthreads, no network, and assembly
optimizations enabled.
It builds x86_64 and aarch64 slices, then links `results/bin/ffprobe.com`.

Build the canonical target with `MAXPROC=4 ./.github/scripts/collectbuild
cli/ffprobe`. The standard recipe uses only pinned archives, the checked-in
Cosmopolitan runtime, and the recipe patch. Validate the resulting APE with
`cli/ffprobe/validate-fixtures.sh`.

For the complete 2187-case FATE run, extract the supplied FATE archives and
run the archived `validate-fate.py` procedure against `results/bin/ffprobe.x86_64`.

Use `cli/ffprobe/validate-portability.sh APE NATIVE_FFPROBE` to compare the portable APE
with a native FFprobe on Unicode, spaces, long paths, relative paths, `pipe:0`,
and truncated media. It fails only when a native success regresses in the APE,
or the APE times out or terminates by signal.
