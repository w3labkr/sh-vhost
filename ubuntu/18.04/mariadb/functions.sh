#
# Database
# https://unix.stackexchange.com/questions/428158/drop-user-if-exists-syntax-error-in-mysql-cli
#
# Via command line
#mysql -uroot -e "SHOW DATABASES;"
#mysql -uroot -e "SELECT User FROM mysql.user;"

# Set the database name.
#setDbName
#setDbName --prefix="user_"
#setDbName --suffix="_db"
#setDbName --no-prefix --no-suffix
#setDbName --dbname=<full-dbname>
function setDbName() {

  # Set constants.
  local PREFIX="$(whoami)_"
  local SUFFIX="_db"
  local DBNAME=""
  local USERNAME=""

  # Set the arguments.
  for arg in "${@}"; do
    case $arg in
    --prefix=*)
      PREFIX="$(echo "$arg" | sed -E 's/(--prefix=)//')"
      ;;
    --no-prefix)
      PREFIX=""
      ;;
    --suffix=*)
      SUFFIX="$(echo "$arg" | sed -E 's/(--suffix=)//')"
      ;;
    --no-suffix)
      SUFFIX=""
      ;;
    --dbname)
      DBNAME="$(echo "$arg" | sed -E 's/(--dbname=)//')"
      ;;
    esac
  done

  # This is the default setting.
  local MAXIMUM="16"
  local RANDLENG="$((${MAXIMUM} - ${#PREFIX} - ${#SUFFIX}))"

  if [ -z "${DBNAME}" ]; then
    DBNAME="${PREFIX}$(openssl rand -base64 ${RANDLENG})${SUFFIX}"
  fi

  USERNAME="${DBNAME}"

  # Check and correct the invalid string.
  DBNAME="$(validDbName "${DBNAME}")"
  USERNAME="$(validDbUser "${USERNAME}")"

  # Detect if database name and username exists.
  if [ ! -z "$(isDbName "${DBNAME}")" ]; then
    setDbName "${@}"
  elif [ ! -z "$(isDbUser "${USERNAME}")" ]; then
    setDbName "${@}"
  fi

  # Print the information.
  echo "${DBNAME}"

}

# Set the database username.
#setDbUser
#setDbUser --prefix="user_"
#setDbUser --suffix="_db"
#setDbUser --no-prefix --no-suffix
#setDbUser --username=<full-username>
function setDbUser() {

  # Set constants.
  local PREFIX="$(whoami)_"
  local SUFFIX="_db"
  local USERNAME=""
  local DBNAME=""

  # Set the arguments.
  for arg in "${@}"; do
    case $arg in
    --prefix=*)
      PREFIX="$(echo "$arg" | sed -E 's/(--prefix=)//')"
      ;;
    --no-prefix)
      PREFIX=""
      ;;
    --suffix=*)
      SUFFIX="$(echo "$arg" | sed -E 's/(--suffix=)//')"
      ;;
    --no-suffix)
      SUFFIX=""
      ;;
    --username)
      USERNAME="$(echo "$arg" | sed -E 's/(--username=)//')"
      ;;
    esac
  done

  # This is the default setting.
  local MAXIMUM="16"
  local RANDLENG="$((${MAXIMUM} - ${#PREFIX} - ${#SUFFIX}))"

  if [ -z "${USERNAME}" ]; then
    USERNAME="${PREFIX}$(openssl rand -base64 ${RANDLENG})${SUFFIX}"
  fi

  DBNAME="${USERNAME}"

  # Check and correct the invalid string.
  USERNAME="$(validDbUser "${USERNAME}")"
  DBNAME="$(validDbName "${DBNAME}")"

  # Detect if database name and username exists.
  if [ ! -z "$(isDbUser "${USERNAME}")" ]; then
    setDbUser "${@}"
  elif [ ! -z "$(isDbName "${DBNAME}")" ]; then
    setDbUser "${@}"
  fi

  # Print the information.
  echo "${USERNAME}"

}

# Set the database password.
function setDbPass() {

  # Set constants.
  local PASSWORD="$(openssl rand -base64 12)"

  # Check and correct the invalid string.
  PASSWORD="$(validDbPass "${PASSWORD}")"

  # Print the information.
  echo "${PASSWORD}"

}

# Detect if database name exists.
function isDbName() {
  mysql -uroot -e 'SHOW DATABASES;' | egrep "^$1$"
}

# Detect if database username exists.
function isDbUser() {
  mysql -uroot -e 'SELECT User FROM mysql.user;' | egrep "^$1$"
}

# Check and correct the invalid string.
function validDbName() {

  # Set constants.
  local DATABASE="$1"

  # Check and correct the invalid string.
  DATABASE="${DATABASE//[^a-zA-Z0-9_]/}"
  DATABASE="${DATABASE:0:16}"

  # Print the information.
  echo "${DATABASE}"

}

# Check and correct the invalid string.
function validDbUser() {

  # Set constants.
  local USERNAME="$1"

  # Check and correct the invalid string.
  USERNAME="${USERNAME//[^a-zA-Z0-9_]/}"
  USERNAME="${USERNAME:0:16}"

  # Print the information.
  echo "${USERNAME}"

}

# Check and correct the invalid string.
function validDbPass() {

  # Set constants.
  local PASSWORD="$1"

  # Check and correct the invalid string.
  PASSWORD="${PASSWORD:0:16}"

  # Print the information.
  echo "${PASSWORD}"

}
