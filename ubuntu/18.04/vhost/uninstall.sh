#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/vhost/uninstall.sh
# ./ubuntu/18.04/vhost/uninstall.sh

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
echo "The ${DOMAIN} starts to be removed."

DOMAIN=""

for arg in "${@}"; do
  case $arg in
  --domain=*)
    DOMAIN="$(echo "${arg}" | sed -E 's/(--domain=)//')"
    ;;
  esac
done

echo
while [ -z "${DOMAIN}" ]; do
  DOMAIN="$(msg -yn -c "Please enter your domain: ")"
  if [ -z "$(isSite "${DOMAIN}")" ]; then
    echo "${DOMAIN} does not exists."
    DOMAIN=""
  fi
done

# Disabling default vhosting
if [ ! -z "$(isSite "000-default")" ]; then
  cd /etc/apache2/sites-available
  a2dissite 000-default.conf
fi

# Disabling default SSL vhosting
if [ ! -z "$(isSite "000-default-ssl")" ]; then
  cd /etc/apache2/sites-available
  a2dissite 000-default-ssl.conf
fi

# Disabling virtualhost
if [ ! -z "$(isSite "${DOMAIN}")" ]; then
  cd /etc/apache2/sites-available
  a2dissite "${DOMAIN}.conf"
fi

# Disabling SSL virtualhost
if [ ! -z "$(isSite "${DOMAIN}-ssl")" ]; then
  cd /etc/apache2/sites-available
  a2dissite "${DOMAIN}-ssl.conf"
fi

# Removing public ip address to the /etc/hosts file
if [ ! -z "$(cat "/etc/hosts" | egrep "^${DOMAIN}$")" ]; then
  sed -i -E "/^${DOMAIN}$/d" /etc/hosts
fi

# Removing virtualhost directory
delDir "/var/www/${DOMAIN}"

# Drop the database.
DB_NAME="${DOMAIN//[^a-zA-Z0-9_]/}"
DB_NAME="${DB_NAME:0:16}"
DB_USER="${DB_NAME}"
DB_USER="${DB_USER:0:16}"

if [ ! -z "$(isDbName "${DB_NAME}")" ] || [ ! -z "$(isDbUser "${DB_USER}")" ]; then
  delDb "${DB_NAME}" "${DB_USER}"
fi

# Reloading apache2
systemctl reload apache2

echo
echo "The ${DOMAIN} has been completely removed."
