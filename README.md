# A Nyxt formula for Homebrew

**Status: this works for some configurations but fails to build on Apple Silicon in Monterey. Could use some help from experienced LISPers in troubleshooting. See https://github.com/incidentist/homebrew-nyxt/issues/6.**

## How do I install these formulae?

`brew install incidentist/nyxt/<formula>`

Or `brew tap incidentist/nyxt` and then `brew install <formula>`.

To install Nyxt, you must first install webkitgtk using the formula that is also in this repo:
`brew install incidentist/nyxt/webkitgtk`
(This could take over an hour.)

Then you can install Nyxt:
`brew install incidentist/nyxt/nyxt`

Nyxt is installed in the homebrew tree because it is not a cask yet. To run it:

`/usr/local/Cellar/nyxt/2.2.4/bin/Nyxt.app/Contents/MacOS/nyxt`

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

## Troubleshooting

* If installation throws an error about "loading libcrypto in an unsafe way" on an M1 Mac: you may have an old x86 homebrew installation with openssl installed. Try running `/usr/local/bin/brew uninstall openssl`.