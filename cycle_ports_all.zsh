#!/usr/bin/env zsh
set -uo pipefail

########################################
# LOAD CREDS
########################################

if [[ ! -f "./creds.txt" ]]; then
  echo "ERROR: creds.txt not found in current directory." >&2
  exit 1
fi

# creds.txt must define:
#   SSH_USER=<username>
#   SSH_PASS=<password>
source ./creds.txt
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

  echo ">>> Processing ${HOST} as ${SSH_USER}..."

  # make vars visible to expect
  export HOST
  export SSH_USER
  export SSH_PASS

  expect << 'EOF'
set timeout 30

set host $env(HOST)
set user $env(SSH_USER)
set pass $env(SSH_PASS)

# Start SSH session
spawn ssh -tt -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 "$user@$host"

# Handle login prompts
expect {
    "Username:" {
        send "$user\r"
        exp_continue
    }
    "username:" {
        send "$user\r"
        exp_continue
    }
    "Password:" {
        send "$pass\r"
        exp_continue
    }
    "password:" {
        send "$pass\r"
        exp_continue
    }
    ">" {}
    "#" {}
}

# We're at exec prompt (>, #)

# Enter config mode
send "conf t\r"
expect "#"

# int range gi1/0/1-40
send "int range gi1/0/1-40\r"
expect "#"
send "shut\r"
expect "#"

# wait 5 sec
after 5000

send "no shut\r"
expect "#"

# te1/0/41-46
send "int range te1/0/41-46\r"
expect "#"
send "shut\r"
expect "#"

# wait 5 sec
after 5000

# gi2/0/1-40
send "int range gi2/0/1-40\r"
expect "#"
send "shut\r"
expect "#"

# wait 5 sec
after 5000

send "no shut\r"
expect "#"

# te2/0/41-46
send "int range te2/0/41-46\r"
expect "#"

# wait 5 sec
after 5000

send "no shut\r"
expect "#"

# exit config & logout
send "end\r"
expect "#"
send "exit\r"
expect eof
EOF

  echo ">>> Finished ${HOST}"
  echo
done < "$HOST_FILE"