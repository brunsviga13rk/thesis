#import "@preview/tiaoma:0.3.0"

#set align(left)

Technology become obsolete and falls victim to entropy as is the fate of all in this universe.
Effective maintenance and repair of physical machines required for preservation
may be inappropriate for each and every device to preform.
After all, is a broom of which the handle and brush have been replaced numerous times still the same broom?
There may be more cost-effective and accessible ways for long-term preservation with digital reformatting.
The goal of digital preservation is to ensure access to digital forms of information.
For this purpose a detailed recreation of the _Brunsviga 13 RK_ is conceived.
This digital twin of the decadic calculating machine from the 1950s serves as the foundation
for the implementation of a functional simulation allowing world-wide access to the machine's
operation. This paper takes a close look at the recreation process and software design of the simulation
as well as the functionality and intricacies the engineers of the 1950s thought of while designing a computing
device still capable of operation over half a century later.

#v(1fr)

#align(center, line(length: 90%))

#v(1fr)

Special thanks to Prof. Dr. Bauer from the Cooperative State University Baden-Württemberg for his
support during the course of study as well as to the former owners of the machines that were required for this work.

#show link: set text(size: 10pt)

#v(0.5cm)

#grid(rows: 2,
  row-gutter: 1cm,
  stack(dir: ltr, spacing: 1em,
    tiaoma.barcode("https://github.com/brunsviga13rk/emulator", "QRCode", options: (scale: 1.1)),
    stack(dir: ttb,
      spacing: 0.8em,
      [*Simulation*],
      [Source code of the web based simulation.],
      link("https://github.com/brunsviga13rk/emulator")[https://github.com/brunsviga13rk/emulator])),
  stack(dir: ltr, spacing: 1em,
    tiaoma.barcode("https://github.com/brunsviga13rk/thesis", "QRCode", options: (scale: 1.1)),
    stack(dir: ttb,
      spacing: 0.8em,
      [*Paper*],
      [Typst source of this paper.],
      link("https://github.com/brunsviga13rk/thesis")[https://github.com/brunsviga13rk/thesis])))

