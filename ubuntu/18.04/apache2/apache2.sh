#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/apache2/apache2.sh
# ./ubuntu/18.04/apache2/apache2.sh

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
#./apache2.sh status
#./apache2.sh start
#./apache2.sh stop
#./apache2.sh reload
#./apache2.sh restart
#./apache2.sh enable
#./apache2.sh disable

echo
echo "Start the Frequently Used Package Command Wizard."

# Set subcommands.
case "$1" in
status | start | stop | reload | restart | enable | disable)
  SUBCOMMAND="$1"
  shift
  shift $((OPTIND - 1))
  ;;
*)
  echo "Command not defined."
  exit 0
  ;;
esac

# If the command is defined, run the script.
case "${SUBCOMMAND}" in
status)
  systemctl status apache2
  ;;
start)
  systemctl start apache2
  ;;
stop)
  systemctl stop apache2
  ;;
reload)
  systemctl reload apache2
  ;;
restart)
  systemctl restart apache2
  ;;
enable)
  systemctl enable apache2
  ;;
disable)
  systemctl disable apache2
  ;;
esac

echo
echo "Exit the Frequently Used Package Command Wizard."
