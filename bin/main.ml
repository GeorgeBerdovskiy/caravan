open Server

module FooController : Control.Controller = struct
  include Control.DefaultController

  let get () = Printf.printf "Handling GET...\n"
end

let () = 
  let app =
    let routes = Routes.initialize in
    let routes = Routes.register routes "foo" (module FooController) in
    App.initialize "interact-api" routes 8000 in
  App.run app
