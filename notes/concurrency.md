So far, we've built a simple but working web server. It can receive and route requests without too much boilerplate written by the programmer.

However, we do have one pretty big problem: we can only handle _one_ request at a time. Yikes.

See for yourself! Before shutting down a connection, sleep for ten seconds. To make it even more obvious, set off a ten second countdown. Before the countdown goes to zero, try to send another request to the server. You will find that the browser will load until the countdown finishes, and only _then_ will you get a response.

In general, there are a few things to think about when implementing concurrency for a web server:

* How many _workers_ or _processes_ you have
* How many _threads_ per worker you have
* How many _seconds_ it takes to handle a request

Beyond that, it's a question of how many instances of your application are available, but that's handled by your load balancer so no need to think about that right now.

Rails applications use Puma. A "worker" is a "process" and typically, you will have one worker (process) per core. By default, each worker will have five threads. So by default, my Rails app will have ten workers, each of which runs five threads.

Suppose every request takes, on average, 100ms (or 0.1 seconds).My Apple M1 Pro has ten cores. This means, on average, my app can handle...

10 * 5 * 10 = 500 requests per second.

That's already not bad! Keep in mind that basically all web applications have a cache layer that will make the duration much faster. If you have 10 application servers running at once, that increases to...

10 * 500 = 5000 requests per second over all your instances.

> This is a good time to remember that threads and processes are NOT the same thing!
> 