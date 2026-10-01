#!/bin/sh
set -eu
BIN=${1:?usage: $0 /path/to/ffmpeg.com}
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
FIXTURES="$ROOT/cli/ffprobe/fixtures"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT HUP INT TERM

"$BIN" -version
"$BIN" -v error -threads 4 -i "$FIXTURES/h264-444/444_8bit_cabac.h264" -frames:v 10 -f rawvideo -y "$WORK/h264.yuv"
"$BIN" -v error -threads 4 -i "$FIXTURES/av1/film_grain.ivf" -frames:v 10 -f rawvideo -y "$WORK/av1.yuv"
[ -s "$WORK/h264.yuv" ] && [ -s "$WORK/av1.yuv" ]
