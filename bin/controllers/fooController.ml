open Server

module FooController = Control.MakeController (struct
  let get () = (Http.OK, "Hello from FooController!")
  let post () = (Http.Created, "Post from FooController!")
end)
