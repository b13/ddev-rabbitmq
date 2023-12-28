# TYPO3 and RabbitMQ 

This is just a simple example on how RabbitMQ can be used
along with TYPO3.

Install required package:

```bash
ddev composer req symfony/amqp-messenger
```

Create a message with all information needed later on in the handler:

```php
final class MyMessage
{
    public function __construct(
        public readonly array $content
    ) {
    }
}
```

Process a message:

```php
final class MyHandler
{
    public function __construct(private readonly MessageBusInterface $bus)
    {
    }

    public function __invoke(MyMessage $message): void
    {
        try {
            // #### Do magic stuff with $message->content ####
        } catch (\Exception $exception) {
            // Workaround to support infinite retryable messages. So no message gets lost.
            $envelope = new Envelope(new MyMessage($message->content), [new DelayStamp(5000)]);
            $this->bus->dispatch($envelope);
        }
    }
}
```

Register 'amqp' in ext_localconf.php

```php
// Unset the default, so that it no longer applies
unset($GLOBALS['TYPO3_CONF_VARS']['SYS']['messenger']['routing']['*']);
// Set Webhook-Messages and MyMessage to asynchronous transport via amqp
foreach ([WebhookMessageInterface::class, MyMessage::class] as $className) {
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['messenger']['routing'][$className] = 'amqp';
}
```

Dispatch a message:

```php
class RunTheRabbit implements MiddlewareInterface
{
    public function __construct(private readonly MessageBusInterface $bus)
    {
    }

    public function process(
        ServerRequestInterface $request,
        RequestHandlerInterface $handler
    ): ResponseInterface {
        $value = ['some' => 'value'];
        $this->bus->dispatch(new MyMessage($value));
        
        return $handler->handle($request);
    }
}
```

Start the worker to consume messages:

```bash
ddev typo3 messenger:consume -vv amqp
```
