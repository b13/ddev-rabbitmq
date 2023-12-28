# RabbitMQ

This enables a RabbitMQ service container that can be used by other containers on the same network and the host 
machine itself.

## Installation

```
ddev get b13/ddev-rabbitmq && ddev restart
```

## Configuration

From within the container, the RabbitMQ container is reached at hostname: `rabbitmq` on port 5672, so
the server URL will be `amqp://rabbitmq:5672`.

For more details check the connection section below.

### YAML configuration

The [config.rabbitmq.yaml](config.rabbitmq.yaml) describes
vhosts, queues, users, and plugins.

The configuration can be applied with the following command:

```bash
ddev rabbitmq apply
```

:warning: This may not cover all possible configuration values! But it is a good start.

Remove rabbitmq configuration but keep default user (`rabbitmq`) and vhost (`/`):

```bash
ddev rabbitmq wipe
```

### Commands

Everything possible in Management UI can be done using `rabbitmqadmin`.
User and password are set 

```
ddev rabbitmqadmin --help
```

`rabbitmqctl` is used to manage the cluster and nodes

```
ddev rabbitmqctl --help
```

ℹ️`rabbitmqadmin` and `rabbitmqctl` share a some functions. Both are needed for full configuration.

## Connection

RabbitMQ is accessible from the host machine itself as well as between the containers on the same network, and comes 
with a nice management UI for ease of use.

### Management UI

The management UI can be accessed through `https://<DDEV_SITENAME>.ddev.site:15673` on the host machine. 
Username: "rabbitmq", password: "rabbitmq". This is also shown in `ddev describe`.

For more information about the HTTP API see the [official documentation](https://rawcdn.githack.com/rabbitmq/rabbitmq-server/v3.12.6/deps/rabbitmq_management/priv/www/api/index.html)

### AMQP protocol access

You can access the RabbitMQ service through its AMQP protocol inside any DDEV container via `amqp://rabbitmq:5672`

## Examples:

* [TYPO3](USAGE.md)


**Originally Contributed by [@Graloth](https://github.com/Graloth) in [ddev-contrib](https://github.com/ddev/ddev-contrib/tree/master/docker-compose-services/rabbitmq)**

**Maintained by [@b13](https://github.com/b13)**
