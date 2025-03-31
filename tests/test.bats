#!/bin/bash

setup() {
  bats_require_minimum_version 1.5.0
}

@test "Send request from 'web' to the api and see how it is going there" {
  run ddev exec "curl -s -u rabbitmq:rabbitmq --fail -H 'Content-Type: application/json' -X GET http://rabbitmq:15672/api/health/checks/alarms"

  [ "$output" == '{"status":"ok"}' ]
}

@test "Apply configuration rabbitmq/config.yaml (default)" {
  run ddev rabbitmq apply

  [[ "$output" != *'plugins_not_found'* ]]
  [ "$status" -eq 0 ]
}

@test "Apply configuration tests/config.test.yaml (multiple plugins enabled)" {
  cp "${DIR}/config.test.yaml" "${TESTDIR}/.ddev/rabbitmq/config.yaml"

  run ddev rabbitmq apply

  [[ "$output" != *'plugins_not_found'* ]]
  [ "$status" -eq 0 ]
}

@test "See expected users" {
  run ddev rabbitmqctl list_users --silent --formatter json

  [[ "$output" == *'{"user":"rabbitmq","tags":["administrator"]}'* ]]
  [[ "$output" == *'{"user":"ddev-admin","tags":["administrator,management"]}'* ]]
}

@test "See expected vhosts" {
  run ddev rabbitmqctl list_vhosts --silent --formatter json

  [[ "$output" == *'{"name":"/"}'* ]]
  [[ "$output" == *'{"name":"ddev-vhost"}'* ]]
}

@test "See expected permissions for users in vhost=ddev-vhost" {
  run ddev rabbitmqctl list_permissions --silent --formatter json --vhost=ddev-vhost

  [[ "$output" == *'{"user":"ddev-admin","configure":".*","write":".*","read":".*"}'* ]]
  [[ "$output" == *'{"user":"rabbitmq","configure":".*","write":".*","read":".*"}'* ]]
}

@test "Delete/wipe custom configuration" {
  run ddev rabbitmq wipe

  [ "$status" -eq 0 ]
}

@test "See only rabbitmq default user" {
  run ddev rabbitmqctl list_users --silent --formatter json

  [[ "$output" == *'{"user":"rabbitmq","tags":["administrator"]}'* ]]
  [[ "$output" != *'{"user":"ddev-admin","tags":["administrator,management"]}'* ]]
}

@test "See only '/' vhost exists" {
  run ddev rabbitmqctl list_vhosts --silent --formatter json

  [[ "$output" == *'{"name":"/"}'* ]]
  [[ "$output" != *'{"name":"ddev-vhost"}'* ]]
}

@test "See error message when trying to list permissions for non-existing vhost" {
  run -1 ddev rabbitmqctl list_permissions --silent --formatter json --vhost=ddev-vhost

  [[ $output == *"Virtual host 'ddev-vhost' does not"* ]]
}

@test "See php amqp module loaded" {
  run ddev exec "php -m | grep amqp"

  [[ $output == "amqp" ]]
}

@test "See php pcntl module loaded on cli" {
  run ddev exec "php -m | grep pcntl"

  [[ $output == "pcntl" ]]
}

@test "Remove addon - see files removed" {
  ddev get --remove rabbitmq

  expected_files_not_to_exist=(docker-compose.rabbitmq.yaml commands/rabbitmq/rabbitmq commands/rabbitmq/rabbitmqadmin commands/rabbitmq/rabbitmqctl rabbitmq/config.yaml rabbitmq/schema.json)
  for file in "${expected_files_not_to_exist[@]}"; do
    [ ! -f "$TESTDIR/.ddev/$file" ]
  done
}
