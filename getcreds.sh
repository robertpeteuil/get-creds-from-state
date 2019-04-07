#!/usr/bin/env bash

set -e

# Retrieve credentials from TFE state file for specified user
#   Download entire state file locally and move to script dir
#   Default
#     looks for a file named 'statedate'
#       use '-f' parameter to specify alternate file name
#     looks for credentials that match the logged in user's name
#       '-u' parameter specify user/customer/partner name
#
# Decoding with PGP keys - auto uses either 'keybase' or 'gpg'
#   Defaults to 'keybase' if both installed
#   '-g' param forces use of 'gpg' if both installed

scriptname=$(basename "$0")
scriptbuildnum="1.1.1"
scriptbuilddate="2019-04-07"

displayVer() {
  echo -e "${scriptname}  ver ${scriptbuildnum} - ${scriptbuilddate}"
}

usage() {
  [[ "$1" ]] && echo -e "Retrieve credentials from TFE state file for specified user\n"
  echo -e "usage: ${scriptname} [-u USER] [-f FILE] [-g] [-n] [-d] [-h] [-v]"
  echo -e "     -u USER\t: specify user/customer/partner name (default = current user)"
  echo -e "     -f FILE\t: filename for downloaded TFE state file (default = 'statedata')"
  echo -e "     -g\t\t: force use of gpg to decrypt data"
  echo -e "     -n\t\t: no decryption of data (includes -d)"
  echo -e "     -d\t\t: display un-encrypted data"
  echo -e "     -h\t\t: help"
  echo -e "     -v\t\t: display ${scriptname} version"
}

while getopts ":u:f:gdnhv" arg; do
  case "${arg}" in
    u)  SPECUSER=${OPTARG};;
    f)  SPECFILE=${OPTARG};;
    g)  decrypttool="gpg";;
    d)  displayall=true;;
    n)  displayall=true; nodecrypt=true;;
    h)  usage x; exit;;
    v)  displayVer; exit;;
    \?) echo -e "Error - Invalid option: $OPTARG"; usage; exit;;
    :)  echo "Error - $OPTARG requires an argument"; usage; exit 1;;
  esac
done
shift $((OPTIND-1))

OS=$(uname)
USERNAME="${SPECUSER:-$USER}"
RAWFILE="${SPECFILE:-statedata}"

decode() {
  case "${decrypttool}" in
    keybase)
      result=$(echo "$1" | base64 "$b64arg" | keybase pgp decrypt)
      ;;
    gpg)
      result=$(echo "$1" | base64 "$b64arg" | gpg --decrypt 2>/dev/null)
      ;;
  esac
  echo -n "$result"
}

parsedata() {
  readdata=$(jq -r --arg sstring "$1" '.modules[0].outputs | .[$sstring] | .value' $RAWFILE)
  echo -n "$readdata"
}

# PARSE VALUES FROM STATE DATA
acckey=$(parsedata "${USERNAME}-accesskey")
enc_pass=$(parsedata "${USERNAME}-password")
enc_secret=$(parsedata "${USERNAME}-secretkey")

# DISPLAY DATA
echo -e "Datafile name:\t ${RAWFILE}"
echo -e "Username:\t ${USERNAME}"
echo -e "Access Key:\t ${acckey}"

# DECRYPT AND DISPLAY (unless in no-decrypt mode)
if [[ ! "$nodecrypt" ]]; then

  # set decryption tool
  if [[ -z "$decrypttool" ]]; then
    if keybase -h 2&> /dev/null; then
      decrypttool="keybase"
    elif gpg -h 2&> /dev/null; then
      decrypttool="gpg"
    else
      echo "Cannot decrypt - neither keybase nor gpg installed"
      exit 1
    fi
  fi

  # set base64 arg format
  if [ "$OS" == "Darwin" ]; then
    # check for coreutils base64 - uses linux syntax
    if base64 --version 2&> /dev/null; then
      b64arg="-d"
    else
      b64arg="-D"
    fi
  else
    b64arg="-d"
  fi

  if [[ "$enc_pass" != "null" ]]; then
    pass=$(decode "$enc_pass")
    echo -e "Password:\t ${pass}"
  fi

  secret=$(decode "$enc_secret")
  echo -e "Secret Key:\t ${secret}"
fi

# DISPLAY ENCRYPTED DATA (if enabled)
if [[ "$displayall" ]]; then
  echo -e "\nEncrypted Password"
  echo "$enc_pass"
  echo -e "\nEncrypted Secret Key"
  echo "$enc_secret"
fi
