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
# Decoding with PGP keys - uses either 'keybase' or 'gpg'
#   Defaults to 'keybase' if installed
#   '-g' param forces use of 'gpg'
#   '-k' param forces use of 'keybase'

scriptname=$(basename "$0")
scriptbuildnum="1.0.1"
scriptbuilddate="2019-04-06"

displayVer() {
  echo -e "${scriptname}  ver ${scriptbuildnum} - ${scriptbuilddate}"
}

usage() {
  [[ "$1" ]] && echo -e "Retrieve credentials from TFE state file for specified user\n"
  echo -e "usage: ${scriptname} [-u USER] [-f FILE] [-k] [-g] [-h] [-v]"
  echo -e "     -u USER\t: specify user/customer/partner name (default = current user)"
  echo -e "     -f FILE\t: filename for downloaded TFE state file (default = 'statedata')"
  echo -e "     -k\t\t: force use of keybase to decrypt data"
  echo -e "     -g\t\t: force use of gpg to decrypt data"
  echo -e "     -n\t\t: don't decrypt data (includes -d)"
  echo -e "     -d\t\t: display encrypted data"
  echo -e "     -h\t\t: help"
  echo -e "     -v\t\t: display ${scriptname} version"
}

while getopts ":u:f:kgdnhv" arg; do
  case "${arg}" in
    u)  SPECUSER=${OPTARG};;
    f)  SPECFILE=${OPTARG};;
    k)  decrypttool="keybase";;
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

if [[ -z "$decrypttool" ]]; then
  if keybase -h 2&> /dev/null; then
    decrypttool="keybase"
  elif gpg -h 2&> /dev/null; then
    decrypttool="gpg"
  else
    echo "Error - neither keybase or gpg is installed"
    exit 1
  fi
fi

if [ "$OS" == "Darwin" ]; then
  # check for coreutils base64 - it uses linux syntax
  if base64 --version 2&> /dev/null; then
    b64arg="-d"
  else
    b64arg="-D"
  fi
else
  b64arg="-d"
fi

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

# PARSE VALUES FROM STATE DATA
substring="${USERNAME}-accesskey"
acckey=$(jq -r --arg sstring "$substring" '.modules[0].outputs | .[$sstring] | .value' $RAWFILE)

substring="${USERNAME}-password"
enc_pass=$(jq -r --arg sstring "$substring" '.modules[0].outputs | .[$sstring] | .value' $RAWFILE)

substring="${USERNAME}-secretkey"
enc_secret=$(jq -r --arg sstring "$substring" '.modules[0].outputs | .[$sstring] | .value' $RAWFILE)

# DISPLAY AND DECODE DATA
echo -e "Datafile name:\t ${RAWFILE}"
echo -e "Username:\t ${USERNAME}"

echo -e "Access Key:\t ${acckey}"

# DECRYPT unless in no-decrypt mode
if [[ ! "$nodecrypt" ]]; then
  if [[ "$enc_pass" != "null" ]]; then
    pass=$(decode "$enc_pass")
    echo -e "Password:\t ${pass}"
  fi

  secret=$(decode "$enc_secret")
  echo -e "Secret Key:\t ${secret}"
fi

# display encrypted data
if [[ "$displayall" ]]; then
  echo -e "\nEncrypted Password"
  echo "$enc_pass"
  echo -e "\nEncrypted Secret Key"
  echo "$enc_secret"
fi
