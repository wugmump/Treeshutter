#!/usr/bin/env zsh
set -uo pipefail
# -u = error on undefined vars
# -o pipefail = pipeline errors propagate

###############################################################################
#                        CONFIGURATION (EDIT THIS SECTION)
###############################################################################

# -------- Credentials --------
SSH_USER="MCAADAdmin"
SSH_PASS="XZw6vFzQRu"

# -------- List of Switch IPs --------
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

# -------- Global wait time (milliseconds) --------
# Example: 3000 = 3 seconds
WAIT_TIME=3000


###############################################################################
#                        START OF SCRIPT (NO EDITS BELOW)
###############################################################################

echo "Using SSH_USER=${SSH_USER}"
echo "Wait time: ${WAIT_TIME} ms"
echo "Switch count: ${#SWITCH_IPS[@]}"
echo

# Loop all switches in parallel
for HOST in "${SWITCH_IPS[@]}"; do
(
    echo ">>> Processing ${HOST} ..."

    # Export for Expect
    export HOST
    export SSH_USER
    export SSH_PASS
    export WAIT_TIME

    expect << 'EOF'
set timeout 30

# Read environment variables
set host $env(HOST)
set user $env(SSH_USER)
set pass $env(SSH_PASS)
set wait $env(WAIT_TIME)

# Start SSH session
spawn ssh -tt \
    -o StrictHostKeyChecking=accept-new \
    -o ConnectTimeout=5 \
    "$user@$host"

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

# Enter configuration mode
send "conf t\r"
expect "#"

########## gi1/0/1-40 ##########
send "int range gi1/0/1-40\r"
expect "#"
send "shut\r"
expect "#"
after $wait
send "no shut\r"
expect "#"

########## te1/0/41-46 ##########
send "int range te1/0/41-46\r"
expect "#"
send "shut\r"
expect "#"
after $wait
send "no shut\r"
expect "#"

########## gi2/0/1-40 ##########
send "int range gi2/0/1-40\r"
expect "#"
send "shut\r"
expect "#"
after $wait
send "no shut\r"
expect "#"

########## te2/0/41-46 ##########
send "int range te2/0/41-46\r"
expect "#"
send "shut\r"
expect "#"
after $wait
send "no shut\r"
expect "#"

# Exit config + logout
send "end\r"
expect "#"
send "exit\r"
expect eof

EOF

    echo ">>> Finished ${HOST}"
    echo
) &
done

# Wait for all background jobs to complete
wait
echo "All switches processed."