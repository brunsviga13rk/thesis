// Import document template.
#import "../template/src/lib.typ": *

#show: dhbw-template.with((
  // language settings used to make decisions about hyphenation and others
  lang: "en", // ISO 3166 language code of text: "de", "en"
  region: "en", // region code
  // mark this thesis as draft
  // Adds preleminarry note page and watermark
  draft: true,
  // information about author(s)
  university: (
    program: "Informationtechnology",
    faculty: "Technology",
    name: "Cooperative State University Baden-Württemberg",
    campus: "Mannheim",
  ),
  authors: (
    (
      name: "Sven Vogel",
      course: "TINF22IT2",
      company: none,
      contact: none,
      matriculation-number: 1191225,
    ),
    (
      name: "Felix Lothar Müller",
      course: "TINF22IT2",
      company: none,
      contact: none,
      matriculation-number: 0,
    ),
  ),
  // information about thesis
  thesis: (
    title: "Emulation of the decadic calculating machine Brunsviga 13 RK",
    subtitle: "", // subtitle may be none
    submission-date: "15.04.2025",
    timeframe: "15.10.2024 - 15.04.2025",
    kind: "T3100",
    // translated version of abstract, only used in case language is not english
    summary: none,
    abstract: none,
    preface: none,
    keywords: ("IT", "Web", "Simulation", "Brunsviga"),
    bibliography: none, /* bibliography("refs.bib") */
    glossary: none,
    appendices: none,
  ),
  style: (header: (logo-image: "")),
))

= Introduction
