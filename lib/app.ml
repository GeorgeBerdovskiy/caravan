open Unix

type t = { name : string; routes : Routes.t; port : int }

let initialize name routes port = { name; routes; port }

let addr_to_str = function
  | ADDR_UNIX s -> s
  | ADDR_INET (addr, port) ->
      Printf.sprintf "%s:%d" (Unix.string_of_inet_addr addr) port

let handle_client app (client_sock : file_descr) (client_addr : sockaddr) =
  (* Read the HTTP request into a string *)
  let request = Http.read_http_request client_sock in

  (* Extract the first line *)
  let first_line =
    match String.split_on_char '\r' request with line :: _ -> line | [] -> ""
  in

  (* Parse the first line *)
  let method_, path = Http.parse_request_line first_line in

  Printf.printf "[%s] %s %s\n" (addr_to_str client_addr) method_ path;
  flush Stdlib.stdout;

  (* Basic routing *)
  let mtd = Http.from_string_http_method method_ in
  let status, response_body = Routes.handle app.routes mtd path in

  let response = Http.build_http_response ~status response_body in

  (* Send response *)
  ignore
    (send client_sock (Bytes.of_string response) 0 (String.length response) []);

  shutdown client_sock SHUTDOWN_ALL;
  close client_sock

let run_server app =
  let port = app.port in
  (* Create a TCP socket *)
  let sock = socket PF_INET SOCK_STREAM 0 in

  (* Enable address reuse *)
  setsockopt sock SO_REUSEADDR true;

  (* Bind the socket to 0.0.0.0 and the provided port *)
  bind sock (ADDR_INET (inet_addr_any, port));

  (* Listen for connection requests on bound socket *)
  listen sock 10;

  (* Print helpful message *)
  Printf.printf "Server listening on port %d...\n" port;
  flush Stdlib.stdout;

  while true do
    (* Accept incoming connection requests *)
    let client_sock, client_addr = accept sock in
    handle_client app client_sock client_addr
  done

let run (app : t) = run_server app
