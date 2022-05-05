#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/wordpress/uninstall.sh
# ./ubuntu/18.04/wordpress/uninstall.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set a relative path.
FILENAME="$(basename "$0")"
MDLPATH="$(dirname "$0")"
MDLNAME="$(basename "${MDLPATH}")"
LIBPATH="$(dirname "${MDLPATH}")"
LIBNAME="$(basename "${LIBPATH}")"
PKGPATH="$(dirname "${LIBPATH}")"
PKGNAME="$(basename "${PKGPATH}")"
OSPATH="$(dirname "${PKGPATH}")"

# Set absolute path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSLIB="${ABSPKG}/${LIBNAME}"
ABSMDL="${ABSLIB}/${MDLNAME}"
ABSPATH="${ABSMDL}/${FILENAME}"

# Include the file.
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"
source "${ABSPKG}/functions.sh"

# Make sure the package is installed.
pkgAudit "apache2"

echo
echo "The ${SERVER_NAME} starts to be removed."

# Set constants.
if [ "$(whoami)" == "root" ]; then
  HOME_DIR="/var/www"
else
  HOME_DIR="/home/$(whoami)/www"
fi

# Set the arguments.
for arg in "${@}"; do
  case $arg in
  --server-name=*)
    SERVER_NAME="$(echo "${arg}" | sed -E 's/(--server-name=)//')"
    ;;
  --document-root=*)
    DOCUMENT_ROOT="$(echo "$arg" | sed -E 's/(--document-root=)//')"
    ;;
  --dbname=*)
    DBNAME="$(echo "$arg" | sed -E 's/(--dbname=)//')"
    ;;
  --dbuser=*)
    DBUSER="$(echo "$arg" | sed -E 's/(--dbuser=)//')"
    ;;
  esac
done

# This is the default setting.
if [ -z "${SERVER_NAME}" ]; then
  echo
  echo "ServerName is not defined."
  exit 0
fi

if [ -z "${DOCUMENT_ROOT}" ]; then
  DOCUMENT_ROOT="${HOME_DIR}/${SERVER_NAME}/html"
fi

if [ -z "${DBNAME}" ]; then
  cd "${DOCUMENT_ROOT}"
  DBNAME="$(wp config get db_name)"
fi

if [ -z "${DBUSER}" ]; then
  cd "${DOCUMENT_ROOT}"
  DBUSER="$(wp config get db_user)"
fi

# Disabling virtualhost
if [ ! -z "$(isSite "${SERVER_NAME}")" ]; then
  cd /etc/apache2/sites-available
  a2dissite "${SERVER_NAME}.conf"
fi

# Disabling SSL virtualhost
if [ ! -z "$(isSite "${SERVER_NAME}-ssl")" ]; then
  cd /etc/apache2/sites-available
  a2dissite "${SERVER_NAME}-ssl.conf"
fi

# Removing public ip address to the /etc/hosts file
if [ ! -z "$(cat "/etc/hosts" | egrep "^${SERVER_NAME}$")" ]; then
  sed -i -E "/^${SERVER_NAME}$/d" /etc/hosts
fi

# Drop the database.
delDb --database="${DBNAME}" --username="${DBUSER}"

# Remove the directory completely.
delDir "${HOME_DIR}/${SERVER_NAME}"

# Reloading apache2
systemctl reload apache2

echo
echo "The ${SERVER_NAME} has been completely removed."