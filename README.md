# Caravan
Web application framework written from scratch using OCaml.

## About Caravan

> I hear and I forget. I see and I remember. I do and I understand.
> 
> _- Confucius_

I've been _using_ web frameworks to build APIs and user-facing web applications for years, but my understanding of their inner workings is hazy at best.

How does my Express API handle hundreds of requests per second? How does my Ruby on Rails application make routing decisions? These are questions that I can only answer vaguely. Interrogate me beyond shallow concepts and I'm lost.

That's why I decided to build my own web application framework. I've barely started, and I've _already_ had to think about...

* Networking (how to interact with the sockets API)
* Routing (how to expose a high-level routing API for end users)
* Concurrency (how to use multiprocessing and multithreading to serve several clients at once)

... and I'm sure the list will grow as time goes on.

## Why OCaml?

Whenever possible, I try to do as many things at once as possible. Why would I learn about web application frameworks _alone_ when I can also learn OCaml at the same time? Plus, I thought it would be nice to write some functional code for a change (right now, most of my work is in Ruby or Rust).
