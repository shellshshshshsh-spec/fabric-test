#!/bin/sh
# Keep the Workspace verification entry point backed by versioned code.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
exec sh "$repo_dir/verify.sh"
