#!/usr/bin/env bash
# Makes the release files in dist/release/: sound_all.deb, the Arch package sound-VERSION-1-any.pkg.tar.zst and SHA256SUMS (signed later, locally, with
# icenux-app-sign-upload.sh; the signing key never reaches GitHub).
#
# Usage: bash packaging/package.sh VERSION     (needs nfpm in PATH; VERSION must match VERSION in ./sound)
set -euo pipefail
umask 022
cd "$(dirname "$0")/.."

VERSION=${1:?usage: packaging/package.sh VERSION}
export VERSION
built=$(sed -n 's/^VERSION="\(.*\)"/\1/p' sound | head -1)
[ "$built" = "$VERSION" ] || { echo "Version in sound ($built) != $VERSION" >&2; exit 1; }
out=dist/release
rm -rf "$out" && mkdir -p "$out"

nfpm package --config packaging/nfpm.yaml --packager deb --target "$out/sound_all.deb"
nfpm package --config packaging/nfpm.yaml --packager archlinux --target "$out/"
(cd "$out" && sha256sum sound_all.deb sound-*.pkg.tar.zst > SHA256SUMS)
ls -l "$out"
