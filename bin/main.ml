open Server
open Controllers

let () =
  let app =
    let routes = Routes.initialize in
    let routes =
      Routes.register routes "/foo" (module FooController.FooController)
    in
    App.initialize "interact-api" routes 8000
  in
  App.run app
