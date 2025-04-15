= Brains of steel

The Design of the Brunsviga 13 RK reflects both engineering ingenuity and precision craftsmanship.
It is able to perform simple mathematical operations through the interplay of various registers
with the selection register at its heart. In this chapter the internal structure of the device
is examined and each individual component explained. Also, the interaction between the components
is analyzed to better understand the mechanics of the Brunsviga.

== Structure

The Brunsviga consists of two main components. These are the selection register with the sprocket
wheels and the sled with the result register. Along the selection register are the input and count register on top of it.

#figure(
  image("res/brunsviga_front.jpg", width: 65%),
  caption: "Brunsviga, front view.",
) <picture:brunsviga_front>

As seen in @picture:brunsviga_front, the machine also possesses five levers and a handle for
the selection register.
Three of the Lever resets a separate part of the machine. The function of the left lever is
to reset the input register and, consequently, the selection register. The upper right lever
serves to reset the count register, while the lower right lever is for resetting the result
register. It is possible to completely reset the machine state using these levers. The two
additional levers have been added to enhance the usability of the Brunsviga. With the right
state of the small lever, it is possible for the right-hand lever to operate the left-hand
lever at the same time. This means that it can not only reset the count register, but also
the input register. The large lever on the right operates both lever on the right. Therefore,
when the small lever is correctly positioned, the large lever can be utilized to reset all
components of the Brunsviga concurrently. This significantly enhances the operational speed.

== Selection register

The selection register is the most important component of the Brunsviga.
It is not only used to set the individual digits, but also to start the computation with the rotation of the handle.

#figure(
  image("res/sprcketwheel.png", width: 65%),
  caption: "Selection register removed from the machine.",
) <picture:sprocketwheel>

As can be seen in @picture:sprocketwheel, the selection register has multiple components.
On the right end the handle to perform the rotation, on the left side a cogwheel for
transmission of the rotation to other components and in the middle ten individual
sprocket wheels for the selection of the digits. It is mentioned, that the handle has a
small tip on the other side and can be pulled. Each sprocket wheel contains eleven
sprockets which can be categorized into two distinct types. The function of these
sprockets is to modify the digits in the result register. The first category of sprockets
can be set with the small handle on the sprocket wheel. Each sprocket is then raised in
turn the further the lever is turned. The second category are two sprockets which handle
the overflow for each digit. These are always raised but shifted to the right, so that they
don't interfere with the normal counting. The result register pushes the needed sprout to the
left to change the count of the next digit accordingly. The sprocket wheel is also not perfectly
round but has an intentional curvature to press the overflow lever back down after
its usage. On the left end of all sprocket wheels is a small button. This Button locks all
sprocket wheels in place and needs to be pressed to change any digit. This mechanism is one
of many to prevent the user to bring the machine in an unstable state and to disrupt the calculation.
Each handle has teeth and functions as a gear to rotate each digit in the input register.

== Count and Result register

The Brunsviga should also operate for subtraction and multiplication with negative numbers.
Because of that the count register has a second pair of numbers on the left of each wheel.
These are red and can't be seen in the default state. The metal cover on top of the register is movable.
To select the right pair of numbers the count register has an extra wheel for the first rotation
which presses the cover to the left, when the selection register is rotates counterclockwise,
revealing the red numbers.
This wheel remains in this state unless on a reset. To move the cover back a small metal wire
operates as a spring. The overflow of all wheels in the register is resolved with a large metal
gear under the register. It has sprockets that are pushed to the right place when needed.
This gear also prevents a reset when its rotated.

The result register is the only register which can be moved relative to the selection register.
This movement is mainly to simplify the multiplication process. Given that it is impossible to
prevent an overflow and sometimes an underflow is especially desired, a bell is installed
in the back of the Brunsviga to signal these occurrences.

When the sled is moved to higher states, it is like the selection register is rotated magnitudes
higher than normal. Therefore, the sled specify which wheel on the count register is rotated.
This mechanism is achieved via a lever that connects the sled to the count mechanism of the count
register. On the Count mechanism is also a red indicator for the specified wheel.

== States of the Brunsviga

As mentioned in the previous chapter, the Brunsviga has several mechanisms in place to
prevent incorrect operation. All of these mechanisms prevent changes while the rotation
of the selection register or prevent the rotation while other components change. Therefore,
the Machine can be described in two discrete states. The change from one state to the other
is fully controlled with the tip of the handle of the selection register. In the selection
state It presses on a metal bar, which connects different mechanisms to enable certain functions.
This pressed state of the metal bar is passed on different lever and components. When pressed
it mainly enables the sprocket wheels on the selection register over the small button on the
side of the wheels and locks the register in place. On this state the sled can be moved, and
all registers can be reset. It should be noted that all levers for reset lock the rod in place
so that the state can not be changed while resetting. When the State changes, most mechanisms
are locked with the metal bar. The Sled and the sprocket wheels are locked in Place.
All reset lever are physical blocked to prevent a reset while rotating the selection register.
