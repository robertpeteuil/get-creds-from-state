# Retrieve credentials from TFE state file for specified user

Parses a user / customer / partner credentials from the TFE state file & decodes them

- Works on Mac/Linux with either keybase & gpg
- Works for general credentials and binary distribution credentials

## Install

Clone of download script:

``` bash
curl -sL https://raw.github.com/robertpeteuil/get-creds-from-state/master/getcreds.sh > getcreds.sh
chmod +x getcreds.sh
```

## Use

- Download state file locally, copy to script dir and rename to `statedata` (or similar)
- Run script with `./getcreds.sh`
- Defaults
  - reads state data from file named `statedate`
    - `-f` specifies alternate file
  - finds credentials that match current user's name
    - `-u` specifies alternate name
- Decoding with PGP keys - auto uses either `keybase` or `gpg`
  - Defaults to `keybase` if both installed
  - `-g` forces use of `gpg` if both installed
- Other Options:
  - `-d` display un-encypted data
  - `-n` no decryption of data (includes `-d`)

## TODO

- Test output for values decrypted with `keybase` and remove entranious text if necessary
- `gpg` sends the following text to stderr for each decryption, which is filtered out
  - gpg: encrypted with 4096-bit RSA key, ID 54D0A5FD449203BD, created 2014-01-27
