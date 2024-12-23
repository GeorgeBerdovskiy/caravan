open Unix

type http_method = GET | POST

(** Abstract type representing HTTP content types. *)
type content_type =
  | Text_Plain  (** text/plain *)
  | Application_Json  (** application.json *)

(** Abstract type representing HTTP status. *)
type status =
  | OK  (** 200 *)
  | Created  (** 201 *)
  | Bad_Request  (** 400 *)
  | Not_Found  (** 404 *)
  | Internal_Server_Error  (** 500 *)

(** Given an HTTP status, returns its code as an integer.  *)
let to_code = function
  | OK -> 200
  | Created -> 201
  | Bad_Request -> 400
  | Not_Found -> 404
  | Internal_Server_Error -> 500

(** Given an HTTP status, returns its corresponding message.  *)
let to_message = function
  | OK -> "OK"
  | Created -> "Created"
  | Bad_Request -> "Bad Request"
  | Not_Found -> "Not Found"
  | Internal_Server_Error -> "Internal Server Error"

(** Given a status, return its string representation. *)
let to_string_status status =
  Printf.sprintf "%d %s" (to_code status) (to_message status)

(** Given a content type, return its string representation. *)
let to_string_content_type = function
  | Text_Plain -> "text/plain"
  | Application_Json -> "application/json"

let from_string_http_method = function
  | "GET" -> GET
  | "POST" -> POST
  | _ -> GET

(** Build an HTTP response using the provided status and content type. Default
    status is [OK] and default content type is [text/plain]. *)
let build_http_response ?(status = OK) ?(content_type = Text_Plain) body =
  let status_string = to_string_status status in
  let content_type_string = to_string_content_type content_type in
  Printf.sprintf
    "HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %d\r\n\r\n%s"
    status_string content_type_string (String.length body) body

let read_http_request sock =
  (* Create a 1 KB buffer *)
  let buf = Bytes.create 1024 in

  (* Read from the socket into the buffer *)
  let n = recv sock buf 0 1024 [] in

  (* Convert received bytes into string *)
  Bytes.sub_string buf 0 n

let parse_request_line line =
  match String.split_on_char ' ' line with
  | [ method_; path; _version ] -> (method_, path)
  | _ -> ("", "")
(* Invalid request line *)
