open Http

module type Controller = sig
  val handle_request : Http.http_method -> string
  val get : unit -> string
  val post : unit -> string
end

module MakeController (Base : sig
  val get : unit -> string
  val post : unit -> string
end) : Controller = struct
  let get = Base.get
  let post = Base.post
  let handle_request = function GET -> get () | POST -> post ()
end

module NotFound = MakeController (struct
  let get () = Response.json Http.Not_Found ""
  let post () = Response.json Http.Not_Found ""
end)
