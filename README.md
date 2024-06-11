# MacOS Mouse Size Toggler

> ⚠️  Requires **macOS Ventura** or later.

Wrapper around [this]() Gist that automates changing your cursor size.

Useful for demos, courses, workshops, or anything else that is simplified by
having a big cursor.

## How to Install

Run the script below to download and install the Mouse Size Toggler to your Mac.

Requires `sudo`.

   ```sh
   set -eo pipefail
   VERSION="main" # Change this to a tag or commit SHA to retrieve a specific version
   curl -Lo /tmp/pointer_size.sh \
    "https://raw.githubusercontent.com/carlosonunez/macos-mouse-size-toggler/$VERSION/toggler.sh"
   chmod +x /tmp/pointer_size.sh
   sudo mv /tmp/pointer_size.sh /usr/local/bin/pointer_size
   ```

## How To Use

```sh
$: pointer_size --help

Usage: pointer_size [NUMBER]
Adjusts the size of your cursor.

ARGUMENTS

    [NUMBER]            The size of the cursor. Must be between 1 and 4.
                        Decimals/floating point values supported.
```
