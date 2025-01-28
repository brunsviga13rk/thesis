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
