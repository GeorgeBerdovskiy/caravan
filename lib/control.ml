open Http

module type Controller = sig
  val handle_request : Http.http_method -> Http.status * string
  val get : unit -> Http.status * string
  val post : unit -> Http.status * string
end

module MakeController (Base : sig
  val get : unit -> Http.status * string
  val post : unit -> Http.status * string
end) : Controller = struct
  let get = Base.get
  let post = Base.post
  let handle_request = function GET -> get () | POST -> post ()
end

module NotFound = MakeController (struct
  let get () = (Http.Not_Found, "Oops! This page doesn't exist.")
  let post () = (Http.Not_Found, "Oops! this page doesn't exist.")
end)
