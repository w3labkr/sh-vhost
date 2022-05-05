#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/laravel/config.sh
# ./ubuntu/18.04/laravel/config.sh

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

echo
echo "Start setting up ${PKGNAME} configuration."

# Set constants.
if [ "$(whoami)" == "root" ]; then
  HOME_DIR="/var/www"
else
  HOME_DIR="/home/$(whoami)/www"
fi

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --no-a2ensite)
    NO_A2ENSITE="YES"
    ;;
  --server-port=*)
    SERVER_PORT="$(echo "${arg}" | sed -E 's/(--server-port=)//')"
    ;;
  --server-name=*)
    SERVER_NAME="$(echo "${arg}" | sed -E 's/(--server-name=)//')"
    ;;
  --server-alias=*)
    SERVER_ALIAS="$(echo "${arg}" | sed -E 's/(--server-alias=)//')"
    ;;
  --server-admin=*)
    SERVER_ADMIN="$(echo "${arg}" | sed -E 's/(--server-admin=)//')"
    ;;
  --document-root=*)
    DOCUMENT_ROOT="$(echo "${arg}" | sed -E 's/(--document-root=)//')"
    ;;
  --directory=*)
    DIRECTORY="$(echo "${arg}" | sed -E 's/(--directory=)//')"
    ;;
  --error-log=*)
    ERROR_LOG="$(echo "${arg}" | sed -E 's/(--error-log=)//')"
    ;;
  --access-log=*)
    ACCESS_LOG="$(echo "${arg}" | sed -E 's/(--access-log=)//')"
    ;;
  esac
done

# This is the default setting.
if [ -z "${SERVER_NAME}" ]; then
  echo "ServerName is not defined."
  exit 0
fi

if [ -z "${NO_A2ENSITE}" ]; then
  NO_A2ENSITE="NO"
fi

if [ -z "${SERVER_PORT}" ]; then
  SERVER_PORT="80 443"
fi

if [ -z "${SERVER_ALIAS}" ]; then
  SERVER_ALIAS=""
fi

if [ -z "${SERVER_ADMIN}" ]; then
  SERVER_ADMIN="webmaster@${SERVER_NAME}"
fi

if [ -z "${DOCUMENT_ROOT}" ]; then
  DOCUMENT_ROOT="${HOME_DIR}/${SERVER_NAME}/html"
fi

if [ -z "${DIRECTORY}" ]; then
  DIRECTORY="${DOCUMENT_ROOT}"
fi

if [ -z "${ERROR_LOG}" ]; then
  ERROR_LOG="${HOME_DIR}/${SERVER_NAME}/log/error.log"
fi

if [ -z "${ACCESS_LOG}" ]; then
  ACCESS_LOG="${HOME_DIR}/${SERVER_NAME}/log/access.log"
fi

# Make sure you have activated this script.
if [ "${NO_A2ENSITE^^}" == "YES" ]; then
  exit 0
fi

# Check and correct the invalid string in the directory path.
DOCUMENT_ROOT="$(echo "${DOCUMENT_ROOT}" | sed -E -e 's/\/+/\//g' -e 's/\/+$//g')"
DIRECTORY="$(echo "${DIRECTORY}" | sed -E -e 's/\/+/\//g' -e 's/\/+$//g')"

# Create the required directory if it does not exist.
addDir "${DOCUMENT_ROOT}"
addDir "${DIRECTORY}"
addDir "$(dirname "${ERROR_LOG}")"
addDir "$(dirname "${ACCESS_LOG}")"

# Activate the site registered on the server port.
PORTS=(${SERVER_PORT})
for i in "${!PORTS[@]}"; do
  case "${PORTS[$i]}" in
  "80")

    # Create a new vhosting configuration file.
    cp -v "${ABSPKG}/tmpl/vhost.conf" "/etc/apache2/sites-available/${SERVER_NAME}.conf"

    # Change from template settings to user settings.
    sed -i -E \
      -e "s/server_name_here/$(escapeString "${SERVER_NAME}")/" \
      -e "s/server_alias_here/$(escapeString "${SERVER_ALIAS}")/" \
      -e "s/server_admin_here/$(escapeString "${SERVER_ADMIN}")/" \
      -e "s/document_root_here/$(escapeString "${DOCUMENT_ROOT}")/" \
      -e "s/directory_here/$(escapeString "${DIRECTORY}")/" \
      -e "s/error_log_here/$(escapeString "${ERROR_LOG}")/" \
      -e "s/access_log_here/$(escapeString "${ACCESS_LOG}")/" \
      "/etc/apache2/sites-available/${SERVER_NAME}.conf"

    # Remove ServerAlias ​​if empty.
    if [ -z "${SERVER_ALIAS}" ]; then
      sed -i -E \
        -e "/ServerAlias/d" \
        "/etc/apache2/sites-available/${SERVER_NAME}.conf"
    fi

    # If the site is already active, deactivate the available site.
    if [ ! -z "$(isSite "${SERVER_NAME}")" ]; then
      cd /etc/apache2/sites-available
      a2dissite "${SERVER_NAME}.conf"
    fi

    # If the site is disabled, please activate the available site.
    if [ -z "$(isSite "${SERVER_NAME}")" ]; then
      cd /etc/apache2/sites-available
      a2ensite "${SERVER_NAME}.conf"
    fi

    ;;
  "443")

    # Create a new vhosting configuration file.
    cp -v "${ABSPKG}/tmpl/vhost-ssl.conf" "/etc/apache2/sites-available/${SERVER_NAME}-ssl.conf"

    # Change from template settings to user settings.
    sed -i -E \
      -e "s/server_name_here/$(escapeString "${SERVER_NAME}")/" \
      -e "s/server_alias_here/$(escapeString "${SERVER_ALIAS}")/" \
      -e "s/server_admin_here/$(escapeString "${SERVER_ADMIN}")/" \
      -e "s/document_root_here/$(escapeString "${DOCUMENT_ROOT}")/" \
      -e "s/directory_here/$(escapeString "${DIRECTORY}")/" \
      -e "s/error_log_here/$(escapeString "${ERROR_LOG}")/" \
      -e "s/access_log_here/$(escapeString "${ACCESS_LOG}")/" \
      "/etc/apache2/sites-available/${SERVER_NAME}-ssl.conf"

    # Remove ServerAlias ​​if empty.
    if [ -z "${SERVER_ALIAS}" ]; then
      sed -i -E \
        -e "/ServerAlias/d" \
        "/etc/apache2/sites-available/${SERVER_NAME}-ssl.conf"
    fi

    # If the site is already active, deactivate the available site.
    if [ ! -z "$(isSite "${SERVER_NAME}-ssl")" ]; then
      cd /etc/apache2/sites-available
      a2dissite "${SERVER_NAME}-ssl.conf"
    fi

    # If the site is disabled, please activate the available site.
    if [ -z "$(isSite "${SERVER_NAME}-ssl")" ]; then
      cd /etc/apache2/sites-available
      a2ensite "${SERVER_NAME}-ssl.conf"
    fi

    ;;
  esac
done

# Import variables from the env file.
PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

# Adding virtual host name to the /etc/hosts file.
if [ -z "$(cat "/etc/hosts" | egrep "^${SERVER_NAME}$")" ]; then
  sed -i "2 a\\${PUBLIC_IP} ${SERVER_NAME}" /etc/hosts
fi

# Reloading the service
systemctl reload apache2

echo
echo "${PKGNAME^} configuration is complete."
