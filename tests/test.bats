#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  bats_require_minimum_version 1.5.0

  # Override this variable for your add-on:
  export GITHUB_REPO=ddev/ddev-rabbitmq

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  echo "Send request from 'web' to the api and see how it is going there" >&3
  run ddev exec "curl -s -u rabbitmq:rabbitmq --fail -H 'Content-Type: application/json' -X GET http://rabbitmq:15672/api/health/checks/alarms"
  assert_success
  assert_output '{"status":"ok"}'

  echo "Apply configuration rabbitmq/config.yaml (default)" >&3
  run ddev rabbitmq apply
  assert_success
  refute_output --partial "plugins_not_found"

  echo "Apply configuration tests/testdata/config.test.yaml (multiple plugins enabled)" >&3
  cp "${DIR}/tests/testdata/config.test.yaml" "${TESTDIR}/.ddev/rabbitmq/config.yaml"
  assert_file_exist .ddev/rabbitmq/config.yaml
  run ddev rabbitmq apply
  assert_success
  refute_output --partial "plugins_not_found"

  echo "See expected users" >&3
  run ddev rabbitmqctl list_users --silent --formatter json
  assert_success
  assert_output --partial '{"user":"rabbitmq","tags":["administrator"]}'
  assert_output --partial '{"user":"ddev-admin","tags":["administrator,management"]}'

  echo "See expected vhosts" >&3
  run ddev rabbitmqctl list_vhosts --silent --formatter json
  assert_success
  assert_output --partial '{"name":"/"}'
  assert_output --partial '{"name":"ddev-vhost"}'

  echo "See expected permissions for users in vhost=ddev-vhost" >&3
  run ddev rabbitmqctl list_permissions --silent --formatter json --vhost=ddev-vhost
  assert_success
  assert_output --partial '{"user":"ddev-admin","configure":".*","write":".*","read":".*"}'
  assert_output --partial '{"user":"rabbitmq","configure":".*","write":".*","read":".*"}'

  echo "Delete/wipe custom configuration" >&3
  run ddev rabbitmq wipe
  assert_success

  echo "See only rabbitmq default user" >&3
  run ddev rabbitmqctl list_users --silent --formatter json
  assert_success
  assert_output --partial '{"user":"rabbitmq","tags":["administrator"]}'
  refute_output --partial '{"user":"ddev-admin","tags":["administrator,management"]}'

  echo "See only '/' vhost exists" >&3
  run ddev rabbitmqctl list_vhosts --silent --formatter json
  assert_success
  assert_output --partial '{"name":"/"}'
  refute_output --partial '{"name":"ddev-vhost"}'

  echo "See error message when trying to list permissions for non-existing vhost" >&3
  run -1 ddev rabbitmqctl list_permissions --silent --formatter json --vhost=ddev-vhost
  assert_failure
  assert_output --partial "Virtual host 'ddev-vhost' does not"

  echo "See php amqp module loaded" >&3
  run ddev exec "php -m | grep amqp"
  assert_success
  assert_output "amqp"

  echo "See php pcntl module loaded on cli" >&3
  run ddev exec "php -m | grep pcntl"
  assert_success
  assert_output "pcntl"

  echo "Remove addon - see files removed" >&3
  expected_files_not_to_exist=(docker-compose.rabbitmq.yaml commands/rabbitmq/rabbitmq commands/rabbitmq/rabbitmqadmin commands/rabbitmq/rabbitmqctl rabbitmq/config.yaml rabbitmq/schema.json)
  for file in "${expected_files_not_to_exist[@]}"; do
    assert_file_exist "$TESTDIR/.ddev/$file"
  done
  run ddev add-on remove rabbitmq
  assert_success
  expected_files_not_to_exist=(docker-compose.rabbitmq.yaml commands/rabbitmq/rabbitmq commands/rabbitmq/rabbitmqadmin commands/rabbitmq/rabbitmqctl rabbitmq/config.yaml rabbitmq/schema.json)
  for file in "${expected_files_not_to_exist[@]}"; do
    assert_file_not_exist "$TESTDIR/.ddev/$file"
  done
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
