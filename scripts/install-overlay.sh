#!/bin/sh
set -eu

[ "$#" -le 1 ] || { echo "Usage: $0 [superconfigure-directory]" >&2; exit 2; }
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
value() { sed -n "s/^$1=//p" "$ROOT/superconfigure.lock"; }
REPOSITORY=$(value superconfigure_repository)
REF=$(value superconfigure_ref)
EXPECTED=$(value superconfigure_commit)
if [ "$#" -eq 0 ]; then
  SUPER=$ROOT/superconfigure
  if [ ! -e "$SUPER" ]; then git clone --depth 1 --branch "$REF" "$REPOSITORY" "$SUPER"; fi
else
  SUPER=$1
fi
SUPER=$(CDPATH= cd -- "$SUPER" && pwd)
ACTUAL=$(git -C "$SUPER" rev-parse HEAD 2>/dev/null || true)
[ "$ACTUAL" = "$EXPECTED" ] || { echo "expected superconfigure $EXPECTED, got ${ACTUAL:-not-a-matching-git-checkout}" >&2; exit 1; }
# Run the base project's setup and cosmo scripts before building. They clone
# current Cosmopolitan and generate its matching Cosmocc tree. dav1d's recipe
# downloads and verifies its pinned Meson source on demand.
mkdir -p "$SUPER/.ape-overlay-backups"
BACKUPS=$(mktemp -d "$SUPER/.ape-overlay-backups/ffmpeg-ffprobe-ape.XXXXXX")
install_tree() {
  relative=$1; source=$ROOT/$relative; destination=$SUPER/$relative
  mkdir -p "$(dirname -- "$destination")"
  if [ -e "$destination" ]; then mkdir -p "$BACKUPS/$(dirname -- "$relative")"; mv "$destination" "$BACKUPS/$relative"; fi
  cp -a "$source" "$destination"
}
enable() { grep -Fqx "$1" "$SUPER/$2" || printf '\n%s\n' "$1" >> "$SUPER/$2"; }
install_tree cli/ffmpeg
install_tree cli/ffprobe
install_tree cli/fatten
install_tree lib/dav1d
install_tree config/rules.mk
enable 'include cli/ffmpeg/BUILD.mk' cli/BUILD.mk
enable 'include cli/ffprobe/BUILD.mk' cli/BUILD.mk
enable 'include lib/dav1d/BUILD.mk' lib/BUILD.mk
printf 'Installed FFmpeg/FFprobe overlay into %s. Backup: %s\n' "$SUPER" "$BACKUPS"
