#!/usr/bin/env bash

set -ef -o pipefail

function print_help_and_exit() {
  [ "$1" ] && echo "$1"
  [ "$1" ] && echo ""
  echo "Run admin tasks on a Postgres database. Uses existing environment variables (\$PGUSER, PGPASSWORD, PGDATABASE, PGHOST, PGPORT) to connect to Postgres."
  echo ""
  echo " $0 -p <task name - one of vacuum, vacuumanalyse or analyse> -t <table name (optional)> -v <run command with verbose option switched on, default is off>"
  echo ""
  exit 1
}

function check_arguments () {
  [ "${TASK}" ] || print_help_and_exit "Please specify the -p parameter. It needs to be one of vacuum, vacuumanalyse or analyse."
  [ ${TASK} == "vacuum" ] || [ ${TASK} == "vacuumanalyse" ] || [ ${TASK} == "analyse" ] || print_help_and_exit "Please specify the -p parameter as one of vacuum, vacuumanalyse or analyse."
}

function run_task () {
  case ${TASK} in
    vacuum)
      COMMAND="VACUUM"
      ;;
    vacuumanalyse)
      COMMAND="VACUUM ANALYZE"
      ;;
    analyse)
      COMMAND="ANALYZE"
      ;;
  esac

  if [[ ${VERBOSE} ]]
  then
    COMMAND=${COMMAND}" VERBOSE"
  fi

  if [[ ${TABLE} ]]
  then
    COMMAND=${COMMAND}" "${TABLE}
  fi

  echo $(date -u) "    Starting "${COMMAND}"..."

  /usr/bin/psql -U ${PGUSER} -d ${PGDATABASE} -h ${PGHOST} -p ${PGPORT} << ENDSQL
${COMMAND};
ENDSQL

  echo $(date -u) "    Finished running "${TASK}
}

while getopts "p:vt:h" arg; do
  case $arg in
    h)
      print_help_and_exit
      ;;
    p)
      TASK="${OPTARG}"
      ;;
    t)
      TABLE="${OPTARG}"
      ;;
    v)
      VERBOSE="1"
      ;;
  esac
done

check_arguments

run_task
