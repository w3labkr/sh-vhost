#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./ubuntu/18.04/vhost/install.sh
# ./ubuntu/18.04/vhost/install.sh

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
echo "Start installing ${PKGNAME}."

# If you do not want to activate the site during installation.
# --no-a2ensite

# You can also use parameters to change a2ensite template settings.
# --server-name=<domain>
# --server-alias="<alias.domain> <alias.domain> <alias.domain>" 
# --server-admin=webmaster@<domain>
# --document-root=<absolute-path>
# --directory=<absolute-path>
# --error-log=<absolute-path>
# --access-log=<absolute-path>

# You can also enable specific ports with parameters.
# Not supported except ports 80 and 443.
# --server-port="80 443"

# If you want to install in a subdirectory.
# --subdirectory=blog
# or
# --subdirectory=blog --no-a2ensite

# If you are installing the framework without a database.
# --no-db
# --no-database

# If you did not enter the db parameter, create a random string.
# None or Laravel framework
# --db-database=dbname
# --db-username=dbuser
# --db-password=dbpass

# Framework
# --framework=none
# --framework=laravel
# --framework=wordpress
# --framework=laravel_wordpress

# None
#./install.sh --server-name=domain.com
#./install.sh --server-name=domain.com --server-alias=www.domain.com
#./install.sh --server-name=domain.com --no-database
#./install.sh --server-name=domain.com --db-database=dbname --db-username=dbuser --db-password=dbpass

# Laravel
# You can use la instead of laravel.
#./install.sh --framework=laravel --server-name=domain.com
#./install.sh --framework=laravel --server-name=domain.com --server-alias=www.domain.com

# Generate basic scaffolding.
#./install.sh --framework=laravel --server-name=domain.com --bootstrap
#./install.sh --framework=laravel --server-name=domain.com --vue
#./install.sh --framework=laravel --server-name=domain.com --react

# Generate login / registration scaffolding.
#./install.sh --framework=laravel --server-name=domain.com --bootstrap --auth
#./install.sh --framework=laravel --server-name=domain.com --vue --auth
#./install.sh --framework=laravel --server-name=domain.com --react --auth

# Wordpress
# You can use wp instead of wordpress.
#./install.sh --framework=wordpress --server-name=domain.com
#./install.sh --framework=wordpress --server-name=domain.com --server-alias=www.domain.com
#./install.sh --framework=wordpress --server-name=domain.com --dbname=DbName --dbuser=DbUser --dbpass=DbPass
#./install.sh --framework=wordpress --server-name=domain.com --title=SiteTitle --admin_user=AdminUser --admin_password=AdminPassword --admin_email=AdminEmail

# Laravel and Wordpress Integration
# Wordpress is installed in a subdirectory.
# Connect db using [corcel](https://github.com/corcel/corcel) libray.
#./install.sh --framework=laravel_wordpress --server-name=domain.com --wp-dir=blog
#./install.sh --framework=laravel_wordpress --server-name=domain.com --wp-dir=blog --server-alias=www.domain.com
#./install.sh --framework=laravel_wordpress --server-name=domain.com --wp-dir=blog --dbname=DbName --dbuser=DbUser --dbpass=DbPass

# Set the arguments.
for arg in "${@}"; do
  case $arg in
  --framework=*)
    FRAMEWORK="$(echo "$arg" | sed -E 's/(--framework=)//')"
    ;;
  esac
done

# Run the script.
case "${FRAMEWORK}" in
none)
  bash "${LIBPATH}/none/install.sh" --no-database "${@}"
  ;;
la | laravel)
  bash "${LIBPATH}/laravel/install.sh" "${@}"
  ;;
wp | wordpress)
  bash "${LIBPATH}/wordpress/install.sh" "${@}"
  ;;
la_wp | la_wordpress | laravel_wp | laravel_wordpress)
  bash "${LIBPATH}/laravel/install.sh" --no-database "${@}"
  bash "${LIBPATH}/wordpress/install.sh" --no-a2ensite "${@}"
  ;;
*)
  bash "${LIBPATH}/none/install.sh" --no-database "${@}"
  ;;
esac

echo
echo "${PKGNAME^} is completely installed."
