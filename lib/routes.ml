open Control

type t = (string, (module Controller)) Hashtbl.t

let initialize : t = Hashtbl.create 50

let register routes path controller =
  Hashtbl.add routes path controller;
  routes

let handle (routes : t) mtd path =
  let (module C) = try Hashtbl.find routes path with _ -> (module NotFound) in
  C.handle_request mtd
