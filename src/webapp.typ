// LTeX: language=en-US

#import "requirements.typ": *

= Simulation <section:simulation>

A 3d model is of not much use without others being able to properly explore
the geometry, pull the levers and check out its functionality. Ideally, it shall
be as easy as possible for people to open and handle a simulation of the model.
In order to achieve maximum accessibility and ease of use the simulation is to be
run in a web based environment which enables all kinds of devices such as
desktop computes, laptops and mobile devices to use their built-in capabilities
to access the application through web browsers.

== Overall goals

The design and development of this web application is discussed in this chapter.
In order to explain the decision-making for choosing the core technologies used
on the creation of the web application core features of the application
are outlined:

1. Interactive 3d model of the calculator
2. Generate steps required to solve a user given calculation
3. Scriptable algorithms making use of the calculators analog user interface
4. Provide text based access to sprocket wheel values

The primary goal (1) was to serve the user an intractable 3d model of the machine.
Besides being able to look around the machine in a virtual space the digital
twin as described in @section:digital_twin shall implement all functionalities
the physical machine is capable of from a users' perspective such as
pulling levers and configuring the input sprocket. This allows the user
to operate the digital twin as would a real human do so with the physical machine
only by interacting with the web application.
Since not every user can be expected to have a decent understanding of the machine
and its modes of operation, a generator with the capability to produce all
steps required in order to solve a calculation correctly with the machine
would allow to interactively learn the machine's usage (2).
Extending the programmatic interface of the simulation can be done by allowing
users to code custom algorithms in a proper programming language (3). This requires
an abstraction of the calculators physical interface of levers and sprockets
to procedures and functions. This feature allows the implementation and quick testing
of more advanced algorithms for logarithms, square roots and trigonometric functions
on the calculator without having to hassle with the analog sample.
As a last overall goal which is to an extent am requirement of the previous goal 3
is the ability to retrieve the machines sprocket wheel values in a text based form
allowing for copy and paste functionality.

== Software architecture

After outlining the overall goals of the web application necessary technologies
and development strategies can be discussed.
As stated in @section:simulation a soft goal of the project is easy accessibility
of the application. Prominently web technologies have been proven to work well
in this field as they typically do not require special dependencies natively
installed other than a web browser with most operating systems having one
preinstalled by default. Additionally, this allows to deploy the application
on a publically accessible server. This dissolves any need to build and compile
the project by any user or download prebuild binaries. In case there are
third party dependencies these may be supplied by a @CDN and automatically downloaded,
although in order to maintain reproducibility and allow for fully functional offline
availability the usage of a @CDN shall be discouraged and avoided for this project.

=== Choice of languages and frameworks

The world of the web is one of the most diverse landscapes in software with a
wide variety of frameworks, libraries and languages.
The foundation of web applications is built upon @HTML, Javascript and @CSS.
@HTML describes the scaffolding of a website by telling the web browser about
individual components @mdn_HTML. Through @CSS a webpage's components are styled
and animated. Interactive logic through buttons, events or timers is achieved most
commonly though Javascript, a dynamically typed programming language that runs
in most modern browsers. With these building blocks the described application
could be built. However, the direct usage of @HTML in conjunction with
Javascript is cumbersome for larger and more compliacted projects such as this
one. Additional resources must either be included locally by storing them
in the repository or loading them on the client side from a third party @CDN.
The lather option is not applicable since the project is supposed to be
offline ready. Including dependency sources directly inside the repository
is not preferable either as versioning is tedious and ambiguous at best.
In order to simplify dependency management and allow for quick creation
of complex user interfaces the project won't directly rely on the primitive
base stack of technologies mentioned above but rather the following compilation
of tools and frameworks:
