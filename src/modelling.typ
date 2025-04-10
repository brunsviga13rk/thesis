// LTeX: language=en-US

#import "requirements.typ": *

= Digital twin <section:digital_twin>

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

== Optimization of reference images

As can be seen on the leftmost image in @figure:reference-image-enhancement,
the raw images taken by camera as reference are rather poor in quality.
The image quality suffers from several factors. First of is the lightning.
Due to the lack of intense but soft indirect illumination obvious shadows were
cast from side. Those could have been avoided by letting the lights shine from
behind the camera. However, this does result in intense reflection in the glossy
metallic parts of the machine. Having soft penumbra shadows is the lesser evil
in this case. Better image quality can be achieved in post-processing by following
a straight forward pipeline.

=== Noise and color enhancements

The first optimization is to get rid of all the redundant
space around the machine. For this purpose the original image (first from the left)
is cropped to the minimum size where everything of the machine is still visible
(second from the left).

#figure(
  box(
    grid(
      rows: 1,
      columns: (1fr, 1fr, 1fr, 1fr),
      image("res/original.jpg", height: 80pt),
      image("res/cropped.jpg", height: 80pt),
      image("res/masked.jpg", height: 80pt),
      image("res/color_correction.jpg", height: 80pt),
    ),
    inset: (bottom: 12pt),
  ),
  caption: "Enhancement steps of a reference image.",
) <figure:reference-image-enhancement>

The background wall of the environment adds no value to the actual machine in question
and is to be regarded as unnecessary noise. In order to remove the background
and retain only the machine the machines outline is traced as a selection. This
selection mask is then inverted selecting every pixel but those contributing to
the machine. The selected pixels are then replaced with a solid white color
(second image from the right). Additionally, areas of low dark lightness can
be brightened up to reveal otherwise hidden detail.

=== Perspective correction

Another point of concern is perspective distortion. Digital cameras see, much
like humans, only in perspective meaning objects farther away appear smaller
and parallel lines become skewed. Even when taking a picture perfectly orthogonal
to the machine, parts near the edges of the image fall victim to distortion.
In some cases this distortion can be corrected manually. @picture:perspective-correction
shows an example where the red handle (on the right side) is not viewed from
a perfectly orthogonal angle thus resulting a skewed perspective revealing sides
of the object that should ideally be occluded.

#figure(
  box(
    image("res/perspective_correction.jpg", width: 100%),
    inset: (bottom: 12pt),
  ),
  caption: "Example of perspective correction for a lever handle.",
) <picture:perspective-correction>

AS can be seen on the left side, this can be fixed by moving the face of the handle
facing the camera face forward slightly down. This results in holes in the image
where the face occluded the metallic lever. These can be filled up by either
manually copying and blending from known and symmetrical parts of the image or
through the use "smart patch" tools commonly found in software like Photoshop,
Krita or Gimp. While editing the reference images a combination of both tools
were found to strike a good balance between high accuracy and quick editing.
Using "smart patch" tools for areas with low discrepancy Gaussian-like noise
not containing sharp edges is limiting the amount of manual copy and past work
by good deal. Areas of high contrast of sharp edges however require manual
intervention in most cases, as "smart patching" tools often rely on a combination
of blending together parts of the surroundings resulting in a blurry mess of
inconsistent patches.

=== Removal of defects

The machine acquired for this project is multiple decades old and has been used
fair while. This results in defects from regular touching, scratches or
in extreme cases by parts rubbing the paint from each other. Two examples
of defects are shown in @picture:decal-correction on the left side.

#figure(
  image("res/decal_correction.jpg", width: 65%),
  caption: "Two examples of digital damage removal.",
) <picture:decal-correction>

In the top left image the continuous usage of one of the levers resulted in it being
bent towards the hull of the machine, scratching its surface each time it is moved.
In order to remove these defects from the image a method similar to the one
used above can be used. By copying and blending parts of the image where an intact
surface is still present, the defects can be over painted with negligible
artifacts persisting. These artifacts mostly manifest themselves as very low
frequency noise over the patched up defects. Some of the patched areas might
appear blurry which is due to the blending operation taking place. This
blurry mess can be reduced by reducing the smoothed out border of the brush
being used to achieve the blending operation. Another possible solution would
be to add Gaussian noise on top of blurry areas to recreate digital image
artifacts at high frequency. This is not considered necessary as the removal
of artifacts only serves the purpose of having a more concise image of reference
with less distracting special elements.

=== Shadow elimination

Another distraction are shadows and highlights. These can be removed or at
least softened by applying the same tricks as previously. However, as can
be seen in @picture:shadow-elimination soft shadows make a fairly large part
of the image. Removing them from the image will result in much more obvious
low frequency noise as the over painted area is much larger than previously.

#figure(
  box(
    image("res/deshade.jpg", width: 100%),
    inset: (bottom: 12pt),
  ),
  caption: "Example of shadow removal.",
) <picture:shadow-elimination>

After the removal of the shadows (right image) the lever is put much more
to the foreground making its contours more clear. Shadows and highlight are
not removed from edges were they help to outline the geometry. In such cases
having detailed shading is of advantage as rounded corners look are clearly
different from sharp corners or flat surfaces. Shading due to shiny metal surfaces
remains untouched as this proves to be too difficult to generate decent results.
Since metals have little to no diffuse components all can be seen are tinted
reflections. Extracting the base tint of metallic surface is too difficult and
unviable for this project as the dark reflection of the environment is sufficient
in distinguishing between the rough diffuse finish of the hull and bare metallic
geometry. A brighter background when tacking the photographs might still have
yielded better results as the reflections would have been brighter as a consequence.
This increased brightness might have also helped to reduce the contrast between
rougher areas of the metal which are a result of scratches and oxidization.

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

== Polygonal modelling <section:modelling>

Due to the wide-spread use of rasterization pipelines, which
are primarily designed for triangle meshes, polygonal modelling is the choice
of favor for this project.
Various software exists allowing for polygonal modelling. Blender is the
preferred software as it is well established, free and open-source and is freely
available on multiple platforms.
The basic modelling process of polygonal modelling in Blender involves several
steps. The Brunsviga 13 RK is split into different parts. Each part is a
physically solid component. These components are treated for modelling as
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
turns and afterward smoothed out by manually by use of the bevel tool. @BlenderManual_Bevel
The two resulting ends of the poly line are joined together at a point of
low curvature, preferably a straight line. It is important to only modify the
points of the polyline in the x- and y-axis in order achieve a "flat" polyline
that can be filled in without creating any depth.
Filling in the polyline forms a flat polygonal surface. This surface forms the
base of the prism. By selection of the edges of the base surface
the prism walls are generated by extruding the edges alongside the direction
where the depth of the object increases orthogonal to the base surface.

#figure(
  image("res/polymodel_convex_prism.png", width: 80%),
  caption: "Polymodelling of the outer hull of the machine.",
) <picture:convex-prism-modelling>

@picture:convex-prism-modelling shows the low poly model
of the outer hull of the machine after extrusion. The orange colored face is one
of two bases of the prism base shape.

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

== Modelling tricks

The models created through the previous steps are low poly by nature thus having
sharp edges or hard transitions. In order to fix such issues previous
procedures made use of the bevel operator by manually rounding edges of faces.
This method has its limitations in cases where edge vertices are connected by
a multitude of faces. In such cases the bevel that can be applied by the operator
is severely limited by the distance the bevel can apply without overlapping.
A workaround to this problem is to move edges of faces further apart stretching
specific parts of a model. Such transformation is undesirable in most cases.
Additionally, all previous operations have taken place in edit mode meaning
each operation applies changes to the vertices of the object directly.
This behavior is referred to as "destructive" as it "destroys" the previous
geometry by permanently altering it. Modifiers offer a non-destructive alternative
to permanent geometry altercations. They perform a specific operation on the mesh
without changing the geometry of the object rather applies the changes only visually
for rendering. This way the geometry can be changed and operations are applied
automatically in post. @BlenderManual_Modifier

=== Repetition

In order to reduce the effort of having to model the same objects multiple
times or copying a single instance by hand multiple times in cases such as the
rotors of sprocket wheels, the array modifier is made use of.
This modifier is applied to a single instance of an object to be repeated
multiple times alongside a linear axis in homogenous distances. This technique
is primarily used to create the rotors of all sprocket wheels.

=== Catmull-Clark subdivision surface

In order to smooth an object in its entirety and retaining the original geometry
for fine-tuning later, a subdivision surface modifier is used. @BlenderManual_Subdiv
This modifier splits each face of the model into smaller faces and generates additional
vertices at position based on the average of neighboring vertices thus smoothing
the resulting geometry. The described method can be applied incrementally in
several iterations to smooth out a surface event further. @Cheng_2008

#figure(
  image("res/subdiv.png", width: 80%),
  caption: [Example of converging subdivisions on a polygon mesh @Subdiv_Icon.],
) <picture:subdiv>

Sharp edges can be created by creating extra edges alongside the edge to be
sharpened. By closing the distance between the additional edge and the target
edge the rounding of the edge created by the subdivision surface becomes
thinner, resulting in a sharper looking edge.

== Texturing

Until now, the model produced by the previous chapter has no actual color information
associated to it, thus it rendered with the default material which is likely a
single solid color. Not very realistic. This can be improved upon by texturing.

=== Texture mapping

Texturing is the process of mapping a two-dimensional image (texture) onto the
surface an object (mostly polygon meshes) by transforming the three-dimensional
coordinates of the mesh to the two-dimensional texture space through a
UV map also referred to as UV-mapping @Radivojevic_2025. A common visualization
of this process is by unfolding the faces of cube along several seams to a flat
surface like in @figure:uvcube.

#figure(
    image("res/uvcube.png", width: 60%),
    caption: [Unfolding a unit cubes faces to a flat plane.]
) <figure:uvcube>

UV-maps associates a texture coordinate $(u, v)$ with every vertex of a mesh,
generally as a dedicated attribute. When rendering the mesh, the interpolated
texture coordinate of the currently processed triangle is used to fetch an image's
texel an output its color. General goals for a decent UV-map involves reducing
the stretch that occurs when projecting a curved surface into the flat texture
space. Additionally, a UV-coordinate may not overflow a textures coordinate space
which is limited on each of its two axis to the interval $[0,1]$. This is not
a technical constraint as most texture sampling procedures can either clamp,
extend or repeat the texture when overflowing coordinates. For the purpose
of mapping an entire objects surface onto a single texture without any overflow,
such is here, the space has to be packed tightly in order to minimize waste of
space. Usage of texture real estate is especially important since the texture
that is mapped onto has a finite resolution. Mapped faces that are smaller than
a pixel of the raster image mapped onto, the face will only have a single color.
In order to avoid this, all faces should take up the most amount of space without
reducing all others to an unreasonable size. Such ratio cannot be expressed easily
in a deterministic manner for each and all surfaces. UV-mapping is always a tradeoff
between stretched textures, wasted texture pixels and low texture resolution per
face. The Brunsviga Model mostly suffers from the latter. This is due to the high
complexity of the model making unwrapping a time-consuming trial-and-error process.
Additionally, the high surface area of the model, due to its many moving and mechanical
parts, makes the UV-map consume a lot of the texture space. Stretching is not
much of a problem as simple prisms shapes can be UV-mapped without great issues.
The estimated texture stretch per face can be seen in @figure:uvmap.
"Stretch" refers to the difference between the UV space and the world space @BlenderManual_UV.
By assuming a mesh being represented by triangle strips the aerial stretch can
be computed by the difference in the normalized edge lengths (1). $v_i$ is the
i-th vertex in the vertex attribute array of mesh $v$. A vertex is assumed here
to be a vector in Euclidean space for both the world space mesh ($v_"base"$) and
the projected unwrapped mesh ($v_"unwrapped"$).

$
    "length"(v) = norm((abs(v_0 - v_1), abs(v_i-1 - v_i), dots, abs(v_n-1 - v_n) )^T) \
    "stretch"(v_("unwrapped"), v_("base")) = abs("length"(v_("base")) - "length"(v_("unwrapped")))
$

The angular stretch is more tricky to calculate. A simplified solution might be to
define the angular stretch as the maximum difference of all the angles between
each edge of the area. An example equation to achieve this is given in (2).

$
    "angle"(v, i) = cos^(-1)( frac((v_i - v_(i+1)) dot (v_(i+1 )- v_(i+2)), abs(v_i - v_(i+1)) abs(v_(i+1) - v_(i+2))  ) ) \
    "stretch"(v_"unwrapped", v_"base") = max ["angle"(v_"unwrapped", i) - "angle"(v_"base", i)]; forall i in [0,n-2]
$

The maximum stretch (rendered as red) would in this case amount to a maximum
angle difference of 180°.
However, the actual implementation would need to handle non-convex polygons with
any amount of vertices and order.
Pixels in between edges and vertices on the UV-map interpolate linearly between
the stretch values of each vertex or edge. This may be achieved in this sample
case through barycentric coordinates.
The given equations do however provide a decent
sample implementation for computing stretching.

#figure(
    box(inset: (bottom: 0.5em),
        grid(columns: (1fr, 1fr, 7em),
            image("res/uv-angular-stretch.png", height: 11em),
            image("res/uv-arial-stretch.png", height: 11em),
            image("res/scala.svg", height: 11em))
    ),
    caption: [UV-map of the Brunsviga model with estimated angle and area stretch.]
) <figure:uvmap>

As can be seen in @figure:uvmap, the current implementation of the UV-map has low angular stretch
per face (left image). However, the area stretch is quite high. This means, that
the UV-map more accurately represents the angles of the mesh rather than the area
of each face. The surface is stretched on purpose since this allows the projected
area to make high usage of the textures pixels. Some of the objects faces,
especially those having digits printed onto them, suffer from blurry results as
the unwrapping process makes the area to small of digits to be rendered by
enough pixels in order to look sharp. This is circumvented by individually
deciding for the unwrapping method for troubled areas. This manual process
however leads to a waste of space as packing faces by hand is not nearly as
efficient as doing so automatically. Due to time constraints this UV-map
is considered to be an acceptable result. Shortcomings in the UV-map can be
counteracted on by increasing texture resolution. Initially a texture resolution
$1024 times 1024$ (1k) was aimed at. After reconsidering due to the immense amount
of surface area the texture has to cover the resolution for the image texture
has been increased to $4096 times 4096$ (4k) and has even been tested at
$8192 times 8192$ (8k). As stated in later chapters a size of 4k proves to be
favorable due to size and performance constraints.

== Physically based rendering <section:shading>

@PBR refers to techniques using statistical models grounded in physical principles
in order to add realism to computer generated imagery @Moneimne2025. Materials
define how a scene's lights interact with objects and determine pixel color
for the viewing camera. Basic physically based material properties can be derived
from the famous rendering equation (@equation:rendering-equation) described by Kajiya
in 1986 @Kajiya1986.

$
    I(x, x') = g(x, x') [
        epsilon(x, x')
        + integral_S rho(x, x', x'') I(x', x'')
        delta x''
    ]
$ <equation:rendering-equation>

This equation models the light intensity passing from a point $x'$ to $x$.
The first factor of the product $g(x, x')$ is a "geometric" term representing
the occlusion of two points. A result of $0$ equating of a mutual occlusion
of both points. In case both points can see each other the term resolves to
$frac(1, r^2)$ where $r$ is the Euclidean norm of the difference between $x$
and $x'$. The geometric term masks the total intensity of light computed
by the second factor. The total intensity is computed by the sum of the emittance
term $epsilon(x, x')$ giving the emitted light between $x$ and $x'$. Onto the
emittance term is added the total amount of light reached at a surface point $x'$.
The addend is the integral of the incoming intensity over a hemisphere $S$
of a point $x'$ (@figure:rendering-equation) @Kajiya1986.

#figure(
    box(inset: (bottom: 0.5cm), image("res/rendering equation.svg", width: 35%)),
  caption: [Model of incoming intesity for a surface patch.],
) <figure:rendering-equation>

The incoming intensity is scaled by the scattering term $rho(x, x', x'')$.
Its purpose is to express the scattering of light from surface patch at $x'$ and
equates to the cosine between the surface normal and the direction of the
sampled point on the hemisphere. #cite(<PBR_2023>, supplement: "sec. 5.5.1")
For example, the scattering term for a diffuse
surface scales down incoming light significantly compared to the non-existing
scattering of a perfect reflection @Kajiya1986.
Ideally the integral samples all points on the hemisphere. In practice techniques
such as biased path tracing rely on Monte Carlo methods to sample a sub set
of the hemisphere and further optimizations such as importance sampling.

=== Bidirectional distribution functions

Various materials interact differently with incoming light.
This behavior not explicitly described by the rendering equation
(which assumes sampling points $x, x', x''$ to be given) is modeled by encoding the path a ray
of light takes when interacting with a surface through a @BDF. @BDF is the generalized
from of both the @BRDF and @BTDF. The @BRDF defines interaction of diffusely reflective
dielectric materials such as wood or stone.
The @BRDF allows rays to bounce from the surface to potentially any direction covered
by the hemisphere over the surface patch.
In contrast, the @BTDF models
transmissive materials such as glass by refracting incoming rays of light
through the object.
#cite(<PBR_2023>, supplement: "sec. 5.6.1")

#figure(
    box(inset: (bottom: 0.5cm), image("res/bsdf.png", width: 40%)),
  caption: [Visual guide to the bidirectional scattering distribution functions @Jurohi2006.],
) <figure:bsdf>

More advanced materials making use of additional interactions such as subsurface scattering
for semi transmissive surfaces such as the human skin are generalized by the @BSDF
#cite(<PBR_2023>, supplement: "sec. 5.6.2") #cite(<PBR_2023>, supplement: "sec. 9.1").
These distribution functions in conjunction with the rendering equation form
the base for physically based rendering. Realistic materials make use of a combination
of all the distribution functions defined by the @BSDF. Commonly these
distribution functions are combined by sampling either one depending on a
per distribution function probability given by either a constant or through
the use of a texture mapped onto a surface. For real-time rendering avoiding
probabilistic sampling models the outcome of different distribution functions
may be blended together #cite(<PBR_2023>, supplement: "sec. 9.3.2").
By combining distribution functions common properties observed in the real world
can be recreated with the addition of absorption coefficients in order to tint
light after interaction. Common properties used by rendering formats include:
albedo (tinted diffuse scattering), metallic (tinted reflections without any
diffuse contribution) and roughness @Moneimne2025.

=== Shading Model

Shading models provide solution for solving parts of the rendering equation (@section:shading).
For example, to achieve glossy reflections a factor is required to 
determine how spread out incoming samples of light are for a given
patch of surface thereby having influence in the @BRDF used. Depending on the method
of rendering, various shading models find application. For the scope of this work
the focus is set on @PBR models as is common in current day rendering engines. 

A physically based material is defined by a set of properties describing
the interaction between light and the surface (see deduction in @section:shading).
The software Blender, as used for modelling (see @section:modelling), defines
physically based material through the Principled @BSDF Node #cite(<BlenderBook>, supplement: "sec. 2").
This shader works by applying material properties in different layers (see @BlenderManual_PrincipledBSDF).
For the sake of simplicity and portability for reasons discussed later,
the only properties used in generating believable materials for the model
will be the following: diffuse, metallic, roughness and normal.
Diffuse refers to the "base" color of the diffuse component of the material. For
a wooden material this color would, on average, be brownish. Metallness specifies
which parts are metallic. This value should ideally be either zero or one as
mixed dielectric and metallic surfaces are rather rare to come by. Roughness
is the anti-proportional equivalent to glossiness, determining the blurring of
the specular part observed in both dielectric and metallic surfaces.
@figure:shading-properties shows the effect three material properties: metalic (above),
roughness (below) and base color rendered directly in Blenders path tracing
engine Cycles. Detailed explanation of Blenders material properties can be found at @BlenderManual_PrincipledBSDF.

#figure(
    box(inset: (bottom: 0.5cm), grid(
        rows: 2,
        columns: (80%),
        image("res/render_shader-nodes_shader_principled-metallic.jpg"),
        image("res/render_shader-nodes_shader_principled-roughness.jpg")
    )),
    caption: [Metalic (above) and roughness (below) on a scale from zero to one @BlenderManual_PrincipledBSDF.]
) <figure:shading-properties>

Normal maps are applied in addition to boost macro level bumps on the surface
without having to include such displacement in the triangular geometry @BlenderBook @BlenderManual_PrincipledBSDF.
This helps to reduce the effort required to manage the memory needed to store additional geometry
and run rendering pipelines for high amounts of detail.
@fig:normalmap shows the effect of applying a normal map in comparison to
true geometric displacement and a flat surface.

#figure(
    box(inset: (bottom: 0.5em), {
        image("res/normalmap.svg", width: 90%)
        grid(
            columns: (1fr, 1fr, auto),
            "displacement",
            "flat geometry",
            "flat geometry + normal mapping",
        )
    }),
  caption: [Baked textures for major material properties.]) <fig:normalmap>

Normal mapping works by transforming the normal vector stored in the normal map
from tangent space to object space. Tangent space is the vector space represented
by an orthonormal basis of which the basis is formed by the normal, tangent and binormal vectors of the surface.
A simplified transformation of the surface normal by the normal map can be computed by
scaling each of the orthonormal basis $B$ vectors ($B_X,B_Y,B_Z$) by the tangent normals
components $arrow(n) = (x,y,z)$ resulting in the transformed normal vector $arrow(n)_r$.

$
  arrow(n)_r = B_X arrow(n)_x + B_Y arrow(n)_y + B_Z arrow(n)_z
$

This assumes the tangent normal is of length one and has component values in the range $[-1, 1]$.
Tangent normals stored in a normal map are usually in the range $[0, 1]$. An even more simplified
version of normal mapping is bump mapping, where a single scalar height value is used compute the
tangent normal as the derivative of the bump or height texture. Normal maps have the advantage of capturing
angled normal data whereas mere height data does not.

A more comprehensive collection of good examples for various material properties and their effects on shading can
be found in the MatSynth dataset @matsynth.

== Synthesis of procedural materials

Know where to derive the pixel contents of the textures? For this purpose
the modelling software Blender offers a comprehensive library of tools for
generating a high variety of variance via procedural generation.
Procedural generation is the process of artificially generating data by introducing
pseudo randomness or patterns usually used for textures or models.
This can be done by mixing real world captured data together with
generated patterns. These mixing operations, patterns can be created or tweaked
manually or generated automatically due to the rise of machine learning based
generation models for procedural materials like VLMaterial @li2025vlmaterialproceduralmaterialgeneration
or MatFormer @MatFormer. For the sake of simplicity the traditional approach of handcrafting
procedural material properties is chosen. A decision made due to the lack of experience
with named generation tools and time constraint. Further exploration of this topic is out of scope
for this work. 

Generation for the material properties is split up into different kinds of material the machine is composed of.
The major materials identified are the metal hull painted in green, dark red plastic for lever handles and
glossy metal for moving parts. Additionally, brass metal components can be found at special places such
as the sprocket wheel used to select input numbers.

// TODO: insert image highlighting materials used in the machine.

For each of these materials the major properties such as diffuse color, metallic, roughness and normal offset
are approximated with a set of experience based formulas. These formulas are based on a couple of functions
that have direct equivalents in the Blender node editor and are as shown in @table:procedural-operators.
The notation convention is as follows: colors are represented by vectors of the letter c with further specification of origin
for vertex attributes set as parameter like $arrow(c)_"vertex"$. Colors without parameter are assumed to be constants.
A material receives a world space position $arrow(p)$ for the pixel currently being colored.

#figure(
  table(
    columns: (auto, auto, 1fr),
    table.header([Name], [Operator], [Description]),
    [mix], $"mix"(a,b,k)$, [Linear interpolation of colors $a,b$ by a scalar factor $k$.],
    [ramp], $"ramp"_X (arrow(c))$, [Map input values to output values as given by the set of $X$. Similar to curve adjustments for digital images.],
    [noise], $h_(d,f)(arrow(p))$, [Generate perlin noise with frequency $f$, distortion factor $d$ for a position $arrow(p)$]
  ),
  caption: [Common operators used in procedural generation.]
) <table:procedural-operators>

Diffuse colors are computed by either of the given methods (5, 6). The basic idea is to mix different base colors
based on perlin noise with different frequencies and distortion factors. The approximated base colors can be found
in // TODO: reference appendix for colors.

$
  "albedo"_"hull" (arrow(p)) = "mix"( arrow(c)_1 dot h_(d_1,f_1) (arrow(p)), arrow(c)_2 dot h_(d_2,f_2) (arrow(p)), k )
$

For the green metal hull and glossy surface metal this method provides decent results with minimal effort.
Base colors are derived from pictures sampling the average color in a rectangular region of the picture
with the assumed least amount of specular interference. For surface being heavily deteriorated by grunge
a per vertex color attribute can be used to control the amount a certain color is used per vertex.
In order to avoid hard linear gradients the vertex color may be multiplied by a noise function in order
to make the transitions more detailed (6). 

$
  "albedo"_"brass" (arrow(p)) = "ramp"_(X)( arrow(c)_"vertex" dot h_(d_1,f_1) (arrow(p)) )
$

The vertex color is assumed to be black and white as equation (6) is only used for dirty brass components
heavily impacted by lubricant and angular friction due to usage. Roughness and normal offset are 
calculated in virtually the same manner but instead of computing a color a single scalar value is produced.
Color constants are replaced by scalar constants. Metalness is set to either zero or one depending
on the material being either a dielectric or not. In total a material count of four arises for
the model. Example renders of the material can found in figure
// TODO: insert figure showing off the procedural materials.

=== Baking



#figure(
    box(inset: (bottom: 0.5em), {
        grid(
            columns: (1fr, 1fr, 1fr, 1fr),
            row-gutter: 1em,
            image("res/diffuse.png", height: 3.25cm),
            image("res/metallic.png", height: 3.25cm),
            image("res/roughness.png", height: 3.25cm),
            image("res/normal.png", height: 3.25cm),
            "Diffuse",
            "Metallic",
            "Roughness",
            "Tangent normal"
        )
    }),
  caption: [Baked textures for major material properties.],
) <picture:baked-textures>

=== Indirect light

So far the baked diffuse component contains no information about occlusion or shadows
cast by other parts of the machine. Blender is able to bake information about direct and indirect
illumination right into the texture itself. This would allow complex illumination for the machine
without additional computational costs later on since the lightning is rendered statically into the
texture itself. To further improve the quality of the baked illumination the same environment
light can be used for baking as is used later for rendering the model in the emulation software.
Unfortunately baking shadows into the model has a drawback. Statically baked shadows won't move
when the casting object is moved. This will later result in dark patches where the shadow is baked
but no shadow should be. This behavior can be seen in @picture:shadow-baking.

#figure(
  image("res/shadow_baking.png", width: 50%),
  caption: [Baked shadow remains in place when moving the casting mesh.],
) <picture:shadow-baking>

In the example image the shadow of a lever as been baked into the diffuse texture. When rotating the
lever the shadow stays put. This effect is too noticeable in order to stay like that.
A possible workaround would be to only bake the shadows cast by object that are later going to be
static as well, result in incoherent illumination. The added effort of manually tweaking the casting
of shadows during the baking process or creation of an advanced material capable of disabling
shadows depending on the object currently baking is considered, while possible, to great and ultimately
not worth the effort.

=== Channel encoding

Material properties in Blender are usually encoded in their own respective image texture.
This is the standard way of defining materials in computer graphics and this is the method
used for modelling the Brunsviga so far.
According to the @glTF 2.0 specification a "metallic-roughness" model is used. Hereby are
all previously discussed material properties applied but the storage layout of both metallic
and roughness differs. Instead of having each of them stored as gray-scale in separate textures,
effectively duplicating two times two color channels in total, both properties are squashed
into a single texture. Since both metallness and roughness are scalar properties, they require
at least a single color channel. Storing the same values in all color channels would be redundant.
As such the @glTF specification requires for metallic and roughness a single image texture,
where the metallic scalar coefficient is stored in the green channel and the roughness coefficients
find their place in the green channel. This leaves the image with a single unsued color channel that
remains unused but removes an entire image texture as two properties are encoded in a single one. @iec12113_2022 

= Mesh optimization

== Polygon reduction

#figure(
  image("res/overdraw.png", width: 75%),
  caption: [Visualization of polygon overdraw.],
) <picture:overdraw>


== Texture compression

Rarely any picture nowadays is being stored uncompressed. Assuming a single
pixel requires 8 bytes of storage space for its three red, green and blue and alpha channels,
a single texture would require about 134 MB.

$
  4096^2 dot 2 frac("Byte", "Channel") dot 4 "Channel" approx 134,22 "MB"
$

For a total of four material properties, each having their own texture, this would amount to 537 MB just
for the raw pixel data. Having to download half a gigabyte just to load the textures is beyond the margin
of acceptance. Luckily, image compression can dramatically reduce file size. Since @glTF is the export
format of choice all textures are embedded on export automatically. For this reason the @glTF specification dictates the image
format used for the textures. According to the IEC-12113 standard (@glTF 2.0 specification) the only supported
image formats are @JPEG and @PNG @iec12113_2022. However, the Blender software allows @glTF export with the @webP
format @BlenderManual_glTF. This is due to support for the @webP extension based on the @glTF 2.0 specification @khronos_webp_ext.
The @webP image format has the advantage of offering efficient compression, saving storage space, and wide adoption on the web.
According to Google, @webP encoded images are about 30 % smaller when compressed than @JPEG or @PNG encoded one's
equivalent visual quality @Alakuijala_2017. Compression of @webP images is based on the VP8 intra-frame encoding and
offers varying levels of quality with the maximum being lossless @rfc9649. The crucial factor to decide on is the
compression quality employed when exporting the image textures. Higher compression results in lower image quality.
Blender offers configuration for this setting through the "Quality" parameter indicating the compression quality
where 100 percent mean lossless and zero percent is the maximum compression achievable by @webP.
Lower quality equates to a greater loss in image detail. @picture:compression-error shows a comparison
of the quality parameter for compression applied to the diffuse texture of the model.

#figure(
    box(inset: (bottom: 0.15em), {
        image("res/webp_compression.png", width: 100%)
        move(dy: -0.5cm, {grid(
            columns: (1fr, 1fr, 1fr, 1fr, 1fr),
        "lossless",
        "90%",
        "75%",
        "50%",
        "10%"
      )})
    }),
  caption: [Compression loss of JPEG format at varying levels.],
) <picture:compression-error>

The upper half shows a cropped version of the diffuse texture with @webP compression applied to the level
indicated by the percentage given below. In order to avoid recompression the image has been encoded as @PNG
using lossless compression. The image sequence below visualizes the loss in detail. This is done by subtracting the
compressed image from the uncompressed image and scaling the result for better visibility. The luminance of each pixel
indicates the difference between uncompressed and compressed image. More gray or white pixels indicate a higher loss
of details as every non-black pixel represents lost detail. As can be seen, with a quality of 75 % the loss in detail 
is already quite significant as the perlin noise @fBM of the models metal plating is starting to smooth and loose high frequencies.
At a level of 10 % the loss is so tremendous, that all noise detail is replaced with compression artifacts and a solid color.
Judging by this test a compression quality between 100 % and 80 % is to be used for the images as 75 % provides the lower
bound of acceptable loss of detail.

#figure(
  image("res/compression_ratio.svg", width: 100%),
  caption: [File size reduction by compression quality.],
) <picture:compression-size>

== Summary of compression methods

// TODO: bar chart showing the file size of:
//  - Highpoly model (glTF) + PNG textures
//  - Lowpoly model (glTF)  + PNG textures
//  - Lowpoly model (glTF)  + WebP textures (losseless)
//  - Lowpoly model (glTF)  + WebP textures (90% compression) + Channel encoding
//  - Lowpoly model (glTF)  + WebP textures (90% compression) + Channel encoding
//  - Lowpoly model (glTF)  + WebP textures (90% compression) + Channel encoding + Draco compression
