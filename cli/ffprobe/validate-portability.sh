#!/bin/sh
set -eu

APE_INPUT=${1:?usage: $0 /path/to/ffprobe.com /path/to/native-ffprobe}
NATIVE_INPUT=${2:?usage: $0 /path/to/ffprobe.com /path/to/native-ffprobe}
APE=$(CDPATH= cd -- "$(dirname -- "$APE_INPUT")" && pwd)/$(basename -- "$APE_INPUT")
NATIVE=$(CDPATH= cd -- "$(dirname -- "$NATIVE_INPUT")" && pwd)/$(basename -- "$NATIVE_INPUT")
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
FIXTURES="$ROOT/cli/ffprobe/fixtures"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT HUP INT TERM

run() {
  name=$1
  shift
  native_status=0
  ape_status=0
  timeout 10 "$NATIVE" "$@" >"$WORK/$name.native.out" 2>"$WORK/$name.native.err" || native_status=$?
  timeout 10 "$APE" "$@" >"$WORK/$name.ape.out" 2>"$WORK/$name.ape.err" || ape_status=$?
  [ "$ape_status" -ne 124 ] || { echo "$name: APE timed out" >&2; exit 1; }
  [ "$ape_status" -lt 128 ] || { echo "$name: APE terminated by signal $ape_status" >&2; exit 1; }
  if [ "$native_status" -eq 0 ] && [ "$ape_status" -ne 0 ]; then
    echo "$name: native succeeded but APE exited $ape_status" >&2
    cat "$WORK/$name.ape.err" >&2
    exit 1
  fi
  printf '%s: native=%s ape=%s\n' "$name" "$native_status" "$ape_status"
}

mkdir -p "$WORK/空 白/日本語/emoji-😀"
SOURCE="$FIXTURES/av1/film_grain.ivf"
UNICODE="$WORK/空 白/日本語/emoji-😀/影片 sample.ivf"
cp "$SOURCE" "$UNICODE"

run absolute -v error -show_entries stream=codec_name,nb_frames -of default=nw=1 "$UNICODE"
(cd "$WORK" && run relative -v error -show_entries stream=codec_name,nb_frames -of default=nw=1 "空 白/日本語/emoji-😀/影片 sample.ivf")

LONG="$WORK"
while [ "${#LONG}" -lt 1200 ]; do
  LONG="$LONG/long-path-segment-0123456789"
done
mkdir -p "$LONG"
cp "$SOURCE" "$LONG/long-name.ivf"
run long_path -v error -show_entries stream=codec_name,nb_frames -of default=nw=1 "$LONG/long-name.ivf"

native_status=0
ape_status=0
cat "$SOURCE" | timeout 10 "$NATIVE" -v error -show_entries stream=codec_name,nb_frames -of default=nw=1 pipe:0 >"$WORK/pipe.native.out" 2>"$WORK/pipe.native.err" || native_status=$?
cat "$SOURCE" | timeout 10 "$APE" -v error -show_entries stream=codec_name,nb_frames -of default=nw=1 pipe:0 >"$WORK/pipe.ape.out" 2>"$WORK/pipe.ape.err" || ape_status=$?
[ "$ape_status" -ne 124 ] && [ "$ape_status" -lt 128 ] || { echo 'pipe: APE did not exit normally' >&2; exit 1; }
[ "$native_status" -ne 0 ] || [ "$ape_status" -eq 0 ] || { echo 'pipe: native succeeded but APE failed' >&2; exit 1; }
printf 'pipe: native=%s ape=%s\n' "$native_status" "$ape_status"

dd if="$FIXTURES/hevc-conformance/WPP_E_ericsson_MAIN_2.bit" of="$WORK/truncated.bit" bs=1 count=1024 status=none
run truncated -v error -count_frames -show_entries stream=codec_name,nb_read_frames -of default=nw=1 "$WORK/truncated.bit"
