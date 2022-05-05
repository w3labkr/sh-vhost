#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/fail2ban/fail2ban.sh
# ./ubuntu/18.04/fail2ban/fail2ban.sh

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
#./fail2ban.sh status
#./fail2ban.sh start
#./fail2ban.sh stop
#./fail2ban.sh reload
#./fail2ban.sh restart
#./fail2ban.sh enable
#./fail2ban.sh disable

## Client
# If the ip address is undefined, print the whole.

### Syntax
#./<package-name>.sh <command> <ip> <ip> <ip>

### Usage
#./fail2ban.sh client
#./fail2ban.sh client 000.000.000.0 000.000.000.0 000.000.000.0

## Log
# If the ip address is undefined, print the whole.

### Syntax
#./<package-name>.sh <command> <ip> <ip> <ip>

### Usage
#./fail2ban.sh log
#./fail2ban.sh log 000.000.000.0 000.000.000.0 000.000.000.0

## Destemail
# Email address is required.

### Syntax
#./<package-name>.sh <command> <email>

### Usage
#./fail2ban.sh destemail email@domain.com

## Sender
# Email address is required.

### Syntax
#./<package-name>.sh <command> <email>

### Usage
#./fail2ban.sh sender email@domain.com

## Banip
# At least one IP address is required.

### Syntax
#./<package-name>.sh <command> <ip> <ip> <ip>

### Usage
#./fail2ban.sh banip <ip> <ip> <ip>

## Unbanip
# At least one IP address is required.

### Syntax
#./<package-name>.sh <command> <ip> <ip> <ip>

### Usage
#./fail2ban.sh unbanip <ip> <ip> <ip>

echo
echo "Start the Frequently Used Package Command Wizard."

# Set subcommands.
case "$1" in
status | start | stop | reload | restart | enable | disable)
  SUBCOMMAND="$1"
  shift
  shift $((OPTIND - 1))
  ;;
client | log | destemail | sender | banip | unbanip)
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
  systemctl status fail2ban
  ;;
start)
  systemctl start fail2ban
  ;;
stop)
  systemctl stop fail2ban
  ;;
reload)
  systemctl reload fail2ban
  ;;
restart)
  systemctl restart fail2ban
  ;;
enable)
  systemctl enable fail2ban
  ;;
disable)
  systemctl disable fail2ban
  ;;
client)

  if [ $# -gt 0 ]; then
    fail2ban-client status sshd | grep "$@"
  else
    fail2ban-client status sshd
  fi

  ;;
log)

  if [ $# -gt 0 ]; then
    tail -f /var/log/fail2ban.log | grep "$@"
  else
    tail -f /var/log/fail2ban.log
  fi

  ;;
destemail)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  sed -i -E \
    -e "/\[DEFAULT\]/,/\[.*\]/{
      /destemail =/c\destemail = $1
    }" \
    /etc/fail2ban/jail.local

  systemctl restart fail2ban

  echo "Destemail has been changed to $1."
  ;;
sender)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  sed -i -E \
    -e "/\[DEFAULT\]/,/\[.*\]/{
      /sender =/c\sender = $1
    }" \
    /etc/fail2ban/jail.local

  systemctl restart fail2ban

  echo "Sender has been changed to $1."
  ;;
banip)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  fail2ban-client set sshd banip "$@"

  systemctl restart fail2ban

  echo "$@ is blocked."
  ;;
unbanip)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  fail2ban-client set sshd unbanip "$@"

  systemctl restart fail2ban

  echo "$@ is unblocked."
  ;;
esac

echo
echo "Exit the Frequently Used Package Command Wizard."
