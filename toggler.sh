#!/usr/bin/env bash
set -euo pipefail

MOUSE_SIZE_TOGGLER_SOURCE="https://gist.githubusercontent.com/EthanSK/bc2c92ad613c9d7a71c36053ecaec12c/raw/936b545556addcd1b8043f9675c16d372e1dce45/main.swift"
MOUSE_SIZE_TOGGLER_FILE="$HOME/.config/macos-pointer-size-toggler/mouse_toggler"

usage() {
  cat <<-USAGE
$(basename "$0") [OPTIONS]
Adjust the size of your cursor.

OPTIONS

  -n                    A specific cursor size; must be between 1 and 4; floating point accepted.
  -h, --help            Shows this help page.
  -s, --small           Makes the cursor small. Same as -n=1.
  -m, --medium          Makes the cursor medium. Same as -n=2.5.
  -l, --large           Makes the cursor large. Same as -n=4.
      --huge            Same as --large.

NOTES

- The System Settings window needs to be visible in the deskop that
  you're in in order for this to work. If you get an error, make sure that
  your terminal is not in fullscreen mode or macOS wasn't able to get to the Pointer Size pref pane.

  Run the command again; it should work!

- Any System Settings windows that are open will be closed after running this.
USAGE
}

get_size() {
  local size
  size=$(bc -l <<< "$1")
  size_int="${size//.*/}"
  { test "$size_int" -le 0 || test "$size_int" -gt 4; } && return 1
  echo "$size"
}

install_xcode_if_swift_not_found() {
  which swiftc &>/dev/null && return 0

  >&2 echo "INFO: The Swift compiler is not installed on your system; installing it now"
  xcode-select --install
}

download_and_compile_toggler_if_needed() {
  _download_mouse_toggler_source() {
    local dir
    dir=$(dirname "$MOUSE_SIZE_TOGGLER_FILE")
    test -d "$dir" || mkdir -p "$dir"

    curl -Lo "${dir}/main.swift" "$MOUSE_SIZE_TOGGLER_SOURCE"
  }

  _compile_mouse_toggler() {
    local dir
    dir=$(dirname "$MOUSE_SIZE_TOGGLER_FILE")
    swiftc -o "$MOUSE_SIZE_TOGGLER_FILE" "${dir}/main.swift"
  }

  test -f "$MOUSE_SIZE_TOGGLER_FILE" && return 0
  >&2 echo "INFO: EthanC's Mouse Size Toggler not found; compiling it now..."
  _download_mouse_toggler_source &&
    _compile_mouse_toggler
}

run_toggler() {
  local result_file
  local attempts=1
  >&2 echo "INFO: Adjusting mouse size now."
  >&2 echo
  result_file="$(mktemp /tmp/toggler-result-XXXX)"
  while test "$attempts" -le 5
  do
    "$MOUSE_SIZE_TOGGLER_FILE" "$1" 2>&1 | tee "$result_file"
    pgrep -qi 'system settings' && pkill -i 'system settings'
    grep -q "slider not found" "$result_file" || return 0

    >&2 echo "ERROR: Failed to adjust size; trying again in 0.5 secs."
    sleep 0.5
    attempts=$((attempts+1))
  done
  >&2 echo "ERROR: Failed to adjust size after five attempts."
  return 1
}

if grep -Eq '^(-h|--help)$' <<< "$@"
then
  usage
  exit 0
fi

if test "$#" -gt 2
then
  usage
  >&2 echo "ERROR: Too many arguments provided"
  exit 1
fi

case "$1" in
  -s|--small)
    size_str=1
    ;;
  -m|--medium)
    size_str=2.5
    ;;
  -l|--large)
    size_str=4
    ;;
  --huge)
    size_str=4
    ;;
  -n)
    if test "$#" -ne 2
    then
      usage
      >&2 echo "ERROR: Expected 2 arguments; got $#."
    fi
    size_str="$2"
    ;;
esac

if ! size=$(get_size "$size_str")
then
  usage
  >&2 echo "ERROR: Invalid size provided: $1"
  exit 1
fi

install_xcode_if_swift_not_found
download_and_compile_toggler_if_needed
run_toggler "$size"
