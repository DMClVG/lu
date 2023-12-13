require "examples.base"

: person:new [
  make [ age name ]
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
