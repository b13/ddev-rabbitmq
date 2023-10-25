#!/bin/bash

setup() {
  bats_require_minimum_version 1.5.0
}

@test "Send request from 'web' to the api and see how it is going there" {
  result="$(ddev exec "curl -u rabbitmq:rabbitmq --fail -H 'Content-Type: application/json' -X GET http://rabbitmq:15672/api/health/checks/alarms")"
  [ "$result" == "{\"status\":\"ok\"}" ]
}

@test "Apply configuration defined in config.rabbitmq.yaml" {
  ddev rabbitmq apply
}

@test "See expected users" {
  result=$(ddev rabbitmqctl list_users --silent --formatter json)
  expected='[ {"user":"rabbitmq","tags":["administrator"]},{"user":"ddev-admin","tags":["administrator,management"]} ]'

  [ "$(echo "$result" | jq -c -S '.' 2>/dev/null)" == "$(echo "$expected" | jq -c -S '.' 2>/dev/null)" ]
}

@test "See expected vhosts" {
  result=$(ddev rabbitmqctl list_vhosts --silent --formatter json)
  expected='[ {"name":"/"},{"name":"ddev-vhost"} ]'

  [ "$(echo "$result" | jq -c -S '.' 2>/dev/null)" == "$(echo "$expected" | jq -c -S '.' 2>/dev/null)" ]
}

@test "See expected permissions for users in vhost=ddev-vhost" {
  result=$(ddev rabbitmqctl list_permissions --silent --formatter json --vhost=ddev-vhost)
  expected='[ {"user":"rabbitmq","configure":".*","write":".*","read":".*"} ,{"user":"ddev-admin","configure":".*","write":".*","read":".*"} ]'

  [ "$(echo "$result" | jq -c -S '.' 2>/dev/null)" == "$(echo "$expected" | jq -c -S '.' 2>/dev/null)" ]
}

@test "Delete/wipe custom configuration" {
  ddev rabbitmq wipe
}

@test "See only rabbitmq default user" {
  result=$(ddev rabbitmqctl list_users --silent --formatter json)
  expected='[ {"user":"rabbitmq","tags":["administrator"]} ]'

  [ "$(echo "$result" | jq -c -S '.' 2>/dev/null)" == "$(echo "$expected" | jq -c -S '.' 2>/dev/null)" ]
}

@test "See only '/' vhost exists" {
  result=$(ddev rabbitmqctl list_vhosts --silent --formatter json)
  expected='[ {"name":"/"} ]'

  [ "$(echo "$result" | jq -c -S '.' 2>/dev/null)" == "$(echo "$expected" | jq -c -S '.' 2>/dev/null)" ]
}

@test "See error message when trying to list permissions for non-existing vhost" {
  run -1 ddev rabbitmqctl list_permissions --silent --formatter json --vhost=ddev-vhost
  expected="Virtual host 'ddev-vhost' does not"

  [[ $output == *$expected* ]]
}

@test "Remove addon - see files removed" {
  ddev get --remove rabbitmq

  expected_files_not_to_exist=(docker-compose.rabbitmq.yaml commands/rabbitmq/rabbitmq commands/rabbitmq/rabbitmqadmin commands/rabbitmq/rabbitmqctl config.rabbitmq.yaml rabbitmq-schema.json)
  for file in "${expected_files_not_to_exist[@]}"; do
    [ ! -f "$TESTDIR/.ddev/$file" ]
  done
}
