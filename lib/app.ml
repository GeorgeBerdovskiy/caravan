open Unix

type t = { name : string; routes : Routes.t; port : int }

let initialize name routes port = { name; routes; port }

let countdown_from n =
  let rec count n =
    if n > 0 then (
      print_int n;
      print_newline ();
      Unix.sleep 1;
      count (n - 1))
    else print_endline "Time's up!"
  in
  count n

let addr_to_str = function
  | ADDR_UNIX s -> s
  | ADDR_INET (addr, port) ->
      Printf.sprintf "%s:%d" (Unix.string_of_inet_addr addr) port

let handle_client app (client_sock, client_addr) =
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

let print_queue q =
  Printf.printf "Queue contents: [";
  Queue.iter (fun (_, addr) -> Printf.printf "(%s)" (addr_to_str addr)) q;
  Printf.printf "]\n";
  flush Stdlib.stdout

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

  (* Create the worker pool *)
  let worker_pool = Worker.create_pool 5 5 (handle_client app) in

  (* Round-robin request distribution *)
  let next_worker_index = ref 0 in

  while true do
    let client_sock, client_addr = accept sock in

    (* Get the next worker in round-robin fashion *)
    let worker_index = !next_worker_index mod worker_pool.worker_count in
    let worker = List.nth worker_pool.workers worker_index in

    (* Send request to the worker's channel *)
    let _ = Event.sync (Event.send worker.channel (client_sock, client_addr)) in

    next_worker_index := !next_worker_index + 1
  done

let run (app : t) = run_server app
