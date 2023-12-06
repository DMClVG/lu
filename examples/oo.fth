
: person:new [
  make [ name age ]
]

: draw [
  dup :x over :y goto 80 emit
]

: nl [ 10 emit ]
: type [ chars each emit ]

: digit [
  48 + emit
]

: space [ 32 emit ]

: number [ \ prints a number in base10
  10 /mod dup 0 = then [ drop ] else [ number ] digit
]

! [
  22 "John" person:new |> [
    [ :name type space ]
    [ :age number nl ]
  ]
]
