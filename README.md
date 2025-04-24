[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/ddev/ddev-rabbitmq/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/ddev/ddev-rabbitmq/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/ddev/ddev-rabbitmq)](https://github.com/ddev/ddev-rabbitmq/commits)
[![release](https://img.shields.io/github/v/release/ddev/ddev-rabbitmq)](https://github.com/ddev/ddev-rabbitmq/releases/latest)

# DDEV RabbitMQ

## Overview

[RabbitMQ](https://www.rabbitmq.com/) is a message-queueing software also known as a message broker or queue manager.

This add-on integrates RabbitMQ into your [DDEV](https://ddev.com/) project and creates users/queues according to the configuration defined in [`.ddev/rabbitmq/config.yaml`](rabbitmq/config.yaml).

## Installation

```bash
ddev add-on get ddev/ddev-rabbitmq
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Configuration

From within the container, the RabbitMQ container is reached at hostname: `rabbitmq` on port `5672`, so
the server URL will be `amqp://rabbitmq:5672`.

For more details check the connection section below.

### YAML configuration

The [rabbitmq/config.yaml](rabbitmq/config.yaml) describes
vhosts, queues, users and plugins.

The configuration can be applied with the following command:

```bash
ddev rabbitmq apply
```

> [!NOTE]
> This may not cover all possible configuration values! But it is a good start.

To ensure the configuration is applied automatically on boot, add the following
hook to your `.ddev/config.yaml`:

```yaml
hooks:
  post-start:
    - exec-host: ddev solrctl apply
```

Remove rabbitmq configuration but keep default user (`rabbitmq`) and vhost (`/`):

```bash
ddev rabbitmq wipe
```

## Usage

| Command                     | Description                                                                    |
|-----------------------------|--------------------------------------------------------------------------------|
| `ddev rabbitmq --help`      | RabbitMQ custom helper command                                                 |
| `ddev rabbitmqadmin --help` | RabbitMQ Management CLI (no auth required)                                     |
| `ddev rabbitmqctl --help`   | Used to manage the cluster and nodes                                           |
| `ddev rabbitmq launch`      | Launch RabbitMQ Management UI in the browser (credentials `rabbitmq:rabbitmq`) |
| `ddev describe`             | View service status and used ports for RabbitMQ                                |
| `ddev logs -s rabbitmq`     | Check RabbitMQ logs                                                            |

ℹ️`rabbitmqadmin` and `rabbitmqctl` share some functions. Both are needed for full configuration.

## Connection

RabbitMQ is accessible from the host machine itself as well as between the containers on the same network, and comes
with a nice management UI for ease of use.

### Management UI

The management UI can be accessed through `https://<DDEV_SITENAME>.ddev.site:15673` (`ddev launch :15673`) on the host machine.

Management UI credentials

* Username: `rabbitmq`
* Password: `rabbitmq`

For more information about the HTTP API see the [official documentation](https://www.rabbitmq.com/docs).

### AMQP protocol access

You can access the RabbitMQ service through its AMQP protocol inside any DDEV container via `amqp://rabbitmq:5672`

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.rabbitmq --rabbitmq-docker-image="rabbitmq:4-management-alpine"
ddev add-on get ddev/ddev-rabbitmq
ddev restart
```

Make sure to commit the `.ddev/.env.rabbitmq` file to version control.

## Examples

* [TYPO3](USAGE.md)

## Credits

**Originally Contributed by [@Graloth](https://github.com/Graloth) in [ddev-contrib](https://github.com/ddev/ddev-contrib/tree/master/docker-compose-services/rabbitmq)**

**Maintained by [@b13](https://github.com/b13)**
