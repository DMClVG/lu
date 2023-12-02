
: happy [
  104 emit
  97 emit
  112 emit
  112 emit
  121 emit
]

: smiley [
  58 emit
  41 emit
]

\ special ASCII-codes
: newline [ 10 emit ]
: space [ 32 emit ]

\ boolean logic
: true [ 1 ]
: false [ 0 ]
: zero? [ 0 = ]
: not [ 0 = ]

: digit [
  48 + emit
]

: number [ \ prints a number in base10
  10 /mod dup zero? then [ drop ] else [ number ] digit
]

: negate [ 0 swap - ]
: 2dup [ over over ]

: xor [ 2dup or -rot and not and ]

! [ \ entry point
  0 12 range [ drop happy space ] newline

  3 2 + number newline

  until [ true ] do [ happy ] \ never executed

  0 while [ dup 0 <> ] do [
    1 +
    happy space
  ] drop

  12312781 number newline

  3 times [ smiley space ] newline
]
