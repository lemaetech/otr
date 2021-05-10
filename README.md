# Otr - OCaml Typed Router 
*(Unreleased)*

A typed router for OCaml web applications. Here is what otr is and can do:

- A trie based router.
- Route handlers are type-checked during compilation.
- Supports matching and capturing URI path components, eg `/home/about/:int`.
- Supports matching and capturing on query parameters, eg `/home/about?q=:int&q1=hello`.
- Supports converting URI to OCaml data types as well and custom defined data types. For now conversion to `int`, `float`, `bool`, and `string` are supported. 
- Provides a ppx for API ergonomics. Specify uri path as it appears in the browser, eg. `/home/about`, `/home/:int`.

__A Demo of the features__

```ocaml

open! Otr

let prod_page i = "Product Page. Product Id : " ^ string_of_int i

let float_page f = "Float page. number : " ^ string_of_float f

let contact_page name number =
  "Contact page. Hi, " ^ name ^ ". Number " ^ string_of_int number

let product_detail name section_id q =
  Printf.sprintf "Product detail - %s. Section: %d. Display questions? %b" name
    section_id q

let product2 name section_id =
  Printf.sprintf "Product detail 2 - %s. Section: %d." name section_id

let router =
  create
    [ {%otr| /home/about                           |} >- "about page"
    ; {%otr| /home/:int/                           |} >- prod_page
    ; {%otr| /home/:float/                         |} >- float_page
    ; {%otr| /contact/*/:int                       |} >- contact_page
    ; {%otr| /product/:string?section=:int&q=:bool |} >- product_detail
    ; {%otr| /product/:string?section=:int&q1=yes  |} >- product2
    ]

let () =
  [ Otr.match' router "/home/100001.1/"
  ; Otr.match' router "/home/100001/"
  ; Otr.match' router "/home/about"
  ; Otr.match' router "/product/dyson350?section=233&q=true"
  ; Otr.match' router "/product/dyson350?section=2&q=false"
  ; Otr.match' router "/product/dyson350?section=2&q1=yes"
  ; Otr.match' router "/product/dyson350?section=2&q1=no"
  ]
  |> List.iteri (fun i -> function
       | Some s -> Printf.printf "%d: %s\n" (i + 1) s
       | None -> Printf.printf "%d: None\n" (i + 1))

(* Should output below: 

1: Float page. number : 100001.1
2: Product Page. Product Id : 100001
3: about page
4: Product detail - dyson350. Section: 233. Display questions? true
5: Product detail - dyson350. Section: 2. Display questions? false
6: Product detail 2 - dyson350. Section: 2.
7: None

*)

```
