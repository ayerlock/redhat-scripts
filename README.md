# redhat-scripts
Various scripts for use with Red Hat/Fedora products
-------------------------------------------------------------------------------------------------------------------------------
### auditwatch
Script for monitoring the audit log for a specific event or set of events and then outputting a process tree map in order to determine what initialized the events in question.

**Usage:**
```txt
# ./auditwatch -h
 auditwatch:    Usage: ./auditwatch [-dvhcf:L:e:t:]
 auditwatch:             -d: Enable debug output
 auditwatch:             -v: Enable verbose output
 auditwatch:             -h: Usage/Help output
 auditwatch:             -f: Log File (default: /var/log/auditwatch.log)
 auditwatch:             -c: Clear logfile before run.
 auditwatch:             -L: Audit log to watch (default: /var/log/audit/audit.log)
 auditwatch:             -e: Event executable to monitor for (i.e. /bin/bash)
 auditwatch:             -t: Event type to monitor for (i.e. SYSCALL, SERVICE_START, SERVICE_STOP)
```

**Example:**
```sh
$ auditwatch -c -e /usr/libexec/openssh/sshd-session -t USER
 auditwatch:    Previous logfile removed...
 auditwatch:    Watching logfile:               /var/log/audit/audit.log
 auditwatch:       ...for events including:     exe="/usr/libexec/openssh/sshd-session"
 auditwatch:       ...for events including:     type=USER

====== EVENT #1 === START === 2025-06-09 15:12:05.864690200 ====================================================================
   EVENT [ type=USER_END msg=audit(1749496325.855:633567): pid=4185183 uid=0 auid=0 ses=1688 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=0 exe="/usr/libexec/openssh/sshd-session" hostname=? addr=? terminal=/dev/pts/6 res=success'UID="root" AUID="root" ID="root" ]

        systemd,1 --switched-root --system --deserialize=50 rhgb
          |-NetworkManager,1415 --no-daemon
          |   |-{gdbus},1429
          |   |-{gmain},1427
          |   `-{pool-spawner},1428
...
          |-sshd,1564
          |   |-sshd-session,5800
          |   |-sshd-session,4085081
          |   |   `-sshd-session,4085085
          |   |       `-bash,4085086
          |   |           |-auditwatch,5715 ./auditwatch -c -e /usr/libexec/openssh/sshd-session -t USER
          |   |           |   |-pstree,5849 -lputa
          |   |           |   |-sed,5850 -e s/^/\\t/g
          |   |           |   |-tail,5729 -n0 -F /var/log/audit/audit.log
          |   |           |   `-tee,5851 -a /var/log/auditwatch.log
          |   |           `-tail,5766 -f nohup.out
          |   `-sshd-session,4127103
          |       `-sshd-session,4127107
          |           `-bash,4127108
          `-wpa_supplicant,1552 -c /etc/wpa_supplicant/wpa_supplicant.conf -u -s
====== EVENT #1 ==== END ==== 2025-06-09 15:12:05.923311810 ======================================================================
```
**Notes:**
  - Script _**should not**_ be affected by any audit log rotations that occur while waiting on a matching event.
  - Needs to be run as either root or via sudo since it must be able to view both the audit file and the entire process tree in order to capture events

-------------------------------------------------------------------------------------------------------------------------------
### rpmextract
Script for extracting an RPM into a subdirectory named after the RPM into your current directory.
**Usage:**
```sh
$ rpmextract rpmfile-1.0-1.el7.x86_64.rpm
Extracting RPM to:      ./rpmfile-1.0-1.el7.x86_64 ... done!

$ ls -l
drwxrwsr-x. 1 root    root          4 Jan 01 00:00 rpmfile-1.0-1.el7.x86_64
-rw-r--r--. 1 root    root       2048 Dec 31 23:30 rpmfile-1.0-1.el7.x86_64.rpm
```
**Notes:**
  - Editing the script allows you to remove additional parts of the RPM filename from the created path.  (See script for details)


-------------------------------------------------------------------------------------------------------------------------------
### rhn-cdn-connect.sh
Script for testing connectivity and response time between a host and the Red Hat CDN.

**Usage:**
```sh
$ rhn-cdn-connect.sh
```
**Notes:**
  - Requires a RHN subscribed system
  - Supports using a proxy host


-------------------------------------------------------------------------------------------------------------------------------
### servicewatch
Script which leverages cron to check whether a daemon is running or not based on the daemon name

**To install:**
```sh
$ git clone https://github.com/ayerlock/redhat-scripts
$ cd redhat-scripts/src/servicewatch
$ cp etc/cron.d/servicewatch /etc/cron.d/
$ mkdir -p /etc/servicewatch.d/
$ cp -a etc/servicewatch.d/* /etc/servicewatch.d/
$ cp -a usr/local/bin/servicewatch /usr/local/bin
$ chmod 775 /usr/local/bin/servicewatch
```
**Notes:**
  - Edit the `/etc/cron.d/servicewatch` file to set up how often you want the application to be watched
  - Edit the `/etc/servicewatch.d/<service>` file to configure how you want the service watched
