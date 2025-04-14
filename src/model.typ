// LTeX: language=en-US

#import "requirements.typ": *
#import "@preview/lilaq:0.2.0" as lq
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge
#import fletcher.shapes: rect

#pagebreak(weak: true)

= Simulation

For the simulation implementation to take shape a comprehensive list of operations, declaring
actions the machine can perform, must be defined first. These actions are defined by the moves
a human user applies during operation from the device. These operations are derived from the
official manual of the machine @Brunsviga-13-R_1950.
The following operations are available:

#figure(
  table(
    columns: 2,
    table.header([Name], [Action and description]),
    [Select input], [Rotate input sprockets, sets the value of the input register.],
    [Addition], [Clockwise rotation of the operaiton crank, adds input register onto result register and increments counter.],
    [Subtraction], [Counter-clockwise rotation of the operaiton crank, subtracts input register from result register and increments counter.],
    [Reset counter], [Pull of counter reset handle, writes zero to counter register.],
    [Reset input], [Pull input reset handle, writes zero to input register.],
    [Reset result], [Pull result reset handle, writes zero to result register.],
    [Reset machine], [Pull reset handle, writes zero to all registers.],
    [Right shift sled], [Push shift knob to the right to shift the result register by one digit to the right.],
    [Left shift sled], [Push shift knob to the left to shift the result register by one digit to the left.]
  ),
  caption: [Operations of calculator to a human user.]) <table:actions>

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
$

This is essentially a linear interpolation depending on the advance factor from the current state of the start state animation $x_c$ and
a specific target state $x_t$ both of which are in between the minimum and maximum boundary. Both $x_c,x_t$ are constant during
an animation. This is from now on referred to as state blending or easing.
The animation state itself is not incremented directly in order to achieve precise control over the duration of the animation.
Each time the event loop processes an animation step the advance factor $t$ is incremented by the delta time of the current and last
frame $delta t$ multiplied by a timescale factor $s$. Assuming $delta t$ to be in seconds every animation, regardless of
motion type or boundary requires exactly one second to pass. The animation can be stretched or compressed temporally by the
timescale $s$. This allows to precisely know when an animation will end which is useful for timing animations later on.

== Easing state

Performed linear motion is rarely perceived as being smooth. In the real world acceleration must overcome inertia for motion
to take place. This leads to lower speed at the start of motion. Inertia also applies when stopping an object where
the kinetic energy of the object in combination with its inertia will continue to push against the stopping force thus
gracefully stopping the object. Linear trajectories do not accurately model this behavior as motion occurs with constant speed
leading to abrupt starts and stops. Such animations do not only look unnatural but are also harder to follow with the eye.
In order to model the effect of inertia and smoothen the animation the initial state blending (11) is changed by performing a
non-linear transformation $g$, called easing function, around the advancement product $t s$:

$
  overline(x) = (1 - g(t s)) dot x_c + g(t s) dot x_t; quad x_c, x_t in [mu_l, mu_u]
$

This transformation introduces non-linear qualities to the animation state resulting in non-uniform speed of the animation.
A classical formula for this is the cubic ease-in-out polynomial:

$
  g(t) = 3t^2 - 2t^3
$

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
      lq.plot(xs, ys_cubic, mark: none, stroke: 1pt + blue, label: [cubic polynomial]), 
      lq.plot(xs, ys_quint, mark: none, stroke: 1pt + teal, label: [quintic polynomial])
    )
  ],
  caption: [Different interpolation functions.]
) <fig:interplation-functions>


By using (12) to compute the animation state, the resulting action looks smoother and more natural.
Easing functions of higher degree may be used to model higher inertia such as the quintic ease
introducing higher computational complexity. Other common easing functions can be found
#link("https://easings.net/")[here]. Cubic ease-in-out provides the best tradeoff between smooth
transition and computational overhead.

=== Publish-Subscribe event model

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
  caption: [Classdiagram of event model.]
)

== Solving calculations

== Programmable application interface
