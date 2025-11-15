#!/usr/bin/env zsh
set -uo pipefail
# -u: undefined vars cause errors
# -o pipefail: pipeline errors propagate

###############################################################################
#                     CONFIGURATION — EDIT THIS PART
#
# NOTE:
#   These explicit credential + IP definitions pave the way for future
#   SSH-based credential storage solutions (e.g., SSH config, keyvault,
#   encrypted local keyrings, or per-switch credential maps).
###############################################################################

# ---- Login credentials ----
SSH_USER="MCAADAdmin"
SSH_PASS="XZw6vFzQRu"

# ---- Explicit list of switch IPs ----
SWITCH_IPS=(
  10.101.120.30
  10.101.120.31
  10.101.120.32
  10.101.120.33
  10.101.120.34
  10.101.120.35
  10.101.120.36
  10.101.120.37
  10.101.120.38
  10.101.120.39
  10.101.120.40
  10.101.120.41
  10.101.120.42
)

###############################################################################
#                           START OF SCRIPT
###############################################################################

echo "Using SSH_USER=${SSH_USER}"
echo "Switches to process: ${#SWITCH_IPS[@]}"
echo

# Loop over each switch IP
for HOST in "${SWITCH_IPS[@]}"; do
  echo ">>> Connecting to ${HOST} as ${SSH_USER}..."

  # -tt: force TTY
  # -o StrictHostKeyChecking=accept-new: avoid key prompts
  # -o ConnectTimeout=5: avoid long hangs
  #
  # The <<< 'exit' feeds an immediate exit command to close the
  # session cleanly, confirming the login works and credentials are valid.
  sshpass -p "${SSH_PASS}" ssh \
    -tt \
    -o StrictHostKeyChecking=accept-new \
    -o ConnectTimeout=5 \
    "${SSH_USER}@${HOST}" <<< "exit"

  echo ">>> Disconnected from ${HOST}"
  echo
done

echo "All switches processed."