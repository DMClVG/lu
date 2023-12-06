
: person:new [
  make [ name age ]
]

: nl [ 10 emit ]
: type [ chars each emit ]

: space [ 32 emit ]

: number [ \ prints a number in base10
  10 /mod dup 0 = then [ drop ] else [ number ] 48 + emit
]

: person:print-info |> [
  [ "Name: " type :name type nl ]
  [ "Age: " type :age number nl ]
]

! [
  22 "John" person:new person:print-info
  20 "Mark" person:new person:print-info
  28 "Jessica" person:new person:print-info
]
