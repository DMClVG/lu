: type [ chars each emit ]
: 2drop [ drop drop ]

: tile make [ t p v ]
: point make [ x y ]

: point:unwrap |> [ :x :y ]

: +point [
  2 wrap |> [
    [ map :x reduce + ]
    [ map :y reduce + ]
  ] point
]

: range [ make [ a b ] ]

: in-range? [
  2 wrap |> [
    [ unwrap :a >= ]
    [ unwrap :b < ]
  ] and
]

: x-in-screen? [
  0 cols range in-range?
]

: y-in-screen? [
  0 rows range in-range?
]

: in-screen? [
  |> [
    [ :x x-in-screen? ]
    [ :y y-in-screen? ]
  ] and
]

: draw [
  |> [ :t :p ]
  dup in-screen? then [ point:unwrap goto type ] else [ 2drop ]
]

: init-screen [
  clear
  hide
]

: move [
  |> [
    :t
    [ |> [ :p :v ] +point ]
    :v
  ] tile
]

! [
  init-screen

  "Q" 9 0 point 1 0 point tile
  "A" 19 0 point -1 0 point tile

  loop [
    clear

    move dup draw
    swap
    move dup draw

    100 sleep
  ]
]
