: inside-line? [
  |> [
    [ 0 >= ]
    [ cols < ]
  ] and
]

: goto-left-center [ 0 rows 2 / goto ]

: no-more-line [ \ row
  hide
  0 loop [
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
    80 sleep
  ]
]
: init-screen [
  clear
  0 0 goto
]

! [
  init-screen
  no-more-line
]
