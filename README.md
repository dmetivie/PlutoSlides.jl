# PlutoSlides

![logo](https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/master/assets/logo_pluto_slides.svg)

Who doesn't love [Pluto.jl](https://plutojl.org/)? Coding, and seeing the results immediately thanks to reactivity...
Who doesn't love a nicely formatted slideshow like Beamer or reveal.js used by Quarto?
This package aims to combine the two[^Disclaimer]! Gets Pluto with a slideshow format.

[^Disclaimer]: Actually, it tries to do so! As I have no knowledge of Javascript, almost no comprehension of HTML and CSS, I turned to LLMs to help me out. So this package is very much vibe coding.

![Example](https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/master/assets/example.gif)

Note that the `html` version of the Pluto notebook can activate the slide mode ! See this [Julia presentation](https://pluto.land/n/k1hq5qtm) for example.

> [!WARNING]
> Pluto already has a [presentation mode](https://plutojl.org/en/docs/presentation/). This package is not an official Pluto project, and it is not meant to replace the original presentation mode. It is just a different way to display your Pluto notebook as a slideshow, with some additional features.

## Installation

It is not yet registered in the General registry, but you can

- Use the Julia 1.12 `[sources]` in the project of your notebook to specify where to find the package [see here](https://discourse.julialang.org/t/pluto-1-0-release/137296#p-638767-automatic-pkg-management-5)
```julia
[sources]
PlutoSlides = {url = "https://github.com/dmetivie/PlutoSlides.jl"}
```

- Or install it from my local registry with
```julia
julia> import Pkg; 
julia> Pkg.pkg"registry add https://github.com/dmetivie/LocalRegistry"
```

Then add it to your Pluto notebook with like any other package `using PlutoSlides` in the notebook.


## Usage

In a Pluto notebook, after installing the package, you can enable slide mode with

```julia
using PlutoSlides

# this will make the notebook width/font etc like the slides (check the docstring for options)
# this is if you want to work on your notebook without the slide mode enabled but keeping same style
slide_mode_settings(footer_left="Authors", footer_center=md"PlutoSlides.jl")

# you can add an (h1) title slide with
slide_mode_title(
    title="PlutoSlides.jl: the Pluto slideshow!",
    author="You",
    footnote=md"[^Note]: This is not an official Pluto Project",
    figures=[Resource("https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/refs/heads/master/assets/logo_pluto_slides.svg", :with => "100%")]
)

# then click it to enable/disable slide mode
slide_mode_button()

# ╔═╡ c9a502d8-7856-46ca-bc47-5566c29908ed
md"""
## Subsubtitles
"""

# ╔═╡ 4cf38fc9-e6f8-45cd-a874-7afdf307f59a
md"""
Currently, for correct display of titles, you need to write `h1`, `h2`, and `h3` titles in separate markdown cells without any other content.
"""

# ╔═╡ a12e0d99-3f30-4fd0-81b0-78153cf6ed4c
md"""
This `h2` slides can be divided into two `h3`!
"""

# ╔═╡ e08a2697-bf8f-40b9-8fbe-50ff6544d4b7
1+1

# ╔═╡ 0ba7fe0b-3a5f-4a68-a13c-3f1bfabffb53
md"""
### Subsub title 1
"""
```

## Features

- Slide mode: it will display `# Section`, `## Subsection/Slide`, and `### Subsubsection` as different slides. The convention is similar as in Pluto's presentation mode (so the original presentation mode should also work).  
- Title slide and section titles bands: The last title appears in a band at the top of the slide.
- Slide counter: it will display the current slide number and the total number of slides. (Making this optional is a planned feature.)
- Appearance (fontsize, font family, colors): you can customize the appearance of the slides with various options, or pick a whole Beamer-like `theme` (see [Themes](#themes)).
- Logo(s): show one or several logos/images on every slide, with predefined or manual positioning (`logo`, `logo_position`, see the `slide_mode_settings` docstring).
- PDF export: a print button turns the deck into a real PDF via the browser's own print dialog (see [PDF export](#pdf-export)).
- Navigation: you can navigate through the slides with the arrow keys, or with a click on the left/right part of the screen and leave slide mode.
- Title slide: it will display the title (`# Title`) of the notebook as the title slide.
- `pause(n)` command: it will create a pause in the slide, allowing you to reveal content step by step. It is very experimental and seems to work inside markdown cells like

## Warnings

> [!WARNING]
> **Display**: Keep in mind that the display of the slides (vertical and horizontal) depends on your screen size. I now prefer to zoom with `ctrl`+`+` to enlarge the slides fonts (instead of changing the font size in the code). When I develop I always check that the slides are displayed correctly on my laptop screen at the resolution I will use for the presentation.

> [!WARNING]
> **Title slides**: Currently, for correct display and detection of titles, you need to write `h1`, `h2`, and `h3` titles in separate markdown cells without any other content.
> 
> For example, 
> ```julia
> md"""
> ## SubTitle h2
> """
> md"""
> Text of h2
> """
> md"""
> ### SubSubTitle h3
> """
> md"""
> Text of h3
> """
> ```
> DO NOT write
> ```julia
> md"""
> ## SubTitle h2
> Text of h2
> """
> ```

> [!WARNING]  
> **Experimental**: This package is very experimental and not well tested. Sometimes a good old `F5` (refresh) might be needed.

> [!WARNING]
> **Performance**: On some of my larger notebooks, I noticed a huge performance drop. Is it related to the number of slides or something else? I don't know. If you have an idea, please discuss it on the related issue [#3](https://github.com/dmetivie/PlutoSlides.jl/issues/3).
> > It seems that this was fixed in PlutoSlides v0.2.0!

## Workflow

My typical workflow **at work** is

1. Open a Pluto notebook with `import Pluto;Pluto.run(auto_reload_from_file=true)`
2. Have the `.jl` script open in a larger screen
3. Using the laptop I'll use for the presentation as a second screen using full screen of your navigator, I open the Pluto notebook. This is the only way to be sure that what will be displayed is exactly what I want.
4. Edit either the `.jl` script or the Pluto notebook. The notebook will reload automatically.

If you don't have a second screen e.g. **on the road**, you can just open the notebook on your presentation laptop.

> [!TIP]
> You can have very simple Markdown layout, but thanks to `@htl` macro, you can have much more complex one, with output of code (figures, numbers etc.) entangled with text using interpolation `@htl"My text is $(x)"`.
> For that `HypertextLiteral.jl` and `MarkdownLiteral.jl` packages are great.

> [!TIP]
> **LLMs**: LLM coding assistants are so powerful that they can really help with HTML, Markdown, etc.
> Using them inside your IDE with `import Pluto;Pluto.run(auto_reload_from_file=true)` is really powerful[^LLMs].
> It can easily convert existing LaTeX Beamer slides to a Pluto notebook.
> To add a cell, they sometimes can even generate correct Pluto unique cell id `# ╟─xxxx` that is recognized by Pluto. In case this does not work, you can always add the cell on the notebook and it will appear on the `.jl` script.

[^LLMs]: This is not specific to `PlutoSlides.jl`, but for Pluto in general.

## Origin story

I was not completely satisfied by the look of the [presentation mode of Pluto](https://plutojl.org/en/docs/presentation/), which did not look like my usual Beamer presentations.
Modifying this classic presentation mode is not completely straightforward, because it requires some choice, might depend on the size of your screen and so on ([see here](https://github.com/fonsp/Pluto.jl/discussions/3226)).
However, I still wanted to try and end up creating this package in case you find it useful.
There is probably a lot of room for improvement, and better ways to do things, so feel free to open an issue or a PR.

## TODO

### General:
- [X] Address the performance issue on some notebooks see issue [#3](https://github.com/dmetivie/PlutoSlides.jl/issues/3). **I hope it is fixed in v0.2.0.**
- [ ] More testing (I have only tested on my computer, with Firefox).
- [ ] Pause feature does not work in all cases. 

### Layout:
- [ ] Ability to detect and display better the h2, h3 titles in the notebook. Currently, it is very strict and requires them to be in separate markdown cells without any other content.
- [ ] Better scalability/formatting of notebooks for different screens and font sizes. There is `max_width` option, but it is not perfect. Maybe a `max_height` option could be useful too?
- [ ] h3 title with the h2 top right title in the band (currently it adds a new band bellow h2 title band).
- [ ] The fonts of the footer band I think do not match the rest of the slide.
- [ ] Option to remove slide counter, add/remove total slide number.
- [ ] No title band slide if empty h2 title `##` title is provided? Or like an option?

### Features:
- [X] PDF export of the slides. **See [PDF export](#pdf-export); pauses are not yet split into separate pages.**. Super experimental. Tested on my laptop with Firefox with Print to PDF.
- [ ] Make the Pluto screen recording work nicely with slide mode.
- [X] Template like Beamer themes, e.g. Madrid, Berlin. Possibility to have templates with logo on each slide. **See [Themes](#themes) and the `logo` option.**

# Experimental features

## PDF export

Click the printer icon (🖨) in the slide-mode controls to turn the current deck into a
PDF, using the browser's native print dialog ("Save as PDF"). Two `slide_mode_settings`
keywords control the page shape:

- `pdf_aspect`: shape of a printed slide, as width/height. Defaults to the live browser
  window's own ratio (so the print looks like what you saw on screen), which on a
  relatively taller sheet leaves a blank band at the bottom. Set it to the paper's ratio
  (e.g. `"a4"`, `"letter"`, `16/9`, `"16:9"`, `(297, 210)`) to fill the sheet instead.
- `pdf_stretch`: extra vertical room as a multiplier on the slide's height only (default
  `1`), to reclaim part of that blank band without going all the way to the paper's
  shape.

```julia
# Fill an A4 landscape sheet instead of leaving the bottom blank
slide_mode_settings(footer_left="My Presentation", pdf_aspect="a4")

# Or keep the screen's shape and just claim 10% more height
slide_mode_settings(footer_left="My Presentation", pdf_stretch=1.1)
```

> [!WARNING]
> This has only been tuned against **Firefox's "Save to PDF"** on **A4 landscape**
> paper. Chromium-based browsers should also work (they honor `pdf_aspect` exactly,
> without Firefox's letterboxing), but are less tested.
>
> Known limitations: the export prints every slide fully revealed as a single page --
> `pause(n)` steps are not split into separate pages. Vertical spacing can also differ
> slightly between a fullscreen and a non-fullscreen browser window.

## Themes

Pass a built-in Beamer-like theme instead of setting colors one by one:

```julia
slide_mode_settings(theme=:Warsaw, footer_left="My Presentation")

available_themes()                    # list all theme names
available_themes(; descriptions=true) # ... with a one-line description of each
```

A theme sets a whole look (palette *and* band style: gloss, rounding, shadow, rules),
and any explicit keyword you also pass still overrides it, like Beamer's `\usetheme`
followed by a `\setbeamercolor`. The built-ins come in six families:

| family | themes | look |
|:--|:--|:--|
| split | `:Madrid` (default), `:Coral` | headline cut in two, three-tone footer, soft shadow |
| shaded | `:Berlin`, `:Warsaw` | the same bands, glossy and deeply shadowed |
| smooth bars | `:Singapore`, `:Copenhagen` | flat bars with rounded free corners |
| plain | `:Boadilla`, `:Journal` | no fills: rules and colored text only, no headline |
| block | `:Rochester`, `:Frankfurt` | no headline, one solid band for the frametitle |
| dark | `:Dracula`, `:Dark` | dark slide surface with light text |

You can also pass a `NamedTuple`/`Dict` of overrides to `theme=` for a fully custom
inline theme. See the `slide_mode_settings` docstring for the full list of band-style
keywords (`band_overlay`, `band_radius`, `band_shadow`, `subtitle_border`,
`footer_border`, `subtitle_align`, `show_title_band`, ...).

> [!WARNING]
> Dark themes repaint the slide surface itself. Check any plot with a transparent background before presenting with one.
