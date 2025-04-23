# RabbitMQ

This DDEV add-on provides a RabbitMQ service and creates users/queues
according to the configuration defined in `.ddev/rabbitmq/config.yaml`.

## Installation

For DDEV v1.23.5 or above run

```bash
ddev add-on get ddev/ddev-rabbitmq && ddev restart
```

For earlier versions of DDEV run

```bash
ddev get ddev/ddev-rabbitmq && ddev restart
```

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

```bash
hooks:
  post-start:
    - exec-host: ddev solrctl apply
```

Remove rabbitmq configuration but keep default user (`rabbitmq`) and vhost (`/`):

```bash
ddev rabbitmq wipe
```

### Commands

You can configure everything available in the RabbitMQ Management UI using `ddev rabbitmqadmin`.
Authentication is pre-configured, so there's no need to specify a username or password.

```bash
ddev rabbitmqadmin --help
```

`ddev rabbitmqctl` is used to manage the cluster and nodes

```bash
ddev rabbitmqctl --help
```

ℹ️`rabbitmqadmin` and `rabbitmqctl` share some functions. Both are needed for full configuration.

## Connection

RabbitMQ is accessible from the host machine itself as well as between the containers on the same network, and comes 
with a nice management UI for ease of use.

### Management UI

The management UI can be accessed through `https://<DDEV_SITENAME>.ddev.site:15673` on the host machine. 

Management UI credentials

* Username: `rabbitmq`
* Password: `rabbitmq`

For more information about the HTTP API see the [official documentation](https://www.rabbitmq.com/docs)

### AMQP protocol access

You can access the RabbitMQ service through its AMQP protocol inside any DDEV container via `amqp://rabbitmq:5672`

## Examples:

* [TYPO3](USAGE.md)


**Originally Contributed by [@Graloth](https://github.com/Graloth) in [ddev-contrib](https://github.com/ddev/ddev-contrib/tree/master/docker-compose-services/rabbitmq)**

**Maintained by [@b13](https://github.com/b13)**
