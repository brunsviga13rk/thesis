<!-- LTeX: language=en-US -->

<img alt="banner" src="./assets/banner.svg" width="100%"/>

<div align="center">
    <h2>
        Thesis about emulating the Brunsviga 13 RK
    </h2>
</div>

<div align="center">
  <p>
      Emulation of the decadic calculating machine Brunsviga 13 RK <br>
      paper as part of the T3100 exam at the Cooperative State University Baden Württemberg.
  </p>
</div>

<div align="center">
    <img src="https://img.shields.io/badge/CC%20BY--SA%204.0-green?style=for-the-badge&label=LICENSE">
    <img src="https://img.shields.io/badge/typst-239DAD.svg?style=for-the-badge&logo=typst&logoColor=white">
    <img src="https://img.shields.io/badge/latex-%23008080.svg?style=for-the-badge&logo=latex&logoColor=white">
</div>

<br>

Source of the research paper written at the cooperative
state university Baden-Württemberg for the course informationtechnology
at the faculty of technology. Subject of research is the simulation of the
mechanical calculator "Brunsviga 13 RK" from the 1950s. The overall goal is to
be able to be able to operate a virtual calculator via a web based interface.
See the official repository of the project for updates
[here](https://github.com/brunsviga13rk/emulator).

The project was conducted from 15.10.2024 to 15.04.2025.

## Document

Typst was chosen as typesetting language for its modernized syntax based on
asciidoc and useful scripting capabilities.

This document makes use a custom template specifically developed for writing
thesis at the cooperative state university Baden-Württemberg. Source of the
template can be found at its GitHub mirror
[here](https://github.com/Servostar/dhbw-abb-typst-template).

## Build Locally

For building locally the Typst compiler is required. Install via your preferred
package manager. Make sure you use at least v0.12.0. More recent version may not
be working properly due to Typst being in prerelease.

For simplified compilation use the Makefile:
```sh
make build
```

This will result in the compiled file stored in the root folder of the
repository as `${TYPST_FILE_PATH}.${TYPST_FILE_TYPE}`. Where these values are
provided by the `.env` file.

## Configuration

Primary configuration of the compilation process is written into the `.env`
file. It contains configuration options for:

| Options name     | Type   | Default                                |
| ---------------- | ------ | -------------------------------------- |
| TYPST_FILE_PATH  | string | 44124_emulation-of-the-brunsviga-13-rk |
| TYPST_FILE_TYPE  | string | pdf                                    |
| TYPST_MAIN       | string | src/main.typ                           |

## Bibtex reference

```
@techreport{Brunsviga13rkVogelMüller2025,
  title       = "Emulation of the decadic calculating machine Brunsviga 13 RK",
  author      = "Sven Vogel, Felix L. Müller",
  institution = "Cooperative State University Baden Württemberg",
  address     = "Baden-Württemberg, Germany",
  year        = 2025,
  month       = april
}
```
