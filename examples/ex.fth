require "examples.base"

: happy [
  "happy" chars each emit
]

! [ \ entry point
  12 times [ happy space ] newline

  3 2 + number newline

  until true do happy \ never executed :'(

  0 while [ dup 0 <> ] do [
    1 +
    happy space
  ] drop

  12312781 number newline

  3 times [ smiley space ] newline
]
