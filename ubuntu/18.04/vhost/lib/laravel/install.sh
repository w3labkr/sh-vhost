#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/laravel/install.sh
# ./ubuntu/18.04/laravel/install.sh

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

# Make sure the package is installed.
pkgAudit "apache2"

echo
echo "Start installing ${PKGNAME}."

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
  --server-name=*)
    SERVER_NAME="$(echo "$arg" | sed -E 's/(--server-name=)//')"
    ;;
  --document-root=*)
    DOCUMENT_ROOT="$(echo "$arg" | sed -E 's/(--document-root=)//')"
    ;;
  --subdirectory=*)
    SUBDIRECTORY="$(echo "$arg" | sed -E 's/(--subdirectory=)//')"
    ;;
  --bootstrap)
    SCAFFOLDING="${arg#--}"
    ;;
  --vue)
    SCAFFOLDING="${arg#--}"
    ;;
  --react)
    SCAFFOLDING="${arg#--}"
    ;;
  --auth)
    AUTHENTICATION="$arg"
    ;;
  --no-db | --no-database)
    NO_DATABASE="YES"
    ;;
  --db-connection=*)
    DB_CONNECTION="$(echo "$arg" | sed -E 's/(--db-connection=)//')"
    if [ ! -z "${DB_CONNECTION}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --db-host=*)
    DB_HOST="$(echo "$arg" | sed -E 's/(--db-host=)//')"
    if [ ! -z "${DB_HOST}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --db-port=*)
    DB_PORT="$(echo "$arg" | sed -E 's/(--db-port=)//')"
    if [ ! -z "${DB_PORT}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --db-database=*)
    DB_DATABASE="$(echo "$arg" | sed -E 's/(--db-database=)//')"
    if [ ! -z "${DB_DATABASE}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --db-username=*)
    DB_USERNAME="$(echo "$arg" | sed -E 's/(--db-username=)//')"
    if [ ! -z "${DB_USERNAME}" ]; then
      NO_DATABASE="NO"
    fi
    ;;
  --db-password=*)
    DB_PASSWORD="$(echo "$arg" | sed -E 's/(--db-password=)//')"
    if [ ! -z "${DB_PASSWORD}" ]; then
      NO_DATABASE="NO"
    fi
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
  DOCUMENT_ROOT="${HOME_DIR}/${SERVER_NAME}/html/${SUBDIRECTORY}"
fi

if [ -z "${SCAFFOLDING}" ]; then
  SCAFFOLDING=""
fi

if [ -z "${AUTHENTICATION}" ]; then
  AUTHENTICATION=""
fi

if [ -z "${NO_DATABASE}" ]; then
  NO_DATABASE="NO"
fi

if [ -z "${DB_CONNECTION}" ]; then
  DB_CONNECTION="mysql"
fi

if [ -z "${DB_HOST}" ]; then
  DB_HOST="localhost"
fi

if [ -z "${DB_PORT}" ]; then
  DB_PORT="3306"
fi

if [ -z "${DB_DATABASE}" ]; then
  DB_DATABASE="$(setDbName)"
fi

if [ -z "${DB_USERNAME}" ]; then
  DB_USERNAME="${DB_DATABASE}"
fi

if [ -z "${DB_PASSWORD}" ]; then
  DB_PASSWORD="$(setDbPass)"
fi

# Activate a virtual hosting site.
bash "${PKGPATH}/a2ensite.sh" "${@}"

# Check and correct the invalid string.
DOCUMENT_ROOT="$(echo "${DOCUMENT_ROOT}" | sed -E -e 's/\/+/\//g' -e 's/\/+$//g')"

# Create the required directory if it does not exist.
addDir "${DOCUMENT_ROOT}"

# Go to the document root directory.
cd "${DOCUMENT_ROOT}"

# Installing Laravel
laravel new .

# JavaScript & CSS Scaffolding
if [ ! -z "${SCAFFOLDING}" ] && [ ! -z "${AUTHENTICATION}" ]; then
  php artisan ui "${SCAFFOLDING}" "${AUTHENTICATION}"
elif [ ! -z "${SCAFFOLDING}" ]; then
  php artisan ui "${SCAFFOLDING}"
fi

# Writing CSS & JavaScript
npm install && npm run dev

# Activate the database.
if [ "${NO_DATABASE^^}" == "YES" ]; then

  # Block database information.
  sed -i -E \
    -e "/DB_(.*)=/{ s/^/#/; s/^#+/#/; }" \
    "${DOCUMENT_ROOT}/.env"

else

  # Check and correct the invalid string.
  DB_DATABASE="$(validDbName "${DB_DATABASE}")"
  DB_USERNAME="$(validDbUser "${DB_USERNAME}")"
  DB_PASSWORD="$(validDbPass "${DB_PASSWORD}")"

  # Create a database and database username.
  bash "${DBPATH}/mariadb.sh" create --database="${DB_DATABASE}" --username="${DB_USERNAME}" --password="${DB_PASSWORD}"

  # Set up the package environment.
  setPkgCnf -f="${DOCUMENT_ROOT}/.env" -fs="=" -o="<<HERE
DB_CONNECTION=${DB_CONNECTION}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
<<HERE"

fi

# Install corcel library for laravel and wordpress integration.
if [ ! -z "${FRAMEWORK}" ]; then
  case "${FRAMEWORK}" in
  la_wp | la_wordpress | laravel_wp | laravel_wordpress)
    composer require jgrossi/corcel
    ;;
  esac
fi

# Change directory permissions to share between group members.
chown -R www-data:www-data "${DOCUMENT_ROOT}"
chmod -R 775 "${DOCUMENT_ROOT}"

# Start the laravel server.
php artisan serve &
echo

# Reloading the service
systemctl reload apache2

echo
echo "${PKGNAME^} is completely installed."
