require "examples.base"

: compute-delta [
  unwrap swap \ a c b
  square -rot \ b a c
  4 * * -
]

: b [ unwrap drop nip ]
: a [ unwrap drop drop ]

: quadratic [
  |> [
    [ |> [
        [ compute-delta sqrt]
        [ b negate ]
      ] + ]
    [ a 2 * ]
  ] /
]

! [
  (12) 12 = .s
  ( 1 8 3 ) quadratic .s
]
