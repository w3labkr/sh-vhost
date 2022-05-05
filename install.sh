#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-vhost
#
# Usage
# git clone https://github.com/w3src/sh-vhost.git
# cd sh-vhost
# chmod +x ./install.sh
# ./install.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit 0
fi

# Check if git is installed
if ! hash git 2>/dev/null; then
  echo -e "Git is not installed! You will need it at some point anyways..."
  echo -e "Exiting, install git first."
  exit 0
fi

# Recursive chmod to make all .sh files in the directory executable.
find ./ -type f -name "*.sh" -exec chmod +x {} +

#
# lsb_release command is only work for Ubuntu platform but not in centos 
# so you can get details from /etc/os-release file
# following command will give you the both OS name and version-
#
# https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
OS_NAME="$(cat /etc/os-release | awk -F '=' '/^NAME=/{print $2}' | awk '{print $1}' | tr -d '"')"

if [ "${OS_NAME}" == "Ubuntu" ]; then
  OS_ID="ubuntu"
  OS_VERSION_ID="$(cat /etc/os-release | awk -F '=' '/^VERSION_ID=/{print $2}' | awk '{print $1}' | tr -d '"')"
  OS_VERSION_NUMBER="${OS_VERSION_ID//./}"
  if [ "${OS_VERSION_NUMBER}" -lt "1804" ]; then
    echo "Sorry. Amp Vhost is not supported on Ubuntu versions below 18.04."
    exit 0
  else
    OS_VERSION_ID="18.04"
  fi
elif [ "${OS_NAME}" == "CentOS" ]; then
  echo "Sorry. Amp Vhost is not supported on CentOS."
  exit 0
else
  echo "Sorry. Amp Vhost is not supported on ${OS_NAME}."
  exit 0
fi

echo
echo "Start installing Amp Vhost installaion."

# Set the arguments.
FILENAME="$(basename $0)"
PACKAGES=()
PARAMS=()
if [ "${#@}" -gt "0" ]; then
  for arg in "${@}"; do
    case $arg in
    -*)
      PARAMS+=("$arg")
      ;;
    *)
      PACKAGES+=("$arg")
      ;;
    esac
  done
else
  PACKAGES=('vhost')
fi

# Run the script.
for ((i = 0; i < ${#PACKAGES[@]}; i++)); do
  FILEPATH="${OS_ID}/${OS_VERSION_ID}/${PACKAGES[$i]}/${FILENAME}"
  if [ -f "${FILEPATH}" ]; then
    bash "${FILEPATH}" "${PARAMS[@]}"
  else
    echo "There is no ${PACKAGES[$i]} ${FILENAME%%.*} file."
  fi
done

echo
echo "Amp Vhost is completely installed."

# Include the file.
source "copyright.sh"
