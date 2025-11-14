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

  echo ">>> Processing ${HOST} as ${SSH_USER}..."

  # export vars so expect can see them
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

# Handle username/password prompts and land at exec prompt (">" or "#")
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

# Now we're in exec mode

# Enter config mode
send "conf t\r"
expect "#"

# gi1/0/1-40 shut
send "int range gi1/0/1-40\r"
expect "#"
send "shut\r"
expect "#"

# wait 5 seconds (on the Mac side)
after 5000

# gi1/0/1-40 no shut
send "no shut\r"
expect "#"

# wait 5 seconds
after 5000

# gi2/0/1-40 shut
send "int range gi2/0/1-40\r"
expect "#"
send "shut\r"
expect "#"

# wait 5 seconds
after 5000

# gi2/0/1-40 no shut
send "no shut\r"
expect "#"

# exit config mode and log out
send "end\r"
expect "#"
send "exit\r"
expect eof
EOF

  echo ">>> Finished ${HOST}"
  echo
done < "$HOST_FILE"