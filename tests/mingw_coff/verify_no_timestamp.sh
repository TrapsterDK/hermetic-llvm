#!/usr/bin/env bash
# Verifies that MinGW COFF objects have a zero TimeDateStamp (bytes 4..8 of
# the COFF file header), so that rebuilding them gives identical bytes.
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: $0 <object>..." >&2
  exit 2
fi

for object in "$@"; do
  stamp=$(od -An -tx1 -j4 -N4 "$object" | tr -d ' \n')
  if [[ "$stamp" != "00000000" ]]; then
    echo "FAIL: $object has TimeDateStamp 0x$stamp, want 0" >&2
    exit 1
  fi
done
