#! /bin/bash

# utility function to run command get log the time it took to run
# if CMD_LOGFILE is set, send output to that file
function time_command {
  local start_seconds=$SECONDS
  echo "RUNNING: $*"

  local error
  # pipe output to log file if set
  if [ "x$CMD_LOGFILE" == "x" ]; then
      "$@"
      error=$?
  else
      echo "Logging to ${CMD_LOGFILE}"
      "$@" >> $CMD_LOGFILE 2>&1
      error=$?
  fi

  local duration=$(( SECONDS - start_seconds ))
  echo "TIMING: Command took `printf '%02d' $(($duration / 60))`:`printf '%02d' $(($duration % 60))` (MM:SS): '$*'"
  if [ ${error} -ne 0 ]; then
    echo "ERROR: '$*' exited with status = ${error}"
    exit $error
  fi
  return $error
}

