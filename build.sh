#!/usr/bin/env bash
# Package RPS addon for drop-in install: copy dist/RPS into the game's Interface/AddOns folder.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADDON_NAME="RPS"
OUT_ROOT="${SCRIPT_DIR}/dist"
OUT_DIR="${OUT_ROOT}/${ADDON_NAME}"

rm -rf "${OUT_ROOT}"
mkdir -p "${OUT_DIR}"

cp "${SCRIPT_DIR}/RPS.toc" "${OUT_DIR}/"

while IFS= read -r -d '' f; do
  rel="${f#${SCRIPT_DIR}/}"
  dest="${OUT_DIR}/${rel}"
  mkdir -p "$(dirname "${dest}")"
  cp "${f}" "${dest}"
done < <(find "${SCRIPT_DIR}" -name '*.lua' ! -path '*/dist/*' -print0)

ZIP_PATH="${OUT_ROOT}/${ADDON_NAME}.zip"
rm -f "${ZIP_PATH}"
( cd "${OUT_ROOT}" && zip -rq "${ADDON_NAME}.zip" "${ADDON_NAME}" )

echo "Packaged addon -> ${OUT_DIR}"
echo "Zip archive     -> ${ZIP_PATH}"
echo "Copy the folder or unzip into your client's Interface/AddOns directory (top-level folder must be \"${ADDON_NAME}\")."
