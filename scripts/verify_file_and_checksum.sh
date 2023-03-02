#!/usr/bin/env dash

#set -x
if [ -f "$1" ]; then
    echo "$2 *$1" | /usr/bin/core_perl/shasum --check --status

    if [ $? -eq 0 ]; then
        exit 0
    else
        echo "ERROR: checksum mismatch for file $1"
        exit 1
    fi

else
    echo "ERROR: missing file $1"
    exit 1
fi

# vim:set ts=4 sts=4 sw=4 et:
