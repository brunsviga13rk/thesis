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
                inset: (bottom: 1em)),
            caption: [ NPM icon @NPM_Icon ]),
        inset: (top: 0.5em, bottom: 0.15em, right: 0.5em)),
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
    ]
)

==== Build system <section:vite>

#wrap-content(
    align: left,
    box(
        figure(
            box(
                image("res/vite.svg", height: 4em),
                inset: (bottom: 1em)),
            caption: [ Vite icon @Vite_Icon ]),
        inset: (top: 0.5em, bottom: 0.15em, right: 0.5em)),
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
    ]
)

==== User interface <section:react>

#wrap-content(
    align: right,
    box(
        figure(
            box(
                image("res/react.svg", height: 4em),
                inset: (bottom: 1em)),
            caption: [ React icon @React_Icon ]),
        inset: (top: 0.5em, bottom: 0.15em, right: 0.5em)),
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
    ]
)

==== Material design components <section:mui>

#wrap-content(
    box(
        figure(
            box(
                image("res/mui.svg", height: 4em),
                inset: (bottom: 1em)),
            caption: [ MUI icon @MUI_Icon ]),
        inset: (top: 0.5em, bottom: 0.15em, right: 0.5em)),
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
    ]
)

==== Computer graphics <section:three>

#wrap-content(
    align: right,
    box(
        figure(
            box(
                image("res/three.svg", height: 4.5em),
                inset: (bottom: 1em)),
            caption: [ Three.js icon @MUI_Icon ]),
        inset: (top: 0.5em, bottom: 0.15em, right: 0.5em)),
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
        based materials and lightning @Three_2025. Using Three allows+
        rendering a physically based model of the machine without having to invest
        time and effort into developing said mechanism in a half-baked manner due
        to time constraints.
    ]
)
