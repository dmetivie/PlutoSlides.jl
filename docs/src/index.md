```@raw html
---
layout: home

hero:
    name: PlutoSlides.jl
    text: Beamer-like slideshows for Pluto notebooks
    tagline: Keep Pluto's reactivity, present it like a Beamer or reveal.js deck.
    actions:
      - theme: brand
        text: Get started
        link: "#Quick-start"
      - theme: brand
        text: See an example deck
        link: https://pluto.land/n/k1hq5qtm
      - theme: alt
        text: View on GitHub
        link: https://github.com/dmetivie/PlutoSlides.jl
    image:
      src: /logo.svg
      alt: PlutoSlides.jl

features:
  - icon: 🎞️
    title: Slides from headings
    details: "#, ## and ### markdown cells become section, slide and sub-slide, with title bands, footer and slide counter."
  - icon: 🎨
    title: Beamer-like themes
    details: Twelve built-in themes (Madrid, Berlin, Warsaw, Dracula...), logos, fonts and every color overridable.
    link: /style/
  - icon: 🖨️
    title: PDF export
    details: Print the deck to PDF from the browser, one slide per page (experimental).
    link: /pdf/
---
```

```@meta
CurrentModule = PlutoSlides
```

![Example](https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/master/assets/example.gif)

!!! warning "Not an official Pluto project"
    Pluto has its own [presentation mode](https://plutojl.org/en/docs/presentation/).
    PlutoSlides is a separate, experimental take on it. A refresh (`F5`) sometimes helps.

## Installation

PlutoSlides is not in the General registry yet. Either point the notebook environment to
the repository (Julia ≥ 1.12, [`[sources]`](https://discourse.julialang.org/t/pluto-1-0-release/137296#p-638767-automatic-pkg-management-5)):

```toml
[sources]
PlutoSlides = {url = "https://github.com/dmetivie/PlutoSlides.jl"}
```

or add the author's registry once, then `using PlutoSlides` as usual:

```julia
import Pkg
Pkg.pkg"registry add https://github.com/dmetivie/LocalRegistry"
```

## Quick start

Three cells turn a notebook into a deck:

```julia
using PlutoSlides

# 1. Style and scripts (the notebook keeps the slide look even outside slide mode)
slide_mode_settings(footer_left="Jane Doe", footer_center=md"PlutoSlides.jl")

# 2. Optional title slide
slide_mode_title(title="My talk", author=md"Jane Doe -- *Institute*")

# 3. The toggle
slide_mode_button()
```

Click **⧉ Slide Mode**, then move with the arrow keys or by clicking the left/right side
of the screen. The HTML export of the notebook keeps the button, so a deck shared on
[pluto.land](https://pluto.land/n/k1hq5qtm) can be presented from the browser.

## Writing slides

Slides are cut at headings, like in Pluto's presentation mode:

| heading | becomes | shown in |
|:--|:--|:--|
| `# Section` | a section slide | the thin top band of the following slides |
| `## Slide` | a new slide | the title band |
| `### Sub-slide` | a new slide (unless `h3_title=false`) | a band under the `##` title |

!!! warning "One heading per cell"
    A heading is only well detected when it is **alone** in its markdown cell:
    ```julia
    md"## My slide"       # ✓ heading cell
    md"Content"           # ✓ content cell
    md"## My slide\nContent" # ✗ top of the content cell will be cut off
    ```

Anything Pluto can display can go in a slide: plots, widgets, tables...
`@htl` from [HypertextLiteral.jl](https://github.com/JuliaPluto/HypertextLiteral.jl)
is handy to mix text with live results: `@htl"<p>The answer is $(x)</p>"`.

### Title slide

[`slide_mode_title`](@ref) builds a title slide with a band, the authors, a row of figures
and a footnote. The title band follows the active theme unless `color` is given.

```julia
slide_mode_title(
    title="PlutoSlides.jl: the Pluto slideshow!",
    author="You",
    footnote=md"[^1]: This is not an official Pluto project",
    figures=[Resource("https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/master/assets/logo_pluto_slides.svg", :width => "100%")],
)
```

### Pauses

[`pause`](@ref) inserts an invisible marker; what follows is revealed step by step.
`pause(n)` reveals it from step `n`, like Beamer's `\pause[n]`. It works best between
paragraphs of a markdown cell and is still **experimental**.

```julia
md"""
Always visible

$(pause(1))

Step 1

$(pause(2))

Step 2
"""
```

### Embedding web pages

[`myWebPage`](@ref) shows a live web page in an `<iframe>`. `offset` crops the top of the
page, for example to hide a site's navigation bar:

```julia
myWebPage("https://julialang.org"; width="90%", ratio="45%", offset=80)
```

## Next steps

- [Style and themes](@ref): fonts, themes, colors, bands and logos.
- [PDF export](@ref): print the deck.
- [Suggested workflow](@ref): editing and checking a deck efficiently.
- [API](@ref): every function and keyword.
