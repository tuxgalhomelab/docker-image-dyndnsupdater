#!/usr/bin/env bash
set -E -e -o pipefail

set_umask() {
    # Configure umask to allow write permissions for the group by default
    # in addition to the owner.
    umask 0002
}

start_dyndnsupdater() {
    echo "Starting dyndnsupdater ..."
    echo

    exec dyndnsupdater "$@"
}

set_umask
start_dyndnsupdater "$@"
