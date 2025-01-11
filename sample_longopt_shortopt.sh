#!/bin/bash

# Define the script usage
usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h, --help           Show this help message"
  echo "  -v, --version        Display the script version"
  echo "  -n, --name NAME      Specify a name"
  exit 1
}

# Define script version
VERSION="1.0.0"

# Parse options using getopt
TEMP=$(getopt -o hvn: --long help,version,name: -n "$0" -- "$@")
if [[ $? -ne 0 ]]; then
  usage
fi

# Rearrange positional parameters to parsed options
eval set -- "$TEMP"

# Process options
while true; do
  case "$1" in
    -h|--help)
      usage
      ;;
    -v|--version)
      echo "Version: $VERSION"
      exit 0
      ;;
    -n|--name)
      NAME="$2"
      echo "Name specified: $NAME"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: $1"
      usage
      ;;
  esac
done

# Remaining arguments
if [[ $# -gt 0 ]]; then
  echo "Additional arguments: $@"
fi
