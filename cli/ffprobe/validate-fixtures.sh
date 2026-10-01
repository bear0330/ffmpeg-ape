#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
BIN=${1:-"$ROOT/results/bin/ffprobe.com"}
FIXTURES="$ROOT/cli/ffprobe/fixtures"

"$BIN" -version
for file in \
  sub/madness.srt \
  sub/empty-events-2167.srt \
  sub/badsyntax.srt \
  sub/SubRip_capability_tester.srt \
  sub/ticket5032-rrn.srt; do
  "$BIN" -v error -show_entries format=format_name -of default=nw=1:nk=1 \
    "$FIXTURES/$file" >/dev/null
done
"$BIN" -v error -show_entries stream=codec_name,width,height,pix_fmt,nb_frames \
  -of default=nw=1 "$FIXTURES/av1/film_grain.ivf"
"$BIN" -v error -threads 1 -count_frames \
  -show_entries stream=codec_name,nb_read_frames -of default=nw=1 \
  "$FIXTURES/av1/film_grain.ivf"
"$BIN" -v error -threads 4 -count_frames \
  -show_entries stream=codec_name,nb_read_frames -of default=nw=1 \
  "$FIXTURES/av1/film_grain.ivf"
"$BIN" -v error -threads 4 -count_frames \
  -show_entries stream=codec_name,nb_read_frames -of default=nw=1 \
  "$FIXTURES/h264-444/444_8bit_cabac.h264"
"$BIN" -v error -threads 4 -count_frames \
  -show_entries stream=codec_name,nb_read_frames -of default=nw=1 \
  "$FIXTURES/hevc-conformance/WPP_E_ericsson_MAIN_2.bit"
"$BIN" -v error -threads 4 -count_frames \
  -show_entries stream=codec_name,nb_read_frames -of default=nw=1 \
  "$FIXTURES/vvc-conformance/ACT_A_3.bit"
