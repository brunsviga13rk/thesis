// LTeX: language=en-US

#import "requirements.typ": *

#pagebreak(weak: true)

= Simulation

For the simulation implementation to take shape a comprehensive list of operations, declaring
actions the machine can perform, must be defined first. These actions are defined by the moves
a human user applies during operation from the device. These operations are derived from the
official manual of the machine @Brunsviga-13-R_1950.
The following operations are available:

#figure(
  table(
    columns: (2.5cm, 1fr),
    table.header([Action], [Description]),
    image("res/input.svg", width: 2cm), [Rotate input sprockets, sets the value of the input register.],
    image("res/addition.svg", width: 2cm), [Clockwise rotation of the operaiton crank, adds input register onto result register and increments counter.],
    image("res/subtract.svg", width: 2cm), [Counter-clockwise rotation of the operaiton crank, subtracts input register from result register and increments counter.],
    image("res/counter_reset.svg", width: 2cm), [Pull of counter reset handle, writes zero to counter register.],
    image("res/input_reset.svg", width: 2cm), [Pull input reset handle, writes zero to input register.],
    image("res/result_reset.svg", width: 2cm),  [Pull result reset handle, writes zero to result register.],
    image("res/all_reset.svg", width: 2cm), [Pull reset handle, writes zero to all registers.],
    image("res/sled_move.svg", width: 2cm), [Push shift knob to the right or left to shift the result register by one digit to the right or left.],
  ),
  caption: [Handbook of operations of calculator to a human user.]) <table:actions>

@table:actions depicts all actions and their respective effect on the calculator which require implementation in order
to offer complete functionality of the machine. Most of these actions are simple affine transformations applied to specific
parts of the machine like rotation or translation around a set origin. For example, pulling the reset levers requires
rotation around the mounting axis of the lever by a certain amount of degree. After completing the rotation in one direction,
the lever is to rotate back in the opposite direction to its origin position. Implementation of the operation crank requires
a multistep operation, as first, the knob holding the input sprocket locked must be extruded only then can the crank be rotated.
When completing the full rotation the knob must be inserted back in locking position in order to proceed with further operation.
The simulation must be capable of the above affine rotary and transitive motions around part origins as well as to combine
multiple such steps into more complex procedures. Component origins are properly defined during the modelling phase of
mesh and require no further tweaks after importing the model. All left to do is to develop an animation system capable of
handling the bespoken tasks.

== Event driven animations

In order to model single as well as multistep animations an event driven architecture promises relative simplicity
in both implementation and usage. The idea is for animations to "emit" events during specific stages. These might occur
when an animation starts, ends or reaches a certain point. This allows other animations to react to the state of other animations
creating chains of actions. The linking of animation events and their influence of each may be implemented by a distributed
state machine where each animation resides with the object it acts upon but can send events to unrelated animations.
This allows a great amount of complex behavior without having to cramp the logic into a single source file but distribute
the logic over multiple files.

=== Action formulation

For ease of use the machine's mesh is aligned to the global axis allowing each part of the machine to rotate and translate
only one of the global $(arrow(x),arrow(y),arrow(z))$ axis allowing for the use of a single scalar $x$.
Any of the described action's animation (@table:actions) can be represented by a set of scalar states, that is a real number
representing either of rotation round an axis or translation along a local axis.
Additionally, each and every animation
has a minimum and maximum bound $[mu_l, mu_u]$ where the scalar state is $mu_l lt.eq x lt.eq mu_u$.
For the rest levers these are the angle in the resting position and
the angle the lever is rotated when fully pulled back.
For these reasons an animation simply controls the transition from one end of the scalar bound to the other and vice versa.
This transformation is done at each step of the event loop, incrementally mutating the current state towards either end of the
bound. Computationally this is done by interpolating between the lower and upper bound of the animation.
An "advance" factor $t in [0,1]$ is introduced. When the animation state is equal to $mu_l$ this factor is equal to zero.
When the animation state is equal to $mu_u$ this factor is equal to one. Any state in between the boundary is represented
by an advance factor $0 lt.eq t lt.eq 1$. The current state of the animation is calculated as follows:

$
  overline(x) = (1 - t s) dot x_c + t s x_t; quad x_c, x_t in [mu_l, mu_u]
$ <eq:state-update>

This is essentially a linear interpolation depending on the advance factor from the current state of the start state animation $x_c$ and
a specific target state $x_t$ both of which are in between the minimum and maximum boundary. Both $x_c,x_t$ are constant during
an animation. This is from now on referred to as state blending or easing.
The animation state itself is not incremented directly in order to achieve precise control over the duration of the animation.
Each time the event loop processes an animation step the advance factor $t$ is incremented by the delta time of the current and last
frame $delta t$ multiplied by a timescale factor $s$. Assuming $delta t$ to be in seconds every animation, regardless of
motion type or boundary requires exactly one second to pass. The animation can be stretched or compressed temporally by the
timescale $s$. This allows to precisely know when an animation will end which is useful for timing animations later on.

=== Easing state

Performed linear motion is rarely perceived as being smooth. In the real world acceleration must overcome inertia for motion
to take place. This leads to lower speed at the start of motion. Inertia also applies when stopping an object where
the kinetic energy of the object in combination with its inertia will continue to push against the stopping force thus
gracefully stopping the object. Linear trajectories do not accurately model this behavior as motion occurs with constant speed
leading to abrupt starts and stops. Such animations do not only look unnatural but are also harder to follow with the eye.
In order to model the effect of inertia and smoothen the animation the initial state blending (@eq:state-update) is changed by performing a
non-linear transformation $g$, called easing function, around the advancement product $t s$:

$
  overline(x) = (1 - g(t s)) dot x_c + g(t s) dot x_t; quad x_c, x_t in [mu_l, mu_u]
$ <eq:eased-interpolation>

This transformation introduces non-linear qualities to the animation state resulting in non-uniform speed of the animation.
A classical formula for this is the cubic ease-in-out polynomial:

$
  g(t) = 3t^2 - 2t^3
$ <eq:cubic-ease-in-out>

The effect of which can be seen in @fig:interplation-functions in comparison to the linear angle bisector.
The cubic polynomial introduces a slowdown at the start where $t s lt 0.5$ simulating inertia when accelerating.
At $t = 0.5$ both interpolation functions advance the animation exactly by half. This is also
the point of highest speed where acceleration is at its maximum. At the end $t gt 0.5$
the cubic polynomial again slows down simulating a more graceful braking process.

#figure(
  [
    #let xs = lq.linspace(0, 1)
    #let ys_lin = xs.map((x) => x)
    #let ys_cubic = xs.map((x) => 3 * x * x - 2 * x * x * x)
    #let ys_quint = xs.map((x) => {
      if x < 0.5 {
        return 16.0 * x * x * x * x * x
      } else {
        let tmp = -2 * x + 2
        return 1 - tmp * tmp * tmp * tmp * tmp * 0.5
      }
    })

    #lq.diagram(
      width: 10cm,
      height: 5cm,
      xlabel: $x$,
      ylabel: $y$,
      legend: (position: left + top),
      margin: 10%,
      lq.plot(xs, ys_lin, mark: none, stroke: 1pt + orange, label: text(weight: "regular", [linear])),
      lq.plot(xs, ys_cubic, mark: none, stroke: 1pt + blue, label: [cubic ease-in-out]),
      lq.plot(xs, ys_quint, mark: none, stroke: 1pt + teal, label: [quintic ease-in-out])
    )
  ],
  caption: [Different interpolation functions.]
) <fig:interplation-functions>


By using introducing @eq:cubic-ease-in-out into @eq:eased-interpolation to compute the animation state,
the resulting action looks smoother and more natural.
Easing functions of higher degree may be used to model higher inertia such as the quintic ease
introducing higher computational complexity. Other common easing functions can be found
#link("https://easings.net/")[here]. Cubic ease-in-out provides the best tradeoff between smooth
transition and computational overhead.

=== Publish-Subscribe event model

Management of events is based on the publish-subscriber pattern. Actions are custom functions
run by an `EventHandler`.
`EventHandlers` may manage any number of actions but only a single condition. A condition specifies
an additional situation that must be satisfied for all the actions to be run. Its definition is based
on custom interfaces that are implemented for each `EventEmitter`.
Every type of event emitter specifies its own set of custom conditions.
`EventEmitter` also generate events. An event can carry custom data, usually produced by
the cause of the event. `EventHandler` discover available emitter through a broker interface
to which they can subscribe to specific events.
@fig:event-architecture shows a class diagram highlighting the conceptual architecture of
the software model.

#let def-class(type, name, members, functions) = [
    #if type != none [
      _\<\<#type\>\>_
    ]

    *#name*

    #if members != none {
      line(length: 100% + 12pt)
      align(left, for member in members {
        member
        linebreak()
      })
    }

    #if functions != none {
      line(length: 100% + 12pt)
      align(left, for function in functions {
        function
      })
    }
]

#figure(
  [
    #set par(spacing: 0.5em)
    #set block(below: 8pt, above: 8pt)
    #set text(size: 10pt)

    #diagram(
      node-stroke: 1pt,
      node-inset: 6pt,
      spacing: 2.5cm,

      node((0,1.25), def-class(none, "Tautology", none, none), shape: rect, name: <tautology>),
      node((0,0.7), def-class("interface", "Conditional", none, ("+ compare()")),  shape: rect, name: <conditional>),
      node((1,0.7), def-class("abstract", "EventHandler", none, none), shape: rect, name: <handler>),
      node((1,1.5), def-class("abstract", "EventEmitter", ("# Object actor", "# List<EventHandler> handler"), none), shape: rect, name: <emitter>),
      node((0.3,0), def-class("interface", "EventAction", none, none), shape: rect, name: <action>),
      node((1.7,0), def-class("interface", "EventBroker", none, ("getEmitter(): EventEmitter")), shape: rect, name: <broker>),

      edge(<tautology>, "-|>", <conditional>),
      edge(<conditional>, "->", <handler>, label: "Gatekeep trigger"),
      edge(<action>, "->", <handler>, label: "Run on event", label-side: right, label-sep: 5pt, label-pos: 20%),
      edge(<emitter>, "->", <handler>, label: "Emit event", bend: 30deg),
      edge(<handler>, "->", <emitter>, label: "Subscribe", bend: 30deg),
      edge(<broker>, "->", <emitter>, label: "Publish emitter", bend: 30deg,),
      edge(<handler>, "->", <broker>, label: "Discover emitter", bend: 10deg,))

      #v(5mm)
  ],
  caption: [Classdiagram of the event model.]
) <fig:event-architecture>

When emitter trigger events, all subscribed handler receive information about these events.
Their associated condition then decides based on the custom data provided by the event if
the action should run. By default, the condition is of type tautology which is always true
and will regardless of event data run all actions.
The abstract classes `EventEmitter` and `EventBroker` are to be implemented by classes
that emit events such as levers that can be pulled. In this use case the lever
provides conditions when the lever is pulled down, pushed up, pull down done and push up done.
Each movable part of the machine implements custom conditions allowing to model
dynamic and interwoven animation systems. It also allows animations to react to changes
by subscribing to its own emitter. Such cases shall be used with great care as this
can lead to an infinite loop when actions trigger themselves continuously
preventing the event loop from advancing any further. It should also be avoided to
form too long of event-action chains, as these may stretch the frame time by
consuming significant processing time thus lagging out the event loop.
Its vulnerability to overload and self triggering actions is a significant drawback of this system.
A possible solution might be to dispatch actions asynchronously, although this does not protect from
overloading the scheduler. A better option might be to run the event processing code in a separate web worker.
However this would introduce a considerable overhead for transferring state information between web workers.
While this system is certainly not foolproof it allows building intricate animation systems with relative ease.
Though it certainly is a future area worth improving on.

=== Event conditions

Actions may be triggered by various types of events. For a scalar state four types
of conditions have proven useful during development. An event may be triggered when:

- Starting an animation.
- The end of an animation is reached.
- Animation state changes (animation is ongoing).
- A specific state value was overrun.

The first two condition are quite simple. At the first increment of an animation, when
a new target is set, the "started" event is triggered. This event runs only once for the
first increment of an animation targeting a value. A "stopped" event is triggered when
the animation state has reached the target value and the advancement factor is one.
An event may also be triggered at any increment of a given animation. Much more intricate
animations require an overrun condition. This condition is true whenever the animation
passed by a specific value. Useful when a pulled lever starts to pull down a second lever
halfway through its animation. The overrun condition is checked each time an increment
in the animation occurs. Every animation increment advances the state by a certain interval
ranging from the previous animation state $overline(x)_0$ to the next $overline(x)_1$
as specified by the transformation of the advancement factor by $delta t$.
In case the overrun variable $h$ is inside this interval, then the condition is true,
as the animation has "stepped over" by the trigger value.
The situation can be seen in @fig:overrun-true.

#figure([
  #diagram(
    edge-stroke: 1pt,
    edge((0,1), (7,1), "|..|"),
    node((0,1.35), $mu_l$),
    node((7,1.35), $mu_u$),

    edge((2,1),(5,1),">-<", stroke: 1pt),

    node((1,1), circle(fill: black, radius: 0.25em)),
    node((1,1.35), $x_c$),

    node((6,1), circle(fill: black, radius: 0.25em)),
    node((6,1.35), $x_t$),

    node((2,1.35), $overline(x)_0$),
    node((5,1.35), $overline(x)_1$),

    node((3.5,1), "|"),
    node((3.5,1.35), $h$),

    edge((2.1,0.8), (4.9,0.8), "-->", bend: 25deg),
    node((3.5,0.25), $delta t$))
  #v(1em)
], caption: [Overrun condition met for $h$ when animating between $x_c$ and $x_t$.]) <fig:overrun-true>

For all other cases, when $h$ is outside the interval $[overline(x)_0,overline(x)_1]$ the overrun condition
is false since the overrun value $h$ as neither already been passed nor will be passed at some point in the future which
may also be never, when $h$ beyond the target value $x_t$.
@fig:overrun-false shows a situation in which an animation will trigger the overrun condition in the next
increments but not at present.

#figure([
  #diagram(
    edge-stroke: 1pt,
    edge((0,1), (7,1), "|..|"),
    node((0,1.35), $mu_l$),
    node((7,1.35), $mu_u$),

    edge((1.5,1),(4,1),">-<", stroke: 1pt),

    node((1,1), circle(fill: black, radius: 0.25em)),
    node((1,1.35), $x_c$),

    node((6,1), circle(fill: black, radius: 0.25em)),
    node((6,1.35), $x_t$),

    node((1.5,1.35), $overline(x)_0$),
    node((4,1.35), $overline(x)_1$),

    node((5,1), "|"),
    node((5,1.35), $h$),

    edge((1.6,0.8), (3.9,0.8), "-->", bend: 25deg),
    node((2.75,0.25), $delta t$))
  #v(1em)
], caption: [Overrun condition not met when animating between $x_c$ and $x_t$.]) <fig:overrun-false>

It should be noted that at current time there is no method in place avoiding infinite recursion when
animations subsequently update their own state based on change events from other animations.
An animations state is to be considered volatile, and it may be mutated by events emitted by other animations
before, during and after an increment. Due to the nature of the frame time increment $delta t$
All described events may trigger at the same increment when the $x_t - x_c lt delta t dot s$ as in this
case the animation starts and stops with the same increments thus possibly triggering all events at once.

=== Synchronization attachments

A common occurrence when connecting animations is one animation state following the increments of another.
This happens when a mechanical part carries or pushes another one.
For this purpose the scalar animation state can synchronize itself to another animation
by attaching. In this case the animation synchronizes its own state (not the advancement factor)
to the state increment of the target animation. In this case it may happen, that the animations state
overflows its boundary. Increments by $delta t$ are disabled in this mode.
Upon releasing from the synchronization all targets are cleared and the animation is stalled.
In this situation its state may too be outside its boundary interval.
However when animating towards the next target the animation will automatically move
back into its valid range of operation.

== Solving calculations

A handy feature of the simulation is to automatically produce all the steps necessary to perform
a certain calculation. Not everybody is familiar with the handling of the calculator. Thus offering
easy verification of the steps undertaken to perform a certain calculation is quite useful.
As such to goal is to transform calculations from infix notation to a list of operations that can directly
be executed by the user on a physical machine or in the simulation itself.

=== Notation transformer

By convention most people use infix notation to write down equations. Infix notation
places two operands around the operator. Example calculation given in @eq:infix.
In addition, terms may be surrounded parenthesis.

$
  3 * (7 + 8)
$ <eq:infix>

Every operator as a certain precedence. Operators with higher precedence will bind operands towards them.
In the example $3 + 4 * 8$ the multiplication has higher precedence than the addition, thus binding both operands
of $4,8$ meaning first we must compute $4 * 8$ onto which we can add $3$. A list of operator precedence can be found in
@table:precedence. This table also shows the operators implemented in the simulation with one exception being division.
The steps used to generate the operation steps is shown below:

#figure(
  [
    #diagram(
    node-stroke: 1pt + black,
    edge-stroke: 1pt + black,
    node-corner-radius: 0.5em,
    spacing: 1em,
    node((0,0), fill: black, circle(fill: black, radius: 0.25em)),
    node((2,0), shape: rect, "Tokenize"),
    node((4,0), "Shunting yard"),
    node((0,2), "Interpret"),
    node((2,2), "Generate"),
    node((4,2), "Squash"),
    edge((0,0), (2,0), "->"),
    edge((2,0), (4,0), "->"),
    edge((4,0), "r,d,llllll,d,r", "->"),
    edge((2,2), (4,2), "->"),
    edge((0,2), (2,2), "->")
  )
  #v(1em)
  ], caption: [Architecture of linear notation transformer.]
)

The first step for producing postfix notation is to tokenize the calculation as the user
edits only a string of characters. Tokenization is performed by splitting the string
using regular expressions and filtering out empty tokens. Each token is a string containing
either an operator or an operand of which there are for now only positive integer numbers.
The array of tokens preserves the order in which the tokens appear in the string.

Sine infix notation does not translate well to calculator operations, the notation needs to be translated to
the operations described in @table:actions. In the upcoming text these will also be referred to as instruction.
The first step in producing these instructions is to compile the infix notation to @RPN otherwise known
as postfix notation. In this notation the operands follow their operator. @eq:infix would look like the following
compiled to postfix:

$
  7 space 8 space + space 3 space *
$

Parenthesis vanish and only their effect on operator precedence is left behind.
Converting to @RPN is done by applying the shunting yard algorithm (@appendix:shunting-yard)
to the list of tokens. This algorithm works by pushing the operator tokens (including parenthesis)
onto a separate temporary stack and pushing numbers to the output queue.
Operators with higher precedence are moved from the stack to the output when an operator
with lower precedence is found as token. This ensured that operators always follow their operands
and operators with higher precedence bind before those with a lower.
The shunting yard algorithm can also detect mismatched parenthesis that is when parenthesis are
left over on the operator stack or a right side parenthesis is unexpectedly found in the list of tokens.
The shunting yard algorithm is also capable of handling functions with parameters and right associative
operators such as exponentiation. Due to time constraints functions and exponentiation remain
unimplemented in the solver. As a side note, any token that cannot be parsed by shunting yard
or the interpreter will cause the solver to return in error.
After converting to @RPN we are left with a notation that is straight forward to execute on paper.
Which is the reason @RPN is often used to small calculator projects. All that is needed to do is to pop
all numbers of the queue until an operator is found. Then the operator is applied to the last to
operand popped from the queue of which the result is pushed back in the queue. After reading all tokens
from the queue the last touched number is the result of the calculation. This can easily be implemented
with a stack based machine. Here comes the interpreter into place. The interpreter much like a real calculator
steps through the queue computing the result. Along this way the interpreter generates the instruction required
to perform the step on the Brunsviga. For equations of all kind this method assumes temporary storage
that in reality would be a piece of paper since the calculator is not capable to storing a separate temporary
value different from the result and input register. Steps generated for a chain of additions would
look like the following:

#figure(
  [
    #diagram(
      spacing: 2em,
      edge-stroke: 1pt + black,
      node-corner-radius: 0.5em,

      node((0,0), "3 + 5 + 7 (input string)"),

      node((0,1), [*Tokenize*]),
      node((1,1), ${3,+,5,+,7}$),
      edge((0,1), "r", "..>"),
      edge((0,0), "l,d,r", "-|>"),

      node((0,3), [*Shunting yard*]),
      node((1,3), ${3,5,+,7,+}$),
      edge((0,3), "r", "..>"),
      edge((1,1), "r,d,lll,d,r", "-|>"),

      node((0,5), [*Interpret/Generate*]),
      edge((0,5), "r", "..>"),
      node((1,5), raw(block: true,
     "load 3, add,
load 5, add,
load 7, add")),
      edge((1,3), "r,d,lll,d,r", "-|>"),
  )
  #v(1em)
  ], caption: [Example transformation of a sum.]
)

The most intricate step is the interpreter that performs the following evaluation for
any given operation: in case the first operator is a subtraction or addition, the first operand
is loaded into the input register of the machine. Afterward, the first value is added onto the result register.
Then the second operand is loaded onto the input register and added or subtracted depending on the operator onto
the result register. In case the operator is not the first one to be processed, the first operand is assumed to already
loaded into the result. Then the second operand is loaded into the input register and either added or subtracted from the result.
Optionally before generating the instructions for the first operation all registers may be cleared.
Not shown is the squash operation which reduces the resulting list of instructions by merging redundant operations together
like clearing registers multiple times in a row. This step is more useful with more complex
calculations involving multiplication.

=== Multiplication algorithm

Computation of products is not as straight forward as it might seem at first:
every product of two integral numbers can be expressed as summing the first number
as often as the absolute value of the second. For example:

$
    3 dot 4 = 3 + 3 + 3 + 3 = 12 \
$

However, this is only a practical approach when one of the factors is a small
number, let's say smaller than ten. For products composed for much larger
numbers the long multiplication algorithm can be used. With long multiplication
the product of two integral numbers is split into several additions.
Pseudocode of the implementation used in the interpreter can be found in @fig:long-mult.
Since the algorithm in pseudocode is a bit hard on the eye let's explore how
we do it on the Brunsviga. For this purpose we image two factors:
$a = 785$ and $b = 56$. Very impractical to compute the product with the first method.
Summing $785$ $56$ times in a row takes quite some time.
First find the minimum and maximum value of the two. Then split the smaller of
the two into the coefficients used in composing the decimal representation:

$
    x = 10^k dot c_k + 10^(k-1) dot c_(k-1) + dots + 10^0 dot c_0 quad k = floor(log_10(x)), k in NN, c in RR \
    ==> 56 = 10^1 dot 5 + 10^0 dot 6
$

Then start iterating over the coefficients and keep an eye on the associated exponent
value. The exponent is the amount the sled has to be shifted to the right
and the coefficient is how many times the larger number ($785$ in this case) has
to be added for each iteration. The algorithm then looks like the following:

1. Find maximum and minimum of $a,b$.
3. Load the larger number into the input register and clear the result.
2. Iterate over decimal coefficients of the smaller number:
    1. Shift the sled by the value of the exponent to the right.
    2. The coefficient is the count by how often to add the input onto the result.
    3. Reset the sled.

== Programmable application interface

Besides solving calculations and interactivity, there is no option to
run more complex algorithms on the machine besides doing all steps manually.
For this purpose a text editor for custom scripts is added as
a secondary option to the tab panel where the calculation solver resides.
All operations shown in table @table:actions have their equivalent
interface function in the Typescript source:

#figure(raw(lang: "typescript", read("res/ts-api.ts").trim()), caption: [
    Stub of the Brunsviga 13 RK programmatic class interface.
])

These are functions that allow direct interaction with the model, animations
and its state. Notice the usage of the `async` keyword. This due to the fact,
that these functions wait until the animation they trigger have completed.
Calling methods can decide whether to await them or not.
Functions that retrieve a value from the register do not need to wait for anything
since they trigger no animations or state change.

=== Moonshine

The goal is now to abstract this interface with its asynchronous nature behind
a scripting language that is, based on the authors' opinion, easier to read and
write, especially for non-programmers: Lua. The Lua programming language
is a "powerful, efficient, lightweight, embeddable scripting language" @Lua_About.
Lua has a simple syntax and is considerably easier conceptually than Typescript
with its static typing and strong object orientation but convoluted evolution.
Additionally, the lightweight nature of the Lua interpreter makes it an
excellent choice to embed into the project since its very small and fast.
The Lua runtime offers a comprehensive list of functions to interact with the
running Lua instance. #link("https://github.com/ceifa/wasmoon", "Wasmoon")
#footnote("https://github.com/ceifa/wasmoon")
is chosen as the binding for Typescript since it packages the Lua interpreter
as precompiled @WASM making it much faster in execution than Lua interpreter
written in Javascript. Beneficial is also the libraries feature to automatically
wrap Typescript classes and global functions in order to expose them directly
to any Lua scripts. This comes in handy when accessing the Typescript interface.

=== Lua abstraction

While it is possible to pass the Brunsviga class as a global to the Lua script
directly there are several disadvantages to this method. First, since
most functions in the Typescript interface are asynchronous the author of Lua
scripts would need to call `await()` after every call except those reading
register values to avoid messing up the state of the machine. Additionally,
the Lua script has access to all other kinds of methods from the class
which undesired and makes a messy appeal.
In order to circumvent these issues a separate class is implemented in Typescript
called the `Brunsviga13rkLuaAPI`. It acts as an intermediate between
the raw Brunsviga interface Lua. It serves the purpose of only exposing functions
to Lua scripts that won't break the simulation and perform some type safety on top.
However, users still need to call `await()` for every asynchronous functions.
For this reason another abstraction is generated. This time in pure Lua.

#figure([
    #diagram(
        node-stroke: 1pt + black,
        spacing: 0pt,
        node((0,0), width: 5em, shape: triangle, "Lua API"),
        node((0,1), width: 9.95em, shape: trapezium.with(angle: 70deg), "Typescript API"),
        node((0,2), width: 14.6em, shape: trapezium.with(angle: 70deg), "Brunsviga API"),
        node((2, 0), stroke: none, width: 18em, align(left)[#h(3em) Await futures]),
        node((2, 1), stroke: none, width: 18em, align(left)[#h(3em) Type safety + sanatisation]),
        node((2, 2), stroke: none, width: 18em, align(left)[#h(3em) Abstraction of animation state]))
    #v(1em)
], caption: [Layers of interface abstractions and their purpose.])

This is the actual interface scriptwriter are meant to interact with.
It wraps all Typescript functions of the `Brunsviga13rkLuaAPI` by native
Lua functions and automatically calls `await()` were necessary. While
authors are discouraged from directly using the `Brunsviga13rkLuaAPI` instead
of the native Lua abstraction it is still possible but should be avoided.
@fig:lua-template shows the template code used to give an initial sample for
a working Lua script. This script loads the Lua interface in the first line
and after resetting the machine calculates the difference between 79 and 8.
