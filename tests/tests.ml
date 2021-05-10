open! Otr

let router =
  Otr.(
    create
      [ {%otr| /home/about |} >- "about page"
      ; ({%otr| /home/:int/ |}
        >- fun i -> "Product Page. Product Id : " ^ string_of_int i)
      ; ({%otr| /home/:float/ |}
        >- fun f -> "Float page. number : " ^ string_of_float f)
      ; ({%otr| /contact/*/:int |}
        >- fun name number ->
        "Contact page. Hi, " ^ name ^ ". Number " ^ string_of_int number)
      ; {%otr| /home/products/** |} >- "full splat page"
      ; ({%otr| /home/*/** |} >- fun s -> "Wildcard page. " ^ s)
      ; ({%otr| /contact/:string/:bool |}
        >- fun name call_me_later ->
        "Contact Page2. Name "
        ^ name
        ^ ". Call me later: "
        ^ string_of_bool call_me_later)
      ; ({%otr| /product/:string?section=:int&q=:bool |}
        >- fun name section_id q ->
        Printf.sprintf "Product detail - %s. Section: %d. Display questions? %b"
          name section_id q)
      ; ({%otr| /product/:string?section=:int&q1=yes |}
        >- fun name section_id ->
        Printf.sprintf "Product detail 2 - %s. Section: %d." name section_id)
      ])

let () =
  assert (Some "Float page. number : 100001.1" = match' router "/home/100001.1/");
  assert (None = match' router "/home/100001.1");
  assert (
    Some "Product Page. Product Id : 100001" = match' router "/home/100001/");
  assert (Some "about page" = match' router "/home/about");
  assert (None = match' router "/home/about/");
  assert (
    Some "Contact page. Hi, bikal. Number 123456"
    = match' router "/contact/bikal/123456");
  assert (
    Some "full splat page"
    = match' router "/home/products/asdfasdf\nasdfasdfasd");
  assert (Some "full splat page" = match' router "/home/products/");
  assert (None = match' router "/home/products");
  assert (Some "Wildcard page. product1" = match' router "/home/product1/");
  assert (None = match' router "/home/product1");
  assert (
    Some "Contact Page2. Name bikal. Call me later: true"
    = match' router "/contact/bikal/true");
  assert (
    Some "Contact Page2. Name bob. Call me later: false"
    = match' router "/contact/bob/false");
  assert (
    Some "Product detail - dyson350. Section: 233. Display questions? true"
    = match' router "/product/dyson350?section=233&q=true");
  assert (
    Some "Product detail - dyson350. Section: 2. Display questions? false"
    = match' router "/product/dyson350?section=2&q=false");
  assert (None = match' router "/product/dyson350?section=2&q1=no");
  assert (
    Some "Product detail 2 - dyson350. Section: 2."
    = match' router "/product/dyson350?section=2&q1=yes")