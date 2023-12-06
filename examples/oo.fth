
: person-new [
  make [ x 0 y 0 ]
]

: draw [
  dup :x over :y goto 80 emit
]

! [
  person-new
  clear draw
]
