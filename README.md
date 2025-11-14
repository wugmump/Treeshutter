# README.md

## **TreeShutter -- Automated Port Cycling for Network Switches**

TreeShutter is a macOS-based automation tool for cycling large groups of
switch ports across multiple network switches.\
It uses:

-   A list of host IPs (`switches.txt`)
-   A credentials file (`creds.txt`)
-   An automation script (`cycle_ports_all.zsh`)
-   The `expect` utility to maintain a persistent SSH session per switch

The script performs the following actions on each switch, in a **single
continuous SSH session**:

1.  Enter configuration mode\
2.  Shut ports `gi1/0/1–40`\
3.  Wait 5 seconds\
4.  Bring ports `gi1/0/1–40` back up\
5.  Wait 5 seconds\
6.  Shut ports `gi2/0/1–40`\
7.  Wait 5 seconds\
8.  Bring ports `gi2/0/1–40` back up\
9.  Exit configuration mode\
10. Log out\
11. Move on to the next switch automatically

------------------------------------------------------------------------

## **File Structure**

    treeshutter/
    │
    ├── cycle_ports_all.zsh   # Main automation script
    ├── creds.txt             # Credentials file (SSH_USER / SSH_PASS)
    ├── switches.txt          # List of switch IPs
    └── README.md             # This file

------------------------------------------------------------------------

## **Requirements**

### **1. macOS with zsh**

TreeShutter runs on macOS using the default zsh shell.

### **2. Homebrew**

Required to install dependencies:

https://brew.sh/

### **3. sshpass**

Used to pass the SSH password non-interactively.

Install:

``` bash
brew install hudochenkov/sshpass/sshpass
```

### **4. expect**

Used to maintain an open SSH session so commands and sleeps can be
sequenced correctly.

Install:

``` bash
brew install expect
```

### **5. A valid `creds.txt` file**

Example:

    SSH_USER=MCAADAdmin
    SSH_PASS=YourPasswordHere

Restrict permissions:

``` bash
chmod 600 creds.txt
```

### **6. A `switches.txt` file**

One IP per line:

    10.101.120.30
    10.101.120.31
    10.101.120.32

------------------------------------------------------------------------

## **Usage**

``` bash
chmod +x cycle_ports_all.zsh
./cycle_ports_all.zsh
```

------------------------------------------------------------------------

## **Security Notes**

-   Passwords are stored unencrypted in `creds.txt`.\
-   Use `chmod 600 creds.txt` to restrict access.

------------------------------------------------------------------------
