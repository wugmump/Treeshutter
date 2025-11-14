#!/usr/bin/env zsh
set -uo pipefail

########################################
# LOAD CREDS
########################################

if [[ ! -f "./creds.txt" ]]; then
  echo "ERROR: creds.txt not found in current directory." >&2
  exit 1
fi

source ./creds.txt   # defines $SSH_USER and $SSH_PASS

echo "Using SSH_USER=${SSH_USER}"

########################################
# HOST LIST
########################################

HOST_FILE="switches.txt"

if [[ ! -f "$HOST_FILE" ]]; then
  echo "ERROR: $HOST_FILE not found." >&2
  exit 1
fi

########################################
# MAIN LOOP
########################################

while IFS= read -r HOST || [[ -n "$HOST" ]]; do
  [[ -z "$HOST" ]] && continue

  echo ">>> Connecting to ${HOST} as ${SSH_USER}..."

  # -tt forces a TTY  
  # The <<< "exit" feeds an exit command to close the session immediately
  sshpass -p "$SSH_PASS" ssh \
    -tt \
    -o StrictHostKeyChecking=accept-new \
    -o ConnectTimeout=5 \
    "${SSH_USER}@${HOST}" <<< "exit"

  echo ">>> Finished ${HOST}"
  echo
done < "$HOST_FILE"