# redhat-scripts
Various scripts for use with Red Hat/Fedora products

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


### rhn-cdn-connect.sh
Script for testing connectivity and response time between a host and the Red Hat CDN.

**Usage:**
```sh
$ rhn-cdn-connect.sh
```
**Notes:**
  - Requires a RHN subscribed system
  - Supports using a proxy host


### servicewatch
Script which leverages cron to check whether a daemon is running or not based on the daemon name

**To install:**
```sh
$ git clone https://github.com/ayerlock/redhat-scripts
$ cd redhat-scripts/servicewatch
$ cp etc/cron.d/servicewatch /etc/cron.d/
$ mkdir -p /etc/servicewatch.d/
$ cp -a etc/servicewatch.d/* /etc/servicewatch.d/
$ cp -a usr/local/bin/servicewatch /usr/local/bin
$ chmod 775 /usr/local/bin/servicewatch
```
**Notes:**
  - Edit the `/etc/cron.d/servicewatch` file to set up how often you want the application to be watched
  - Edit the `/etc/servicewatch.d/<service>` file to configure how you want the service watched
