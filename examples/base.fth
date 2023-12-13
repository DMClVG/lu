\ special ASCII-codes
: space [ 32 emit ]
: nl [ 10 emit ]

: type [ chars each emit ]

: number [ \ prints a number in base10
  10 /mod dup 0 = then [ drop ] else [ number ] 48 + emit
]

\ boolean logic
: true [ 1 ]
: false [ 0 ]
: zero? [ 0 = ]
: not [ 0 = ]

\ math
: negate [ 0 swap - ]

\ manipulation
: product [ 1 fold-left * ]
: sum [ 0 fold-left + ]
: 2dup [ over over ]
: square [ dup * ]
: 2drop [ drop drop ]

: smiley [
  58 emit
  41 emit
]
