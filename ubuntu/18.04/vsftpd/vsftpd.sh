#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/vsftpd/vsftpd.sh
# ./ubuntu/18.04/vsftpd/vsftpd.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set a relative path.
FILENAME="$(basename $0)"
PKGPATH="$(dirname $0)"
PKGNAME="$(basename "${PKGPATH}")"
OSPATH="$(dirname "${PKGPATH}")"
LIBPATH="${PKGPATH}/lib"

# Set absolute path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSLIB="${ABSPKG}/lib"
ABSPATH="${ABSPKG}/${FILENAME}"

# Include the file.
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"
source "${ABSPKG}/functions.sh"

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

# Frequently Used Package Command Wizard
# The vhost systemctl command is the same as apach2.

## Systemctl
# status: <package-name> state loaded.
# start: <package-name> started.
# stop: <package-name> has stopped.
# reload: <package-name> was reloaded.
# restart: <package-name> restarted.
# enable: <package-name> is enabled.
# disable: <package-name> is disabled.

### Syntax
#./<package-name>.sh <command>

### Usage
#./vsftpd.sh status
#./vsftpd.sh start
#./vsftpd.sh stop
#./vsftpd.sh reload
#./vsftpd.sh restart
#./vsftpd.sh enable
#./vsftpd.sh disable

## a2query
# List of active virtual host sites.

### Syntax
#./<package-name>.sh <command>

### Usage
#./vhost.sh a2query

## a2dissite
# If the site is already active, deactivate it.
# The server name is required.

### Syntax
#./<package-name>.sh <command> <option> <option>

### Option
# --server-name=<domain.com>
# --server-port="80 443"

### Usage
#./vhost.sh a2dissite --server-name=domain.dom

echo
echo "Start the Frequently Used Package Command Wizard."

# Set subcommands.
case "$1" in
status | start | stop | reload | restart | enable | disable)
  SUBCOMMAND="$1"
  shift
  shift $((OPTIND - 1))
  ;;
a2query | a2dissite | a2ensite)
  SUBCOMMAND="$1"
  shift
  shift $((OPTIND - 1))
  ;;
*)
  echo "Command not defined."
  exit 0
  ;;
esac


./vsftpd.sh <command> <username>
./vsftpd.sh adduser --username=testuser
./vsftpd.sh deluser --username=testuser
./vsftpd.sh passwd --username=testuser


./vsftpd.sh ftponly

./vsftpd.sh user_list
./vsftpd.sh chroot_list

./vsftpd.sh ftpusers --allow
./vsftpd.sh ftpusers --deny



# If the command is defined, run the script.
case "${SUBCOMMAND}" in
status)
  systemctl status vsftpd
  ;;
start)
  systemctl start vsftpd
  ;;
stop)
  systemctl stop vsftpd
  ;;
reload)
  systemctl reload vsftpd
  ;;
restart)
  systemctl restart vsftpd
  ;;
enable)
  systemctl enable vsftpd
  ;;
disable)
  systemctl disable vsftpd
  ;;
adduser)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  username_create "$1"

  adduser "${create_username}"
  usermod -a -G www-data "${create_username}"
  
  if [ -z "$(cat "/etc/vsftpd.user_list" | egrep "^${create_username}$")" ]; then
    echo "${create_username}" | tee -a /etc/vsftpd.user_list
  fi

  # Disabling Shell Access
  usermod "${create_username}" -s /bin/ftponly

  # Restart the service.
  systemctl restart vsftpd

  echo "New users have been added."
  ;;
deluser)
  
  ;;
passwd)
  
  ;;
esac

echo
echo "Exit the Frequently Used Package Command Wizard."
