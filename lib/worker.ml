type t = { channel : (Unix.file_descr * Unix.sockaddr) Event.channel }
type pool = { worker_count : int; workers : t list }

let create worker_index thread_count request_handler =
  let channel = Event.new_channel () in
  let _ =
    Domain.spawn (fun _ ->
        let queue = Queue.create () in
        let mutex = Mutex.create () in
        let _ =
          List.init thread_count (fun thread_index ->
              Thread.create
                (fun _ ->
                  while true do
                    Mutex.lock mutex;
                    let _ =
                      match Queue.take_opt queue with
                      | Some request ->
                          Printf.printf
                            "[DEBUG] [W%d] [T%d] Request received.\n"
                            worker_index thread_index;
                          flush Stdlib.stdout;
                          request_handler request
                      | None -> ()
                    in
                    Mutex.unlock mutex
                  done)
                ())
        in

        while true do
          let request = Event.sync (Event.receive channel) in
          Mutex.lock mutex;
          Queue.add request queue;
          Mutex.unlock mutex
        done)
  in
  { channel }

let create_pool worker_count thread_count request_handler =
  let workers =
    List.init worker_count (fun worker_index ->
        create worker_index thread_count request_handler)
  in
  { worker_count; workers }
