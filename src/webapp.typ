// LTeX: language=en-US

#import "requirements.typ": *

= Application <section:visualisation>

A 3d model is of not much use without others being able to properly explore
the geometry, pull the levers and check out its functionality. Ideally, it shall
be as easy as possible for people to open and handle a simulation of the model.
In order to achieve maximum accessibility and ease of use the simulation is to be
run in a web based environment which enables all kinds of devices such as
desktop computes, laptops and mobile devices to use their built-in capabilities
to access the application through web browsers.
Content of this chapter is focused on the technical description rather than
the design. Coverage of the user interface design process and development
are not considered to be in scope of this project.

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
As stated in @section:visualisation a soft goal of the project is easy accessibility
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
The foundation of web applications is built upon @HTML, JavaScript and @CSS.
@HTML describes the scaffolding of a website by telling the web browser about
individual components @mdn_HTML. Through @CSS a webpage's components are styled
and animated. Interactive logic through buttons, events or timers is achieved most
commonly though JavaScript, a dynamically typed programming language that runs
in most modern browsers. @HTML is linked to scripting languages through an in memory
tree of nodes called @DOM @mdn_DOM. With these building blocks the described application
could be built. However, the direct usage of @HTML in conjunction with
JavaScript is cumbersome for larger and more complicated projects such as this
one. Additional resources must either be included locally by storing them
in the repository or loading them on the client side from a third party @CDN.
The lather option is not applicable since the project is supposed to be
offline ready. Including dependency sources directly inside the repository
is not preferable either as versioning is tedious and ambiguous at best.
In order to simplify dependency management and allow for quick creation
of complex user interfaces the project won't directly rely on the primitive
base stack of technologies mentioned above but rather the following compilation
of tools and frameworks described more in-depth in the following chapters:

- Package and dependency manager (@section:npm)
- Build system (@section:vite)
- Component based user interface framework (@section:react)
- Library of user interface components (@section:mui)
- Framework for @3D rendering (@section:three)

==== Package manager <section:npm>

#wrap-content(
  align: right,
  box(
    figure(
      box(
        image("res/npm.svg", height: 4em),
        inset: (bottom: 1em),
      ),
      caption: [ NPM icon @NPM_Icon ],
    ),
    inset: (top: 0.5em, bottom: 0.15em, right: 0.5em),
  ),
  [
    @NPM was created in 2009 in order to help developers share packages of
    JavaScript. @NPM is the command line interface allowing to install
    packages of software from the public registry hosted at
    #link("https://www.npmjs.com", "npmjs.com") @AboutNPM_2025.
    As of 2022 the registry contains more than 2.1 million packages.
    For package and dependency management @NPM writes installed packages
    with alongside their version into a file named `package.json`. The exact
    layout of the created dependency tree is stored in a file called
    `package-lock.json` which can be used to reproduce a working environment
    on different hosts. A command line interface allows for quick and
    easy operations such as installation, cleaning or optimization of
    locally installed packages @IntroductionToNPM_2025.
  ],
)

==== Build system <section:vite>

#wrap-content(
  align: left,
  box(
    figure(
      box(
        image("res/vite.svg", height: 4em),
        inset: (bottom: 1em),
      ),
      caption: [ Vite icon @Vite_Icon ],
    ),
    inset: (top: 0.5em, bottom: 0.15em, right: 0.5em),
  ),
  [
    #link("https://vite.dev/", "Vite") is a build system created in 2020
    aimed at fast and efficient building of client side web
    applications and server backends in JavaScript. Additionally, Vite is
    capable of transpiling Typescript and @JSX to @ESM @ViteFeatures_2025.
    This proves to be a specifically usefull feature as Vite allows to
    bootstrap projects by templates allowing to build web applications
    with languages such as Typescript instead of JavaScript and handeling
    imports of various other technologies such as Web Assembly.
    The process of transpilation servers to @ESM servers several reasons,
    the primary being able to bundle software to neat packages of high
    client compatability. For this purpose Vite generates @ESM as output,
    which is not only standardized by the @ECMA but also widely
    supported by most web browsers with a market share above 2 % @Hayes_1997.
  ],
)

==== User interface <section:react>

#wrap-content(
  align: right,
  box(
    figure(
      box(
        image("res/react.svg", height: 4em),
        inset: (bottom: 1em),
      ),
      caption: [ React icon @React_Icon ],
    ),
    inset: (top: 0.5em, bottom: 0.15em, right: 0.5em),
  ),
  [
    Instead of having to write raw @HTML or manually modifying the @DOM directly
    through JavaScript, React allows to create user interfaces by piecing together
    inidividual components. React automatically handles state for components
    by rendering component affected by change when required. While components
    are formost written in JavaScript or Typescript
    a components @DOM can be modelled by embedding @HTML tags into the source of
    the of the scripting language through a syntax extension referred to as @JSX.
    Variables declared in Type- or JavaScript
    can be used in the @JSX markup in order to render dynamic component state
    by escaping code blocks from @JSX back to Type- or JavaScript inside
    @HTML tags. @ReactHome_2025
    Hooks offer a way of storing state between component renders
    an even complete component reloads for persistent data. Such proof useful
    when writing custom JavaScript not meant to be altered by subsequent reloads
    of components suited for managing a global state. Custom hooks may be
    written in order to modularize acquisition of processed data such as
    theming.
  ],
)

==== Material design components <section:mui>

#wrap-content(
  box(
    figure(
      box(
        image("res/mui.svg", height: 4em),
        inset: (bottom: 1em),
      ),
      caption: [ MUI icon @MUI_Icon ],
    ),
    inset: (top: 0.5em, bottom: 0.15em, right: 0.5em),
  ),
  [
    Since none of the authors have a background in graphics design the choice
    was made not to implement component animations and styles by hand but to
    rely instead on a third party library. One of the most widely used
    and well proven over the span of a decade is the @MUI component library.
    Several well known companies and instituitons have made use of @MUI such as
    Amazon, Netflix or NASA.
    @MUI bundles React components such as Buttons, Tables and Sliders.
    Its name is derived from Google's Material Design system of which @MUI is
    an indipendent implementation @MUIGitHub_2025. Material design is insipired
    by real world materials. To qoute Google's introduction to material design:
    #quote("Material surfaces reimagine the mediums of paper and ink.").
    The design language of material is used in various frameworks offering
    user interfaces for specific platforms such as Android or cross platform
    solutions such as Flutter and web technologies @MaterialDesign_2025.
  ],
)

==== Computer graphics <section:three>

#wrap-content(
  align: right,
  box(
    figure(
      box(
        image("res/three.svg", height: 4.5em),
        inset: (bottom: 1em),
      ),
      caption: [ Three.js icon @MUI_Icon ],
    ),
    inset: (top: 0.5em, bottom: 0.15em, right: 0.5em),
  ),
  [
    Since an interactive visualization of the machine is to be part of the
    project capabilities for @3D rendering are required. Preferably by
    using native hardware based acceleration through a graphics library.
    For the projects web based architecture native graphics libraries such as
    OpenGL or Vulkan fall short as they cannot be used. Modern day web browsers
    generally implement @WebGL. @WebGL is a wrapper around @OpenGLES2
    implementing low level functions for rendering lines, triangles and making
    use of shader pipelines @mdn_WebGL. The use of @WebGL requires at least
    a @HTML 5 compatible browser @OpenGLES2Reference_2025.
    Three.js, as a library, uses @WebGL in order provide higher level functions
    to draw entire meshes of triangles, create perspective cameras, physically
    based materials and lightning @Three_2025. Using Three allows
    rendering a physically based model of the machine without having to invest
    time and effort into developing said mechanism in a half-baked manner due
    to time constraints.
  ],
)

== Organization

Nearly as important as the technologies used is the applied project management.
The source code of is hosted as GitHub and relies on the Git version control
system. This allows controlled collaboration between multiple contributes
during development. In order to enhance tracking of changes a
specific development workflow is chosen based on Gitflow.
The idea here is to have to most up-to-date version of the software on
the main branch. Working tasks such as bug fixes, new features or any other
are performed in their own separate branch, which on completion is merged into the
main branch. Additionally, conventional commits shall be used to write commit messages.
This strategy used a simple pattern to create readable and formal messages:

#figure(
  raw("<type>[optional scope]: <description>"),
  caption: [Conventional commit message without body.])

Each and every commit starts with a type. This type can be any of: `fix` (bug fix), `feat` (new feature),
`refactor` (change in code but not in behavior) and many more. See specification for an
exhaustive list @ConventionalCommits. A scope may be a software module worked on or general topic.
The type is to be used not only in commit messages but also as initial path element for naming
branches. For example, a new feature branch may be named like the following:
`feat/add-jumping-animation`. Commit descriptions and branch names may only use the presence tense.
Last but not least is the versioning scheme. Semantic versioning is chosen due to its
good integration with conventional commits and wide adoption in the software world.
Helpful automation in the repository is performed by GitHub actions such as `release-please`
which is used to automate the generation of releases. It automatically generates
changelogs and performs version increments from the history of commit messages all
possible by using conventional commits.
On release the current software is built by a custom action and the static files produced by vite
are attached to the current release. The latest version is also deployed to a GitHub page hosted
at: #link("https://brunsviga13rk.github.io/emulator/", "brunsviga13rk.github.io/emulator").

== User interface

The user interface is crafted with @MUI components with classical React
function components in a hierarchy. It is meant to be simple and easy to read,
but also adapt to thinner mobile screens. The basic layout of the interface
follows the golden ratio (blue) as can be seen in @fig:layout.

#figure(image("res/user-interface.svg", width: 80%), caption:  [Scheme of user interface]) <fig:layout>

The idea is to have a title bar at the top of the application showing the logo
of the Brunsviga and giving additional information such as version number or
providing links to the source code or a wiki page. Most space of the page
will be given to the view showing the interactive machine since this is the
highlight of project. On the right side two separate components are stacked
over each other. Below is a tab page for various editors used to run different
programs on the virtual machine. Above is a panel showing the current values
of each of the machines three registers. The component displaying the value
of the input register may even be editable since, the input register can be
mutated through a sprocket wheel either way. On mobile devices the right side
is to slide away giving of its screen real estate to the view of the model.
Optionally these may be brought back into view by clicking a button in the title bar.

== Event loop

One of the most critical part of the application is the event loop.
Implemented as anonymous function, the event loop (@fig:event-loop) is called by the renderer
each time before a frame is rendered (about 60 times per second). Similar to
game development this event loop processes the state of all things related
to rendering. At first, the renderer checks whether it has to resize to
fit its parent container since it does not do so automatically.

#figure(
    diagram(
        node-stroke: 1pt + black,
        edge-stroke: 1pt + black,
        spacing: 2.5em,
        node((1,0), "Engine", name: <engine>),
        node((3,0), "Renderer", name: <renderer>),
        node((4,0), "Brunsviga", name: <brunsviga>),
        node((5,0), "EventHandler", name: <handler>),
        node((1,7), "Engine"),
        node((3,7), "Renderer"),
        node((4,7), "Brunsviga"),
        node((5,7), "EventHandler"),
        edge((1,0), "ddddddd", ".."),
        edge((3,0), "ddddddd", ".."),
        edge((4,0), "ddddddd", ".."),
        edge((5,0), "ddddddd", ".."),
        edge((1, 1), "rr", "-|>", label: "Initialize"),
        edge((3, 2), "ll", "-|>", label: "Event loop"),
        edge((1, 3), "rr", "-|>", label: "Resize", snap-to: (<engine>, <renderer>)),
        edge((3, 3.25), "ll", "..>", snap-to: (<engine>, <renderer>)),
        node(align(top + left, "loop"), inset: 0pt, extrude: 4pt, enclose: ((0.5,2.5), (5.5,6.5))),
        edge((1, 4), "rrrr", "-|>", label: "Actions", snap-to: (<engine>, <brunsviga>)),
        edge((4, 4.5), "r", "->", label: "Emit events", snap-to: (<handler>, <brunsviga>)),
        edge((5, 5.5), "l", "..>", label: "Process events", snap-to: (<handler>, <brunsviga>)),
        edge((4, 6), "lll", "..>", snap-to: (<engine>, <brunsviga>))),
    caption: [Sequence diagram of the event loop.]) <fig:event-loop>

After returning from the renderer the event loop triggers all actions of the Brunsviga.
For now these only perform updates of the animation state which in turn
asynchronously starts to process events. This works similar to a waterfall
effect where a set of fixed actions can trigger a wave of subsequent procedures.
For more information on how events work see @sec:events. For performance
reasons it is important that the event loop runs as smoothly as possible
as any delay in the loop will have stuttering frames and in turn poor rendering
performance as consequence.

== Rendering

Rendering refers to the process of generating imagery from geometric meshes.
It serves as the fundamental approach used to put the generated model to the screen.
For the purpose of rendering in real time, achieving a frame time less than 16 milliseconds,
@WebGL in Three.js relies on rasterization.
Rasterization works by transforming the geometric shapes of a mesh, usually triangles,
from their local space into clip space, where their vertices are represented in pixel coordinates
and can directly be drawn by dropping the z-coordinate and using the $(x,y)$ coordinates.

=== Environment

In order to add realistic illumination to the scene environment maps
find use commonly. These are rectangular image texture of a 360° view of an environment
such a room or landscape stitched together from pictures taken from angles
covering the entire surrounding sphere. The spherical texture data is then projected
onto a flat image with equirectangular mapping similar (but not alike) how the surface of the
earth is commonly projected on mercator maps.

#figure(image("res/studio_smalljpg.jpg", width: 80%), caption: [Environment map of a studio room @StudiosmallZaal.]) <fig:environment-map>

@fig:environment-map shows the environment used in the scene. This particular
environment map is from a source hosting an entire library of environment maps
used in the animation industry and licensed under
#link("https://creativecommons.org/publicdomain/zero/1.0/", "CC0") @StudiosmallZaal.
When the rendering engine computes the incoming light for a point on a surface
all needed to be done is to sample the environment map in the normal direction,
optionally blurring the environment in the same step in order approximate
scattering. This process allows for detailed lightning with very little effort.
@fig:material-showcase was rendered with this exact environment map to make sure
the synthesized materials would match the materials later rendered in real time.
Another special feature of environment map is their format. They are usually not
encoded in @PNG or @JPEG but @HDR. This special file format is able to store much
higher resolution color data. Typically, @HDR has 8 bytes per color channel instead
of 2 bytes like @PNG or @JPEG. Such high resolution in color depth allows representing
much greater dynamic range of colors @OpenEXR. 

#figure(image("res/hdri-dynamic-range-big-3089469445.jpg", width: 70%), caption: [Dynamic range of two pictures @HDRIAversis.]) <fig:dynamic-range>

@fig:dynamic-range shows the effect high dynamic range has on a picture.
Storing high resolution color data allows much greater freedom in adjusting contrast
and brightness. This high resolution color data is captured by shooting the same
picture at different exposure levels (stop) and combining them later in post-processing
by merging their color data scaled by the exposure they were shot at.
Due to this process @HDR environment maps are able to capture both dark shadows
and bright light sources without clipping to black or white like lower
resolution color formats do.

#pagebreak()

=== Passes <sec:passes>

Rendering is not as straight forward as drawing and coloring the polygons
on the canvas. The raw rendered image makes it hard to know which parts
can be interacted with. For this purpose the Three library used for rendering
supports post-processing filters which can be chained together to form
multi pass rendering pipelines @Three_Postprocessing.
At the first stage a `RenderPass` is used to draw the model with its surface
shaders and environment lightning to a frame buffer. This step also
stores some additional depth data used in the second step, where an outline
pass draws a white border for a handpicked selection of objects which
are decided upon whether the mouse cursor hovers over them or not.
Several other improvements can be made at this stage too.
The borders drawn by the outline pass have hard edges and appear blocky
on slopes. A quick fix for this is to apply antialiasing at the very end of
the rendering pipeline. For this purpose a @FXAA shader is run by a shader pass
on the frame buffer previously written to by the outline pass.
This small addition helps to reduce visual quirks with the final image.
However, the @FXAA algorithm falls short in several cases where the machine
itself produces hard edges with artifacts. Sometimes these do not get filtered
properly by @FXAA leaving the viewer with a rather unpleasant image.
Antialiasing of the model can be computed quite cheaply by swapping the `RenderPass`
at the beginning with a special render pass performing @TAA.
@TAA works by averaging samples of rendered image over the temporal domain, that is time.
This results, much like multi sampling in smoother images over time.
Images have only a small influence over time to prevent ghosting, that is seeing
blurry version of objects that once were in view but have since moved onward.

#figure(
  [
    #diagram(
    node-stroke: 1pt + black,
    edge-stroke: 1pt + black,
    node-corner-radius: 0.5em,
    spacing: 1em,
    node((2,0), shape: rect, "Render"),
    node((4,0), shape: rect, "TAA"),
    node((0,2), "Outline"),
    node((2,2), "FXAA"),
    node((4,2), "Output"),
    edge((2,0), (4,0), "->"),
    edge((4,0), "r,d,llllll,d,r", "->"),
    edge((2,2), (4,2), "->"),
    edge((0,2), (2,2), "->")
  )
  #v(1em)
  ], caption: [Sequence of render passes.])

The output pass additionally transforms the linear color space rendered in to sRGB
with tone mapping in order to produce accurate display output @Three_Postprocessing.

#pagebreak()

The final composed Brunsvgia model can be seen in @fig:output-comparison.
On the left side is a picture taken of the physical machine. In the middle is the
finalized digital model rendered with path tracing by Cycles in Blender.
On the right side is the same model rendered in real time in @WebGL.
The most similarity is between the path traced model and the real picture.
This is due to the fact, that path tracing simulates actual rays of light by bouncing
them around and approximating the rendering equation by quasi monte carlo methods.
This procedure is computationally expensive and rendering at 1080p took about
four minutes for 512 samples per pixel.

#figure(
    grid(columns: (1fr, 1fr, 1fr), image("res/machine.jpg", width: 100%), image("res/model-showcase.png", width: 95%), image("res/Screenshot_20250415_000140.png", width: 95%)),
    caption: [Picture (right), path trace (middle), web (right).]) <fig:output-comparison>

@WebGL renders its model at 60 frames per second, over 15000 times faster.
This of course, has the drawback of significantly reducing visual quality.
The most obvious lack is the absence of shadows or ambient occlusion
from the real time render. A possible road to improvement would
be to fake ambient occlusion by adding a screen space based approach
in post-processing. Modern games often rely on ambient occlusion approximations.
Screen space based approaches can even be taken to far as to simulate
bounces of global illumination @SSDO.
Several implementations of @SSAO are available to use, some of them built into
Three.js itself. For unknown reasons these @SSAO filters seem to work mutually
exclusive to the outline pass meaning a decision between outlines and @SSAO
needs to be made. Due to time constraint no satisfying solution was found
in time. Outlines are considered more important as they add more value to the
user experience than @SSAO adds to visual quality.
It remains to explore further possibilities or fixes for adding more advanced
illumination techniques to the view.
