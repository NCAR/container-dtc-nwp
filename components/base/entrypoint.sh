#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9999}

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -g 9999 -o -c "" -m user

exec /usr/local/bin/gosu user "$@"
