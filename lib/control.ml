open Http

module type Controller = sig
  val handle_request: Http.http_method -> unit

  val get: unit -> unit

  val post: unit -> unit
end

module DefaultController : Controller = struct
  let get () = ()

  let post () = ()

  let handle_request = function
  | GET -> get ()
  | POST -> post ()
end
