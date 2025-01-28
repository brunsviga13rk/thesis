// LTeX: language=en-US

#import "requirements.typ": *

= Digital twin

At the core of this entire project is the simulation of a real-world physical
object. Mechanical machinery is best understood when viewed through animations
showing each step of process. Multiplication on the Brunsviga for example is
generally a multistep procedure. Having a model to virtually orbit around
benefits understanding. For the purpose of rendering the calculator on a
computer screen, a digital recreation of the calculating machine is required.
This 3d model will be referred to as "digital twin" a term used in by the
automation industry to monitor, test and verify various parts of factories
such as assembly lines by estimating said factors through a virtual simulation.
Although the use case diverges from those of the major
industries, as this project does not center around any of the more commonly used
goals of data analysis, cost estimation. Additionally, both physical and the digital
twins are not linked by sensor data or a network connection since the object of
interest is a purely analog computing device. This digital twin is used entirely
for educational purposes in order to deepen and preserve the understanding of the
history of calculators as they were used decades ago.

== Reference data

In order to accurately recreate the calculator details of the physical model
are mandatory. This data will from here on now be referred to as reference data.
At first glance there are two branches of reference data usable for modelling:
measurements and pictures. Measurements provides length and angle values with
a relative precision of millimeters allowing
for a detailed description of shapes. Measurements are taken with calipers
allowing for precision of up to 100 μm. However, a precision error
of ±0.5 cm is more realistic for certain measurements especially for those on
angled edges with rounded corners where deciding on fixed locations for
measurements are for one challenging to hit precisely and secondly hard to
pinpoint exactly in pictures or technical drawing for reference.
For simple convex shapes such as
circles and boxes this method of description allows for precise recreations.
However, the amount of measurements required in combination with varying
precisions due to real world errors make it hard to describe complex non-convex
shapes such as gears, springs or parts of the hull. In order to simplify
both individual shapes and reduce the amount of measurements pictures can be
used to visually trace lines and approximate proportions.
See appendix for a table of measurements taken from the real world machine.
// TODO: add table of measurements

== Modelling and representation

After covering decent data of reference a technique for modelling the digital twin
is required. Several ways exist to represent three-dimensional objects.
In general complex non-convex objects are split into a multitude of simpler
objects and grouped together to achieve higher complexity. These "simpler" objects
will be referred here as "atomic shapes" as these are the foundational building
blocks of modelling. Atomic shapes cannot have an arbitrary shape but may be
customized by a set of keys. The simplest form of such an atomic shape is a
triangle represented by three keys, one for each vertex. Besides stitching
triangles together to build surfaces as is traditionally done in computer
graphics by rasterization atomic shapes can also be defined implicitly through
equations. Examples for such techniques include function computing
signed distance fields, Bézier curves or solving for line object intersections
analytically for use in ray tracing. These methods allow to mathematically
describe curvature with much higher precision than triangular approximations.
Since the real world machine in everything but perfect analytical approaches
provide too much overhead and complexity for modelling. Curves are traditionally
limited in usage in modelling software without generating triangle meshes halfway
through. Additionally, curves are a better fit for flat, two-dimensional shape
modelling rather than non-convex three-dimensional objects.
For such reasons such as the simplicity of triangle meshes these have long become
the defacto-standard for modelling software.
Polygonal modelling refers to the process of approximating a model with a
composition of polygons which are eventually split down into triangles for
ease of rendering.

== Polygonal modelling

Due to the wide-spread use of rasterization pipelines, which
are primarily designed for triangle meshes, polygonal modelling is the choice
of favor for this project.
Various software exists allowing for polygonal modelling. Blender is the
preferred software as it is well established, free and open-source and is freely
available on multiple platforms.
The basic modelling process of polygonal modelling in Blender involves several
steps. The Brunsviga 13 RK is split into different parts. Each part is a
physically solid component.These components are treated for modelling as
independent objects ignoring mechanical joints at first. The decision process
for start and end of each component is strictly based on the disassembly of the
Brunsviga 13 RK. Each piece taken off as a hole during disassembly is modelled
as a single component. As such the hull is split into different metal plates
with the screws being dedicated components. Each component is modelled the same
way. Pictures taken orthogonally to the surface of the component to be modelled
are projected into the background. The exact procedure of modelling can be
divided into two distinct processes for convex prisms and cylindrical shapes.

=== Convex prisms

In front of the background reference image poly lines are traced around
the components edges by extrusion. Rounded corners are first traced as sharp
turns and afterward smoothed out by manually by use of the bevel tool.
The two resulting ends of the poly line are joined together at a point of
low curvature, preferably a straight line. It is important to only modify the
points of the polyline in the x- and y-axis in order achieve a "flat" polyline
that can be filled in without creating any depth.
Filling in the polyline forms a flat polygonal surface. This surface forms the
base of the prism. By selection of the edges of the base surface
the prism walls are generated by extruding the edges alongside the direction
where the depth of the object increases orthogonal to the base surface.

// TODO: show example of hull modelling

=== Cylindrical shapes

A different modelling process applies for cylindrical objects such as the crank
handle. Blender provides cylinder poly meshes out-of-box. By transforming
the length and radius of a cylinder the base shape for components such as the
operation crank is finished. The downwards metal extrusion of the operation
crank is modelled by extruding the base of cylinder alongside the length by
the thickness of the metal extrusion. Any face of the newly generated cylinder
segment which face downwards are selected and extruded downwards, forming the
metal extrusion.

// TODO: show example of crank modelling
