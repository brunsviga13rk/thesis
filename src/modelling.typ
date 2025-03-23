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

== Polygonal modelling

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
For that purpose this chapter deals with the process of creating photo realistic
Materials for the polygon model. Afterward, textures
of each of the materials major properties will be extracted to individual images
enabling portable and detailed shading for the final model.

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

=== Procedural materials

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

#figure(
  image("res/shadow_baking.png", width: 50%),
  caption: [Baked shadow remains in place when moving the casting mesh.],
) <picture:shadow-baking>

= Mesh optimization

== Polygon reduction

#figure(
  image("res/overdraw.png", width: 75%),
  caption: [Visualization of polygon overdraw.],
) <picture:overdraw>


== Texture compression

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
  caption: [Compression loss of webp format at varying levels.],
) <picture:compression-error>


#figure(
  image("res/compression_ratio.svg", width: 100%),
  caption: [File size reduction by compression quality.],
) <picture:compression-size>
