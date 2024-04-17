#!/bin/sh
#
# Plesk chroot template for CentOS 7.9, Rocky 8 - 9, and Alma 8 - 9 by QWeb Ltd
#
# On CentOS 6, setting a domains Web Hosting Access -> Access to the server over SSH value to "/bin/bash (chrooted)" within Plesk just worked, but on CentOS 7.9, Rocky 8 - 9, and Alma 8 - 9 this causes PHP scripts set to run as cron tasks to break for a variety of reasons.
#
# This script configures the chroot template Plesk uses to resolve the various problems we've come across at QWeb:
#     - The PHP binaries provided by Plesk are made accessible within the chroot environment.
#     - DNS resolution is fixed within the chroot environment.
#     - MySQL/MariaDB is made accessible within the chroot environment, and to PHP, though mysqli_connect() only works with 127.0.0.1, not localhost.
#     - Curl and wget are made accessible within the chroot environment, fixing the various PHP functions that can be used to load remote resources.
#     - NSS libraries and SSL/TLS CAs are made accessible within the chroot environment, fixing Curl requests to https addresses.
#
# It's advised that you run each line of this script manually rather than actually running as a script, because for example the ldconfig step might result in an output that means you need to tailor the configuration slightly for your own environment.
#
# Thanks to John from the Plesk forums for pointing me in the right direction with this one.

# Ref https://support.plesk.com/hc/en-us/articles/12377962235159-How-to-add-programs-to-chrooted-shell-environment-template-in-Plesk
curl -o update_chroot.sh https://raw.githubusercontent.com/plesk/kb-scripts/master/update-chroot/update-chroot.sh
chmod 700 update_chroot.sh
sudo ./update_chroot.sh --rebuild

# Create some required directories ready to copy imporant files into.
# Some of these might already exist after running the above, so check for each before creating
sudo mkdir /var/www/vhosts/chroot/usr/share
sudo mkdir /var/www/vhosts/chroot/usr/lib64
sudo mkdir /var/www/vhosts/chroot/etc/ssl

# Important files and libraries.
sudo cp -a /usr/share/zoneinfo /var/www/vhosts/chroot/usr/share/zoneinfo
sudo cp -a /usr/lib64/*.so* /var/www/vhosts/chroot/usr/lib64/
# On some distributions MariaDB uses the same mysql binary, but others user a mariadb binary instead
sudo cp -a /usr/lib64/mysql /var/www/vhosts/chroot/usr/lib64/
sudo cp -a /usr/lib64/mariadb /var/www/vhosts/chroot/usr/lib64/

# Might not be needed if /etc/ssl/certs isn't a symlink to /etc/pki
sudo cp -a /etc/pki /var/www/vhosts/chroot/etc/

sudo cp -a /etc/ssl/certs /var/www/vhosts/chroot/etc/ssl/

# Add the various PHP binaries provided by Plesk. Skip versions not installed on your own set-up, and add any that are needed.
sudo ./update_chroot.sh --add /opt/plesk/php/5.6/bin/php
sudo ./update_chroot.sh --add /opt/plesk/php/7.1/bin/php
sudo ./update_chroot.sh --add /opt/plesk/php/7.2/bin/php
sudo ./update_chroot.sh --add /opt/plesk/php/7.3/bin/php
sudo ./update_chroot.sh --add /opt/plesk/php/7.4/bin/php
sudo ./update_chroot.sh --add /opt/plesk/php/8.0/bin/php
sudo ./update_chroot.sh --add /opt/plesk/php/8.1/bin/php
sudo ./update_chroot.sh --add /opt/plesk/php/8.2/bin/php
sudo ./update_chroot.sh --add /opt/plesk/php/8.3/bin/php
for i in /opt/plesk/php/5.6/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done
for i in /opt/plesk/php/7.1/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done
for i in /opt/plesk/php/7.2/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done
for i in /opt/plesk/php/7.3/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done
for i in /opt/plesk/php/7.4/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done
for i in /opt/plesk/php/8.0/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done
for i in /opt/plesk/php/8.1/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done
for i in /opt/plesk/php/8.2/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done
for i in /opt/plesk/php/8.3/lib64/php/modules/*.so; do sudo ./update_chroot.sh --add $i; done

# More important files for those binaries. Again, skip versions not installed on your own set-up, and add any that are needed.
sudo cp -a /opt/plesk/php/5.6/etc /var/www/vhosts/chroot/opt/plesk/php/5.6/
sudo cp -a /opt/plesk/php/7.1/etc /var/www/vhosts/chroot/opt/plesk/php/7.1/
sudo cp -a /opt/plesk/php/7.2/etc /var/www/vhosts/chroot/opt/plesk/php/7.2/
sudo cp -a /opt/plesk/php/7.3/etc /var/www/vhosts/chroot/opt/plesk/php/7.3/
sudo cp -a /opt/plesk/php/7.4/etc /var/www/vhosts/chroot/opt/plesk/php/7.4/
sudo cp -a /opt/plesk/php/8.0/etc /var/www/vhosts/chroot/opt/plesk/php/8.0/
sudo cp -a /opt/plesk/php/8.1/etc /var/www/vhosts/chroot/opt/plesk/php/8.1/
sudo cp -a /opt/plesk/php/8.2/etc /var/www/vhosts/chroot/opt/plesk/php/8.2/
sudo cp -a /opt/plesk/php/8.3/etc /var/www/vhosts/chroot/opt/plesk/php/8.3/

# Important device nodes. Some of these might already be included in the default chroot environment. The update script will just spit out a safe to ignore notice if so.
sudo ./update_chroot.sh --devices tty
sudo ./update_chroot.sh --devices urandom

# SSH and SFTP binaries to fix PHPs built in SFTP stream functions. May also be needed for SFTP connections to the website files as the domain user though my notes here have gotten lost.
sudo ./update_chroot.sh --add ssh

# Ref subsystem= line in /etc/ssh/sshd_config. If this is something other than /usr/libexec/openssh/sftp-server, use that instead.
sudo ./update_chroot.sh --add /usr/libexec/openssh/sftp-server

# Adds MySQL and MariaDB to the environment to fix PHPs mysql and mysqli functions.
sudo ./update_chroot.sh --add mysql
sudo ./update_chroot.sh --add mariadb

# Adds wget and curl to the environment so that PHPs various functions can pull remote files.
sudo ./update_chroot.sh --add wget
sudo ./update_chroot.sh --add curl

# Adds DNS lookup stuff to the environment. This might not be needed actually. You could "sudo chroot /var/www/vhosts/chroot" and test "curl http://www.google.com" first to check.
sudo ./update_chroot.sh --add named
sudo ./update_chroot.sh --add nslookup

# Adds ldconfig to the environment. This is apparently already done with newer versions of the update_chroot script, but there's no harm in doing it manually anyway.
sudo ./update_chroot.sh --add ldconfig
sudo chroot /var/www/vhosts/chroot /bin/sh -c "ldconfig -v"

# If the above output generates any "Can't stat .... No such file or directory" messages, cp directories that seem important like with the /usr/lib/mysql cp above, and then re-run.

# Apply the new template to all domains currently set to "/bin/bash (chrooted)". Subsequently created domains will use the new template automatically I believe.
sudo ./update_chroot.sh --apply all
