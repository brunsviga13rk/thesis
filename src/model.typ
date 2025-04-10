// LTeX: language=en-US

#import "requirements.typ": *
#import "@preview/lilaq:0.2.0" as lq
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge
#import fletcher.shapes: rect

= Simulation

== Event driven animations

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

=== State blending

#figure(
  [
    #let xs = lq.linspace(0, 1)
    #let ys_lin = xs.map((x) => x)
    #let ys_cubic = xs.map((x) => 3 * x * x - 2 * x * x * x)

    #lq.diagram(
      width: 10cm,
      height: 5cm,
      xlabel: $x$, 
      ylabel: $y$,
      legend: (position: left + top),
      margin: 10%,
      lq.plot(xs, ys_lin, mark: none, stroke: 1pt + blue, label: text(weight: "regular", [linear])), 
      lq.plot(xs, ys_cubic, mark: none, stroke: 1pt + orange, label: [cubic polynomial]), 
    )
  ],
  caption: [Different interpolation functions.]
)