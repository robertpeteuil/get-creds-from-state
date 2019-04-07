# Retrieve credentials from TFE state file for specified user

Parses a user / customer / partner credentials from the TFE state file & decodes them.  Works on Mac/Linux with both Keybase & gpg

## Use

- Download entire state file locally, copy to script dir and rename to `statedata`
- Defaults
  - looks for a file named `statedate`
    - use `-f` parameter to specify alternate file name
  - looks for credentials that match the logged in user's name
    - `-u` specifies user/customer/partner name
- Decoding with PGP keys - uses either 'keybase' or 'gpg'
  - Defaults to `keybase` if installed
  - `-g` forces use of `gpg`
  - `-k` forces use of `keybase`
- Other Options:
  - `-d` also display encypted data
  - `-n` don't decrypt data (includes `-d`)
