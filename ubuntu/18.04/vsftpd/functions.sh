function username_exists() {
  if [ -z "$(cut -d: -f1 /etc/passwd | egrep "^$1$")" ]; then
    echo "The user '$1' does not exist."
    exists_username=""
    while [ -z "${exists_username}" ]; do
      read -p "username: " exists_username
      if [ -z "$(cut -d: -f1 /etc/passwd | egrep "^${exists_username}$")" ]; then
        echo "The user '${exists_username}' does not exist."
        exists_username=""
      fi
    done
  else
    exists_username="$1"
  fi
}

function username_create() {
  if cut -d: -f1 /etc/passwd | egrep -q "^$1$"; then
    echo "The user '$1' already exists."
    create_username=""
    while [ -z "${create_username}" ]; do
      read -p "username: " create_username
      if [ ! -z "$(cut -d: -f1 /etc/passwd | egrep "^${create_username}$")" ]; then
        echo "The user '${create_username}' already exists."
        create_username=""
      fi
    done
  else
    create_username="$1"
  fi
}

# Set up an ftp user.
# Prefix is ​​required.
# There is no prefix when accessing by root.
# If not accessed as root, the default prefix is ​​the Unix username.

# <unix-username>_<infix>_<ftp-username>_<suffix>
# fcm2qKBx

# setUser --username= --len=16

function setUser() {

  # Set constants.
  local USERNAME=""
  local len=""

  # Set the arguments.
  for arg in "${@}"; do
    case $arg in
    --username=*)
      USERNAME="$(echo "$arg" | sed -E 's/(--username=)//')"
      ;;
    --len=* | --length=*)
      len="$(echo "$arg" | sed -E 's/(--len=|--length=)//')"
      ;;
    esac
  done

  # This is the default setting.
  if [ -z "$len" ]; then
    len="$(randomNumeric --len=2 --min=8 --max=16)"
  fi

  if [ -z "${USERNAME}" ]; then
    USERNAME="$(randomAlphaNumeric --len=$len)"
  fi

  # Check and correct the invalid string.
  USERNAME="$(validUser "${USERNAME}")"

  # Detect if database name and username exists.
  if [ ! -z "$(isUser "${USERNAME}")" ]; then
    ISUSER=""
    while [ -z "${ISUSER}" ]; do
      ISUSER="$(isUser "${USERNAME}")"

      ISUSER=""
    done
  fi


  # Print the information.
  echo "${USERNAME}"


  if [ ! -z "$(isUser "$1")" ]; then
    echo "The user '$1' already exists."
    NEW_USERNAME=""
    while [ -z "${NEW_USERNAME}" ]; do
      read -p "USERNAME: " NEW_USERNAME
      if [ ! -z "$(isUser "${NEW_USERNAME}")" ]; then
        echo "The user '${NEW_USERNAME}' already exists."
        NEW_USERNAME=""
      fi
    done
  else
    NEW_USERNAME="$1"
  fi
}

function isUser() {
  cut -d: -f1 /etc/passwd | egrep "^$1$"
}

function validUser() {

  # Set constants.
  local USERNAME="$1"

  # Check and correct the invalid string.
  USERNAME="${USERNAME//[^a-zA-Z0-9_]/}"
  USERNAME="${USERNAME:0:16}"

  # Print the information.
  echo "${USERNAME}"

}


