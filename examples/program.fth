: nl [ 10 emit ]

: type [ chars each emit ]

: space [ " " type ]

: ok [ "ok" type space ]

: 3dup [
  2 pick 2 pick 2 pick
]

: inside-line? [ dup 0 >= swap cols < and ]

: goto-left-center [ 0 rows 2 / goto ]

: no-more-line [ \ row
  hide
  0 while 1 do [
    clear-line

    goto-left-center

    dup while [ dup cols < ] do [

      "- No More - " chars each [
        swap \ char i

        dup inside-line? then [ swap emit ] else [ swap drop ]

        1 +
      ]
    ] drop

    1 -
    100 sleep
  ]
]

! [
  clear
  \ clear
  \ 0 0 goto
  \ 2 times ok ":)" type nl

  \ 0 rows goto

  0 0 goto

  no-more-line
]
