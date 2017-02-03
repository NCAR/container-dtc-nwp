#!/bin/ksh

################################################################################
#
# Script Name: run_command.ksh
#
#      Author: John Halley Gotway
#              NCAR/RAL/DTC
#
#    Released: 10/10/2012
#
# Description:
#   This is a wrapper script for executing the command that is passed to it
#   and checking the return status.
#
# Arguments:
#   The first argument is the command to be executed and all remaining arguments
#   are passed through to the command.
#
################################################################################

# Name of this script
SCRIPT=run_command.ksh

# Check for at least one argument
if [ $# -eq 0 ]; then
  echo
  echo "ERROR: ${SCRIPT} zero arguments."
  echo
  exit 1
fi

# Run the command
echo
echo "CALLING: $*"
echo
$*

# Check the return status
error=$?
if [ ${error} -ne 0 ]; then
  echo "ERROR:"
  echo "ERROR: $* exited with status = ${error}"
  echo "ERROR:"
  exit ${error}
fi

