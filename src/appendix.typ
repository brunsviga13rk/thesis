#import "requirements.typ": *

= Compression data generator

Bash script used to generate the data of the evaluation compression
algorithms used by different raster file formats.

#figure(
    raw(read("res/compression-generator.sh"), lang: "bash"),
    caption: [Shell script used to generate data for compressed images.]
)

== Operator precedence <table:precedence>

#figure(
  table(columns: 2, table.header([Operator], [Precedence]),
  [+], [1],
  [-], [1],
  [\*], [2],
  [/], [2],
  [(], [3],
  [)], [3]), caption: [Operator precedence as used in the simulation.]
)

== Shunting yard algorithm <appendix:shunting-yard>

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

== Long multiplication <fig:long-mult>

#figure(
  pseudocode-list[
      + *let* a := integer number
      + *let* b := integer number
      + *let* $v_max$ := max(a, b)
      + *let* $v_min$ := min(a, b)
      + *let* s := $floor(log_10(v_min))$
      + *let* sum := 0
      + *for* i := 0 *to* s *do*
        + *let* k := $mod(frac(v_min, 10^i), 10)$
        + *for* j := 0 *to* k *do*
            + sum += $v_max$
        + *end*
      + *end*
  ], caption: [Long multiplication.])

#figure(raw(lang: "lua", read("res/example.lua").trim()), caption: [
    Template program for the Lua editor.
]) <fig:lua-template>

== Typescript interface stub <appendix:ts-stub>

#figure(raw(lang: "typescript", read("res/ts-api.ts").trim()), caption: [
    Stub of the Brunsviga 13 RK programmatic class interface.
])
