## The Unix Module

The Unix module doesn't have very good documentation, so I'll expand on some of the functions I use here.

```ocaml
val recv :
  file_descr -> bytes -> int -> int -> msg_flag list -> int
```

Used for receiving data from a socket.

* file_descr: A file descriptor representing the socket
* bytes: A buffer to store the received data
* int: The starting offset in the buffer where data should be stored
* int: The maximum number of bytes to receive
* msg_flag list: A list of flags that modify the receive behavior

The function returns the actual number of bytes received, which may be less than the buffer capacity. If the peer closes the connection, it will return 0. It can raise `Unix_error` exceptions for various error conditions. Common flags include `MSG_PEEK` to look at data without removing it from the queue, and `MSG_OOB` for out-of-band data.

The function is blocking by default - it will wait until data is available. For non-blocking behavior, you need to set the socket to non-blocking mode using Unix.set_nonblock.

