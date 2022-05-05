#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/vhost/vhost.sh
# ./ubuntu/18.04/vhost/vhost.sh

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
pkgAudit "apache2"

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
#./vhost.sh status
#./vhost.sh start
#./vhost.sh stop
#./vhost.sh reload
#./vhost.sh restart
#./vhost.sh enable
#./vhost.sh disable

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

## a2dissite
# Activate the site if it is disabled.
# The server name is required.

### Syntax
#./<package-name>.sh <command> <option> <option>

### Option
# --server-name=<domain.com>
# --server-port="80 443"

### Usage
#./vhost.sh a2ensite --server-name=domain.dom

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
a2query)
  a2query -s
  ;;
a2dissite)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  # Set the arguments.
  for arg in "${@}"; do
    case $arg in
    --server-port=*)
      SERVER_PORT="$(echo "${arg}" | sed -E 's/(--server-port=)//')"
      ;;
    --server-name=*)
      SERVER_NAME="$(echo "${arg}" | sed -E 's/(--server-name=)//')"
      ;;
    esac
  done

  # Make sure ServerName is defined.
  if [ -z "${SERVER_NAME}" ]; then
    echo "ServerName is not defined."
    exit 0
  fi

  # This is the default setting.
  if [ -z "${SERVER_PORT}" ]; then
    SERVER_PORT="80 443"
  fi

  # Go to the directory where you can activate the site.
  cd /etc/apache2/sites-available

  # If the site is active, deactivate the site.
  PORTS=(${SERVER_PORT})
  for i in "${!PORTS[@]}"; do
    case "${PORTS[$i]}" in
    "80")
      if [ ! -z "$(isSite "${SERVER_NAME}")" ]; then
        a2dissite "${SERVER_NAME}.conf"
      fi
      ;;
    "443")
      if [ ! -z "$(isSite "${SERVER_NAME}-ssl")" ]; then
        a2dissite "${SERVER_NAME}-ssl.conf"
      fi
      ;;
    esac
  done

  ;;
a2ensite)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  # Set the arguments.
  for arg in "${@}"; do
    case $arg in
    --server-port=*)
      SERVER_PORT="$(echo "${arg}" | sed -E 's/(--server-port=)//')"
      ;;
    --server-name=*)
      SERVER_NAME="$(echo "${arg}" | sed -E 's/(--server-name=)//')"
      ;;
    esac
  done

  # Make sure ServerName is defined.
  if [ -z "${SERVER_NAME}" ]; then
    echo "ServerName is not defined."
    exit 0
  fi

  # This is the default setting.
  if [ -z "${SERVER_PORT}" ]; then
    SERVER_PORT="80 443"
  fi

  # Go to the directory where you can activate the site.
  cd /etc/apache2/sites-available

  # If disabled, please activate the site.
  PORTS=(${SERVER_PORT})
  for i in "${!PORTS[@]}"; do
    case "${PORTS[$i]}" in
    "80")
      if [ -z "$(isSite "${SERVER_NAME}")" ]; then
        a2ensite "${SERVER_NAME}.conf"
      fi
      ;;
    "443")
      if [ -z "$(isSite "${SERVER_NAME}-ssl")" ]; then
        a2ensite "${SERVER_NAME}-ssl.conf"
      fi
      ;;
    esac
  done

  ;;
esac

echo
echo "Exit the Frequently Used Package Command Wizard."
