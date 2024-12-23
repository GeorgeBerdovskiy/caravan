open Control

type t = (string, (module Controller)) Hashtbl.t

let initialize: t = Hashtbl.create 50

let register routes path controller =
  Hashtbl.add routes path controller;
  routes