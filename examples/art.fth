
: tile make [ t p v ]
: point make [ x y ]

: point:unwrap |> [ :x :y ]

: +point [
  2 wrap |> [
    [ unwrap :x swap :x + ]
    [ unwrap :y swap :y + ]
  ] point
]

: type [ chars each emit ]
: 2dup [ over over ]
: 2drop [ drop drop ]

: x-in-screen? [
  |> [ [ 0 >= ] [ cols < ] ] and
]

: y-in-screen? [
  |> [ [ 0 >= ] [ rows < ] ] and
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
  "A" 19 0 point -1 1 point tile

  loop [
    clear

    move dup draw
    swap
    move dup draw

    100 sleep
  ]
]
