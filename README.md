# Retrieve credentials from TFE state file for specified user

Parses a user / customer / partner credentials from the TFE state file & decodes them

- Works on Mac/Linux with either keybase & gpg
- Works for general credentials and binary distribution credentials

## Install

Express install via `iac.sh` or `https://iac.sh` (my bootstrap server)

``` bash
curl iac.sh/getcreds | sh   # run without '| sh' to view & verify script
```

Manual Download

``` bash
curl -sL https://raw.github.com/robertpeteuil/get-creds-from-state/master/getcreds.sh > getcreds.sh
chmod +x getcreds.sh
```

## Use

- Download state file locally, copy to script dir and rename to `statedata` (or similar)
- Run script with `./getcreds.sh`
- Defaults
  - reads state data from file named `statedata`
    - `-f` specifies alternate file
  - finds credentials that match current user's name
    - `-u` specifies alternate name
- Decoding with PGP keys - auto uses either `keybase` or `gpg`
  - Defaults to `keybase` if both installed
  - `-g` forces use of `gpg` if both installed
- Other Options:
  - `-d` display encrypted data
  - `-n` no decryption of data (includes `-d`)

## To Test

- `gpg` outputs the text below to stderr which is filtered out
  - `gpg: encrypted with 4096-bit RSA key, ID 23B2A5AB229679FA, created 2018-07-11`
- Need to determine if `keybase` output contains similar entranious text
  - if present, need to add filter to remove it
