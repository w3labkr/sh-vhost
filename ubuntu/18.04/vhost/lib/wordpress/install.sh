#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/wordpress/install.sh
# ./ubuntu/18.04/wordpress/install.sh
#
# Installation
# https://github.com/wp-cli/wp-cli
# https://make.wordpress.org/cli/handbook/quick-start/

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
DBPATH="${OSPATH}/mariadb"

# Set absolute path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSDB="${ABSOS}/mariadb"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSLIB="${ABSPKG}/${LIBNAME}"
ABSMDL="${ABSLIB}/${MDLNAME}"
ABSPATH="${ABSMDL}/${FILENAME}"

# Include the file.
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"
source "${ABSDB}/functions.sh"
source "${ABSPKG}/functions.sh"

echo
echo "Start installing wordpress."

# Set constants.
if [ "$(whoami)" == "root" ]; then
  HOME_DIR="/var/www"
else
  HOME_DIR="/home/$(whoami)/www"
fi

# Set the arguments.
for arg in "${@}"; do
  case "$arg" in
  --framework=*)
    FRAMEWORK="$(echo "$arg" | sed -E 's/(--framework=)//')"
    ;;
  --server-port=*)
    SERVER_PORT="$(echo "$arg" | sed -E 's/(--server-port=)//')"
    ;;
  --server-name=*)
    SERVER_NAME="$(echo "$arg" | sed -E 's/(--server-name=)//')"
    ;;
  --document-root=*)
    DOCUMENT_ROOT="$(echo "$arg" | sed -E 's/(--document-root=)//')"
    ;;
  --subdirectory=*)
    SUBDIRECTORY="$(echo "$arg" | sed -E 's/(--subdirectory=)//')"
    ;;
  --wp-dir=*|--wp-directory=*|--wordpress-dir=*|--wordpress-directory=*)
    WP_DIR="$(echo "$arg" | sed -E 's/(--wp-dir=|--wp-directory=|--wordpress-dir=|--wordpress-directory=))//')"
    ;;
  --no-db | --no-database)
    NO_DATABASE="YES"
    ;;
  --dbhost=*)
    DBHOST="$(echo "$arg" | sed -E 's/(--dbhost=)//')"
    if [ ! -z "${DBHOST}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --dbcharset=*)
    DBCHARSET="$(echo "$arg" | sed -E 's/(--dbcharset=)//')"
    if [ ! -z "${DBCHARSET}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --dbcollate=*)
    DBCOLLATE="$(echo "$arg" | sed -E 's/(--dbcollate=)//')"
    if [ ! -z "${DBCOLLATE}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --dbprefix=*)
    DBPREFIX="$(echo "$arg" | sed -E 's/(--dbprefix=)//')"
    if [ ! -z "${DBPREFIX}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --dbname=*)
    DBNAME="$(echo "$arg" | sed -E 's/(--dbname=)//')"
    if [ ! -z "${DBNAME}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --dbuser=*)
    DBUSER="$(echo "$arg" | sed -E 's/(--dbuser=)//')"
    if [ ! -z "${DBUSER}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --dbpass=*)
    DBPASS="$(echo "$arg" | sed -E 's/(--dbpass=)//')"
    if [ ! -z "${DBPASS}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --url=*)
    URL="$(echo "$arg" | sed -E 's/(--url=)//')"
    ;;
  --title=*)
    TITLE="$(echo "$arg" | sed -E 's/(--title=)//')"
    ;;
  --admin-user=*)
    ADMIN_USER="$(echo "$arg" | sed -E 's/(--admin-user=)//')"
    ;;
  --admin-password=*)
    ADMIN_PASSWORD="$(echo "$arg" | sed -E 's/(--admin-password=)//')"
    ;;
  --admin-email=*)
    ADMIN_EMAIL="$(echo "$arg" | sed -E 's/(--admin-email=)//')"
    ;;
  esac
done

# This is the default setting.
if [ -z "${SERVER_NAME}" ]; then
  echo "ServerName is not defined."
  exit 0
fi

if [ -z "${SERVER_PORT}" ]; then
  SERVER_PORT="80 443"
fi

if [ ! -z "${FRAMEWORK}" ]; then
  case "${FRAMEWORK}" in
    la_wp | la_wordpress | laravel_wp | laravel_wordpress)
      if [ -z "${WP_DIR}" ]; then
        SUBDIRECTORY="blog"
      else
        SUBDIRECTORY="${WP_DIR}"
      fi
      ;;
  esac
fi

if [ -z "${DOCUMENT_ROOT}" ]; then
  DOCUMENT_ROOT="${HOME_DIR}/${SERVER_NAME}/html/${SUBDIRECTORY}"
fi

if [ -z "${NO_DATABASE}" ]; then
  NO_DATABASE="NO"
fi

if [ -z "${DBHOST}" ]; then
  DBHOST="localhost"
fi

if [ -z "${DBCHARSET}" ]; then
  DBCHARSET="$(getPkgCnf -f="/etc/my.cnf" -rs="\[mysqld\]" -fs="=" -s="character-set-server")"
fi

if [ -z "${DBCOLLATE}" ]; then
  DBCOLLATE="$(getPkgCnf -f="/etc/my.cnf" -rs="\[mysqld\]" -fs="=" -s="collation-server")"
fi

if [ -z "${DBPREFIX}" ]; then
  DBPREFIX="wp_"
fi

if [ -z "${DBNAME}" ]; then
  DBNAME="$(setDbName)"
fi

if [ -z "${DBUSER}" ]; then
  DBUSER="${DBNAME}"
fi

if [ -z "${DBPASS}" ]; then
  DBPASS="$(setDbPass)"
fi

if [ -z "${URL}" ]; then
  if [ ! -z "$(echo "${SERVER_PORT}" | egrep "^443$")" ]; then
    URL="https://${SERVER_NAME}"
  else
    URL="http://${SERVER_NAME}"
  fi
fi

if [ -z "${TITLE}" ]; then
  TITLE="Site Title"
fi

if [ -z "${ADMIN_USER}" ]; then
  ADMIN_USER="admin"
fi

if [ -z "${ADMIN_PASSWORD}" ]; then
  ADMIN_PASSWORD="$(setDbPass)"
fi

if [ -z "${ADMIN_EMAIL}" ]; then
  ADMIN_EMAIL="admin@${SERVER_NAME}"
fi

# Activate your virtual hosting site.
bash "${PKGPATH}/a2ensite.sh" "${@}"

# Check and correct the invalid string.
DOCUMENT_ROOT="$(echo "${DOCUMENT_ROOT}" | sed -E -e 's/\/+/\//g' -e 's/\/+$//g')"

# Create the required directory if it does not exist.
addDir "${DOCUMENT_ROOT}"

# Go to the document root directory.
cd "${DOCUMENT_ROOT}"

# Activate the database.
if [ "${NO_DATABASE^^}" == "NO" ]; then

  # Check and correct the invalid string.
  DBNAME="$(validDbName "${DBNAME}")"
  DBUSER="$(validDbUser "${DBUSER}")"
  DBPASS="$(validDbPass "${DBPASS}")"

  # Create a database and database username.
  bash "${DBPATH}/mariadb.sh" create --database="${DBNAME}" --username="${DBUSER}" --password="${DBPASS}"

fi

wp core download --allow-root
wp core config --allow-root --dbname="${DBNAME}" --dbuser="${DBUSER}" --dbpass="${DBPASS}" --dbhost="${DBHOST}" --dbcharset="${DBCHARSET}" --dbcollate="${DBCOLLATE}" --dbprefix="${DBPREFIX}"
wp core install --allow-root --url="${URL}" --title="${TITLE}" --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASSWORD}" --admin_email="${ADMIN_EMAIL}"

echo "url: ${URL}"
echo "title: ${TITLE}"
echo "admin_user: ${ADMIN_USER}"
echo "admin_password: ${ADMIN_PASSWORD}"
echo "admin_email: ${ADMIN_EMAIL}"

# Change directory permissions.
chown -R www-data:www-data "${DOCUMENT_ROOT}"
chmod -R 775 "${DOCUMENT_ROOT}"

# Reloading the service
systemctl reload apache2

# Initialize WordPress.
wp maintenance-mode activate --allow-root

wp theme delete --all --allow-root
wp plugin delete --all --allow-root

wp theme update --all --allow-root
wp plugin update --all --allow-root

wp maintenance-mode deactivate --allow-root

echo
echo "Wordpress is completely installed."
