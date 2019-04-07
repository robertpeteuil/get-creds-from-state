# Retrieve credentials from TFE state file for specified user

Parses a user / customer / partner credentials from the TFE state file & decodes them

- Works on Mac/Linux with either keybase & gpg
- Works for general credentials and binary distribution credentials

## Use

- Download entire state file locally, copy to script dir and rename to `statedata`
- Defaults
  - looks for a file named `statedate`
    - use `-f` parameter to specify alternate file name
  - looks for credentials that match the logged in user's name
    - `-u` specifies user/customer/partner name
- Decoding with PGP keys - uses either `keybase` or `gpg`
  - Defaults to `keybase` if installed
  - `-g` forces use of `gpg`
  - `-k` forces use of `keybase`
- Other Options:
  - `-d` also display encypted data
  - `-n` don't decrypt data (includes `-d`)

## TODO

- Test output for values decrypted with `keybase` and remove entranious text if necessary
- `gpg` sends the following text to stderr for each decryption, which is filtered out
  - gpg: encrypted with 4096-bit RSA key, ID 54D0A5FD449203BD, created 2014-01-27
  - "Robert Peteuil <robert@peteuil.com>"
