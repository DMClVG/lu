: nl [ 10 emit ]

: type [ chars each emit ]

: space [ " " type ]

: ok [ "ok" type space ]

! [
  2 times ok nl
]
