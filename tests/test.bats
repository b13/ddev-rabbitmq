#!/bin/bash

setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-rabbitmq-addon
  mkdir -p $TESTDIR
  export PROJNAME=test-addon-rabbitmq
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

health_checks() {
  result="$(ddev exec "curl -u rabbitmq:rabbitmq --fail -H 'Content-Type: application/json' -X GET http://rabbitmq:15672/api/health/checks/alarms")"
  [ "$result" == "{\"status\":\"ok\"}" ]
}

apply_config() {
  ddev rabbitmq apply
  result=$(ddev rabbitmqctl list_users --silent --formatter json)
  expected='[ {"user":"rabbitmq","tags":["administrator"]},{"user":"ddev-admin","tags":["administrator,management"]} ]'

  [ "$(echo "$result" | jq -c -S '.' 2>/dev/null)" == "$(echo "$expected" | jq -c -S '.' 2>/dev/null)" ]
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  health_checks
  apply_config
}

#@test "install from release" {
#  set -eu -o pipefail
#  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#  echo "# ddev get ochorocho/ddev-rabbitmq with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
#  ddev get ddev/ddev-addon-template
#  ddev restart >/dev/null
#  health_checks
#}
#
