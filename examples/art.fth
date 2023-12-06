
: tile:new [ make [ t x y vx vy ] ]
: type [ chars each emit ]

: x-in-screen? [
  |> [ [ 0 >= ] [ cols < ] ] and
]

: y-in-screen? [
  |> [ [ 0 >= ] [ rows < ] ] and
]

: in-screen? [
  y-in-screen? swap x-in-screen? and
]

: 2dup [
  over over
]

: 2drop [
  drop drop
]

: draw [
  |> [ :t :x :y ]
  2dup in-screen?
  then [ goto type ] else [ 2drop drop ]
]

: init-screen [
  clear
  hide
]

: negate [
  0 swap -
]

: move [
  |> [
    :t
    [ |> [ :x :vx ] + ]
    [ |> [ :y :vy ] + ]
    :vx
    :vy
  ] tile:new
]

! [
  init-screen

  "Q" 9 0 1 0 tile:new
  "A" 19 0 1 negate 0 tile:new

  loop [
    clear

    move dup draw
    swap
    move dup draw

    100 sleep
  ]
]
