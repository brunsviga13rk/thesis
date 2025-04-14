
= Compression data generator

#figure(
    raw(read("res/compression-generator.sh"), lang: "bash"),
    caption: [Shell script used to generate data for compressed images.]
)


= Operator precedence <table:precedence>

#figure(
  table(columns: 2, table.header([Operator], [Precedence]),
  [+], [1],
  [-], [1],
  [\*], [2],
  [/], [2],
  [(], [3],
  [)], [3]), caption: [Operator precedence as used in the simulation.]
) 

= Shunting yard algorithm <appendix:shunting-yard>

#import "@preview/lovelace:0.3.0": *

#figure(
  pseudocode-list[
  + *for* all tokens *do*
    + *if* token is number *do*
      + push to output queue
    + *if* token is function *do*
      + push to operator stack
    + *if* token is operator $o_1$ *do*
      + *while* token $o_2$ ontop of operator stack *do*
        + *if* $o_1$ not "(" *and* $o_2 gt o_1$ *do*
          + pop $o_2$ to output queue
        + *else do*
          + *break*
        + *end*
      + *end*
    + *end*
    + *if* token is "," *do*
      + *while* token $o_2$ ontop of operator stack *do*
        + *if* $o_1$ not "(" *do*
          + pop $o_2$ to output queue
        + *else do*
          + *break*
        + *end*
      + *end*
    + *end*
    + *if* token is "(" *do*
      + push into operator stack
    + *end*
    + *if* token is ")" *do*
      + *while* token $o_2$ ontop of operator stack *do*
        + *if* $o_1$ not "(" *do*
          + pop $o_2$ to output queue
        + *else do*
          + *break*
        + *end*
      + *end*
      + pop left parenthesis off the operator stack
      + *if* function ontop of operator stack *do*
        + pop function from the operator stack into the output queue
      + *end*
    + *end*
  + *end*
  + *while* token on operator stack *do*
    + pop operator from the operator stack onto the output queue
  + *end*
], caption: [Shunting yard algorithm.]
)
