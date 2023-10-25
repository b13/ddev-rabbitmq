# RabbitMQ

This enables a RabbitMQ service container that can be used by other containers on the same network and the host 
machine itself.

## Installation

```
ddev get ochorocho/ddev-rabbitmq && ddev restart
```

## Configuration

From within the container, the RabbitMQ container is reached at hostname: `ddev-<projectname>-rabbitmq`, port: 5672, so
the server URL might be `amqp://ddev-<projectname>-rabbitmq:5672`.

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

__Important:__ If you need to run multiple ddev sites that use this RabbitMQ service, you will have to alter the ports 
per site in the [docker-compose.rabbitmq.yaml](docker-compose.rabbitmq.yaml).

### Management UI

The management UI can be accessed through `http://<DDEV_SITENAME>.ddev.site:15672` on the host machine. 
Username "rabbitmq", password "rabbitmq".

For more information about the HTTP API see the [official documentation](https://rawcdn.githack.com/rabbitmq/rabbitmq-server/v3.12.6/deps/rabbitmq_management/priv/www/api/index.html)

### AMQP protocol access

You can access the RabbitMQ service through it's AMQP protocol two ways:

* From the host machine: `amqp://<DDEV_SITENAME>.ddev.site:5672`
* From docker containers on the same docker network (ddev_default): `amqp://ddev-<projectname>-rabbitmq:5672`

**Originally Contributed by [@Graloth](https://github.com/Graloth) in [ddev-contrib](https://github.com/ddev/ddev-contrib/tree/master/docker-compose-services/rabbitmq)**

**Maintained by [@ochorocho](https://github.com/ochorocho)**
