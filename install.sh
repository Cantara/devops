#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="Cantara"
REPO_NAME="devops"
#REF="4a4479ddc6ff6d0ad6274655f328f2759b70be6c"
REF="master"
REMOTE_DIR="scripts"
DEST_DIR="scripts"

# If you prefer a branch instead of a pinned commit, change REF to e.g. "main".
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REF}/${REMOTE_DIR}"

FILES=(
  "CRON"
  "README.md"
  "download_and_restart_if_new.sh"
  "kill-service.sh"
  "semantic_update_service.properties"
  "semantic_update_service.sh"
  "start-service.sh"
)

mkdir -p "${DEST_DIR}"

download() {
  local url="$1"
  local out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$out"
  else
    echo "ERROR: Need either curl or wget installed." >&2
    exit 1
  fi
}

for f in "${FILES[@]}"; do
  echo "Downloading ${REMOTE_DIR}/${f} -> ${DEST_DIR}/${f}"
  download "${BASE_URL}/${f}" "${DEST_DIR}/${f}"
done

# Make shell scripts executable
chmod +x "${DEST_DIR}"/*.sh 2>/dev/null || true

echo "Done. Downloaded ${#FILES[@]} file(s) into ./${DEST_DIR}/"
