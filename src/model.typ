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
], caption: [Overrun condition not met for $h$ when animating between $x_c$ and $x_t$.]) <fig:overrun-false>

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

== Programmable application interface
