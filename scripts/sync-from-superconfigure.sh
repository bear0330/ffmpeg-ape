#!/bin/sh
# Synchronizes the FFmpeg/FFprobe APE overlay from a superconfigure checkout.
# Parent catalog entries are installed separately by install-overlay.sh.
set -eu

usage() {
  echo "Usage: $0 [--force] /path/to/superconfigure" >&2
  exit 2
}

FORCE=false
case "${1:-}" in
  --force) FORCE=true; shift ;;
esac
[ "$#" -eq 1 ] || usage

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOURCE=$(CDPATH= cd -- "$1" && pwd)
for path in cli/ffmpeg/BUILD.mk cli/ffprobe/BUILD.mk cli/fatten lib/dav1d/BUILD.mk config/rules.mk; do
  [ -e "$SOURCE/$path" ] || {
    echo "missing required source path: $SOURCE/$path" >&2
    exit 1
  }
done

PATHS='cli/ffmpeg cli/ffprobe cli/fatten lib/dav1d config/rules.mk'
if [ "$FORCE" != true ] && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  for path in $PATHS; do
    if [ -n "$(git -C "$ROOT" status --porcelain --untracked-files=all -- "$path")" ]; then
      echo "refusing to overwrite modified $path; commit/stash it or rerun with --force" >&2
      exit 1
    fi
  done
fi

STAGE=$(mktemp -d "${TMPDIR:-/tmp}/ffmpeg-ffprobe-ape-sync-stage.XXXXXX")
BACKUP=$(mktemp -d "${TMPDIR:-/tmp}/ffmpeg-ffprobe-ape-sync-backup.XXXXXX")
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT HUP INT TERM

for path in $PATHS; do
  mkdir -p "$STAGE/$(dirname -- "$path")"
  cp -pR "$SOURCE/$path" "$STAGE/$path"
done

sync_path() {
  relative=$1
  destination=$ROOT/$relative
  staged=$STAGE/$relative
  backup=$BACKUP/$relative
  mkdir -p "$(dirname -- "$destination")" "$(dirname -- "$backup")"
  if [ -e "$destination" ]; then mv "$destination" "$backup"; fi
  mv "$staged" "$destination"
}

for path in $PATHS; do sync_path "$path"; done

echo "Synchronized from $SOURCE"
echo "Replaced files are backed up at $BACKUP"
