open Server

module FooController = Control.MakeController (struct
  let get () = Response.json Http.OK "{ \"hello\": \"world\" }"
  let post () = Response.json Http.Created "{ \"hello\": \"world\" }"
end)
