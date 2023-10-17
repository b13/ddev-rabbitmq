# RabbitMQ

This enables a RabbitMQ service container that can be used by other containers on the same network and the host 
machine itself.

## Installation

```
ddev get ochorocho/ddev-rabbitmq && ddev restart
```

The [rabbitmq-build](rabbitmq-build) directory contains the enabled plugins, these are required for having a functioning 
RabbitMQ service, as the container would otherwise stop itself shortly after starting. The plugins themselves are what 
enables the management UI and the graphs within it.

## Configuration

From within the container, the RabbitMQ container is reached at hostname: `ddev-<projectname>-rabbitmq`, port: 5672, so
the server URL might be `amqp://ddev-<projectname>-rabbitmq:5672`.

For more details check the connection section below.

## Connection

RabbitMQ is accessible from the host machine itself as well as between the containers on the same network, and comes 
with a nice management UI for ease of use.

__Important:__ If you need to run multiple ddev sites that use this RabbitMQ service, you will have to alter the ports 
per site in the [docker-compose.rabbitmq.yaml](docker-compose.rabbitmq.yaml).

### Management UI

The management UI can be accessed through `http://<DDEV_SITENAME>.ddev.site:15672` on the host machine. 
Username "rabbitmq", password "rabbitmq".

### Use the API to manage rabbitmq

Within the ddev web container it is easy to utilize the HTTP API to
create a custom queue, get stats and so on.

Create a queue called "ddev"

```
curl -u rabbitmq:rabbitmq -H "Content-Type: application/json" -X PUT http://rabbitmq:15672/api/queues/%2F/ddev --data-raw '{"auto_delete": false,"durable": true,"arguments": {}}'
```

Create the message "DDEV is awesome" in the "ddev" queue

```
curl -u rabbitmq:rabbitmq -H "Content-Type: application/json" -X POST -d '{"properties":{},"routing_key":"ddev","payload_encoding": "string", "payload":"DDEV is awesome"}' http://rabbitmq:15672/api/exchanges/%2f/amq.default/publish
```

For more information about the HTTP API see the [official documentation](https://rawcdn.githack.com/rabbitmq/rabbitmq-server/v3.12.6/deps/rabbitmq_management/priv/www/api/index.html)

### AMQP protocol access

You can access the RabbitMQ service through it's AMQP protocol two ways:

* From the host machine: `amqp://<DDEV_SITENAME>.ddev.site:5672`
* From docker containers on the same docker network (ddev_default): `amqp://ddev-<projectname>-rabbitmq:5672`

**Originally Contributed by [@Graloth](https://github.com/Graloth) in [ddev-contrib](https://github.com/ddev/ddev-contrib/tree/master/docker-compose-services/rabbitmq)**

**Maintained by [@ochorocho](https://github.com/ochorocho)**
