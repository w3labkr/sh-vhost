#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/mariadb/mariadb.sh
# ./ubuntu/18.04/mariadb/mariadb.sh

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
#./mariadb.sh status
#./mariadb.sh start
#./mariadb.sh stop
#./mariadb.sh reload
#./mariadb.sh restart
#./mariadb.sh enable
#./mariadb.sh disable

## Create database
# One or more arguments are required.
# If the value is empty, a random string is assigned.

### Syntax
#./<package-name>.sh <command> <option> <option> <option>

### Option
# --database=<database-name>
# --username=<database-username>
# --password=<database-password>

### Usage
#./mariadb.sh create --database= --username= --password=
#./mariadb.sh create --database= --password=
#./mariadb.sh create --database=

## Drop database
# One or more arguments are required.
# The database name is required.
# If usename is empty, it is specified as the database name.

### Syntax
#./<package-name>.sh <command> <option> <option> <option>

### Option
# --database=<database-name>
# --username=<database-username>

### Usage
#./mariadb.sh drop --database= --username=
#./mariadb.sh drop --database=

echo
echo "Start the Frequently Used Package Command Wizard."

# Set subcommands.
case "$1" in
status | start | stop | reload | restart | enable | disable)
  SUBCOMMAND="$1"
  shift
  shift $((OPTIND - 1))
  ;;
create | drop)
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
  systemctl status mariadb
  ;;
start)
  systemctl start mariadb
  ;;
stop)
  systemctl stop mariadb
  ;;
reload)
  systemctl reload mariadb
  ;;
restart)
  systemctl restart mariadb
  ;;
enable)
  systemctl enable mariadb
  ;;
disable)
  systemctl disable mariadb
  ;;
create)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  # Set the arguments.
  for arg in "${@}"; do
    case $arg in
    --database=*)
      DATABASE="$(echo "${arg}" | sed -E 's/(--database=)//')"
      shift
      shift $((OPTIND - 1))
      ;;
    --username=*)
      USERNAME="$(echo "${arg}" | sed -E 's/(--username=)//')"
      shift
      shift $((OPTIND - 1))
      ;;
    --password=*)
      PASSWORD="$(echo "${arg}" | sed -E 's/(--password=)//')"
      shift
      shift $((OPTIND - 1))
      ;;
    esac
  done

  # Set the default if the variable is empty.
  if [ -z "${DATABASE}" ]; then
    DATABASE="$(setDbName)"
  fi

  if [ -z "${USERNAME}" ]; then
    USERNAME="${DATABASE}"
  fi

  if [ -z "${PASSWORD}" ]; then
    PASSWORD="$(setDbPass)"
  fi

  # Check and correct the invalid string.
  DATABASE="$(validDbName "${DATABASE}")"
  USERNAME="$(validDbUser "${USERNAME}")"
  PASSWORD="$(validDbPass "${PASSWORD}")"

  # Make sure the database and username exist.
  if [ ! -z "$(isDbName "${DATABASE}")" ]; then
    echo "Database already exists."
    exit 0
  elif [ ! -z "$(isDbUser "${USERNAME}")" ]; then
    echo "Username already exists."
    exit 0
  fi

  # Create a database and database username.
  mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${DATABASE};"
  mysql -uroot -e "CREATE USER IF NOT EXISTS '${USERNAME}'@'localhost' IDENTIFIED BY '${PASSWORD}';"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO '${USERNAME}'@'localhost';"
  mysql -uroot -e "FLUSH PRIVILEGES;"

  # Print the information.
  echo
  echo "The database has been created."
  echo "Database: ${DATABASE}"
  echo "Username: ${USERNAME}"
  echo "Password: ${PASSWORD}"

  ;;
drop)

  # Make sure the argument is defined.
  if [ $# -eq 0 ]; then
    echo "Argument not defined."
    exit 0
  fi

  # Set the arguments.
  for arg in "${@}"; do
    case $arg in
    --database=*)
      DATABASE="$(echo "${arg}" | sed -E 's/(--database=)//')"
      shift
      shift $((OPTIND - 1))
      ;;
    --username=*)
      USERNAME="$(echo "${arg}" | sed -E 's/(--username=)//')"
      shift
      shift $((OPTIND - 1))
      ;;
    esac
  done

  # Make sure the database is defined and exists.
  if [ -z "${DATABASE}" ]; then
    echo "Database is not defined."
    exit 0
  elif [ -z "$(isDbName "${DATABASE}")" ]; then
    echo "Database does not exists."
    exit 0
  fi

  # Set the default if the variable is empty.
  if [ -z "${USERNAME}" ]; then
    USERNAME="${DATABASE}"
  fi

  # If the database name and username exist, delete the database and database username.
  mysql -uroot -e "DROP DATABASE IF EXISTS ${DATABASE};"
  mysql -uroot -e "DROP USER IF EXISTS '${USERNAME}'@'localhost';"
  mysql -uroot -e "FLUSH PRIVILEGES;"

  # Print the information.
  echo
  echo "The database has been deleted."

  ;;
esac

echo
echo "Exit the Frequently Used Package Command Wizard."
