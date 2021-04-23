type ('ty, 'v) t =
  | End : ('v, 'v) t
  | Constant : string * ('ty, 'v) t -> ('ty, 'v) t
  | String : ('ty, 'v) t -> (string -> 'ty, 'v) t
  | Int : ('ty, 'v) t -> (int -> 'ty, 'v) t

let rec kprintf : type ty res. (string -> res) -> (ty, res) t -> ty =
 fun k -> function
  | End -> k ""
  | Constant (const, fmt) -> kprintf (fun str -> k @@ const ^ str) fmt
  | String fmt ->
    let f s = kprintf (fun str -> k @@ s ^ str) fmt in
    f
  | Int fmt ->
    let f i = kprintf (fun str -> k @@ string_of_int i ^ str) fmt in
    f

let printf : ('ty, 'v) t -> 'a = fun fmt -> kprintf (fun x -> x) fmt

let fmt1 = String (Constant (" | ", String (Constant (" ", Int End))))

let f1 = printf fmt1 "hello" "hello" 12

let fmt2 = Constant ("||", Constant ("   ", End))

let f = printf fmt2

type param =
  | Int of int
  | Float of float

let rec apply : type ty res. (ty, res) t -> ty -> res =
 fun fmt f ->
  match fmt with
  | End -> f
  | Constant (_, fmt) -> apply fmt f
  | String fmt -> apply fmt (f "hello")
  | Int fmt -> apply fmt (f 10)

let a = apply fmt1 (fun s1 s2 i -> s1 ^ " || " ^ s2 ^ " || " ^ string_of_int i)
(* - : string = "hello || hello || 10" *)
