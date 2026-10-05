# PlutoSlides

![logo](https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/master/assets/logo_pluto_slides.svg)

[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://dmetivie.github.io/PlutoSlides.jl)

Who doesn't love [Pluto.jl](https://plutojl.org/)? Coding, and seeing the results immediately thanks to reactivity...
Who doesn't love a nicely formatted slideshow like Beamer or reveal.js used by Quarto?
This package aims to combine the two! Gets Pluto with a slideshow format.

![Example](https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/master/assets/example.gif)

> [!WARNING]
> Disclaimer: As I had no knowledge of Javascript, basics of HTML and CSS, I turned to AI/LLMs to help me out. So this package is very much vibe coded. I did read the code and tried to understand it, but I am sure there are better ways to do things.

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
    figures=[Resource("https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/refs/heads/master/assets/logo_pluto_slides.svg", :width => "100%")]
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

## Warnings

> [!WARNING]
> **Display**: Keep in mind that the display of the slides (vertical and horizontal) depends on your screen size. I currently did not found a way to ensure reproducible rendering across, laptot and browser. I sometime use the browser zoom with `ctrl`+`+` to enlarge the slides fonts (instead of changing the font size in the code).
> When I develop I always check that the slides are displayed correctly on my laptop screen at the resolution I will use for the presentation.
>
> The base font size is `19` px by default (a browser's own default is 16, which is small on a projector). Everything else is sized in rem/em, so changing it rescales the whole slide, PDF export included: `slide_mode_settings(font_size=22)`, or `font_size=nothing` to leave the notebook's own size alone.
>
> The PDF export takes the shape and the width of the browser window you export from, so export from the window — and the full screen (`F11`) state — you will present with.

> [!WARNING]
> **Title slides**: Currently, for correct display and detection of titles, you need to write `h1` (#), `h2` (##), and `h3` (###) titles in separate markdown cells without any other content.
>
> For example,
>
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
>
> DO NOT write
>
> ```julia
> md"""
> ## SubTitle h2
> Text of h2
> """
> ```

> [!WARNING]  
> **Experimental**: This package is very experimental and not well tested. Sometimes a good old `F5` (refresh) might be needed.

> [!WARNING]
> **Performance**: I had issues with performance on some notebooks, see issue (see [#3](https://github.com/dmetivie/PlutoSlides.jl/issues/3)), it seems it has been fixed in PlutoSlides.jl v0.2.0!
> However, if you find issues do not hesitate to open an issue or a PR with a MWE.

## Workflow

See the [suggested workflow](https://dmetivie.github.io/PlutoSlides.jl/dev/workflow/) in the documentation.

**Origin story**

I was not completely satisfied by the look of the [presentation mode of Pluto](https://plutojl.org/en/docs/presentation/), which did not look like my usual Beamer presentations.
Modifying this classic presentation mode is not completely straightforward, because it requires some choice, might depend on the size of your screen and so on ([see here](https://github.com/fonsp/Pluto.jl/discussions/3226)).
However, I still wanted to try and end up creating this package in case you find it useful.
There is a lot of room for improvement, and better ways to do things, so feel free to open an issue or a PR.

## TODO

### General

- [X] Address the performance issue on some notebooks see issue [#3](https://github.com/dmetivie/PlutoSlides.jl/issues/3). **I hope it is fixed in v0.2.0.**
- [ ] More testing (I have only tested on my computer, with Firefox). *`]test` now covers the Julia side; the slide behavior is still checked by hand.*

### Layout

- [ ] Ability to detect and display better the h2, h3 titles in the notebook. Currently, it is very strict and requires them to be in separate markdown cells without any other content.
- [ ] Better scalability/formatting of notebooks for different screens and font sizes. There is `max_width` option, but it is not perfect. Maybe a `max_height` option could be useful too?
- [X] h3 title with the h2 top right title in the band. **This is `h3_title=true`, the default: on a `###` slide the `##` goes to the top-right band and the `###` takes the band below it.**
- [X] The fonts of the footer band I think do not match the rest of the slide.
- [ ] Option to remove slide counter, add/remove total slide number.
- [X] No title band slide if empty h2 title `##` title is provided? Or like an option?

### Features

- [X] PDF export of the slides. **See [PDF export](https://dmetivie.github.io/PlutoSlides.jl/dev/pdf/); pauses are not yet split into separate pages.** Experimental. Tested on my laptop with Firefox with Print to PDF.
- [ ] Make the Pluto screen recording work nicely with slide mode. *Screen recording with your computer is probably the best way to record currently.*
- [X] Template like Beamer themes, e.g. Madrid, Berlin. Possibility to have templates with logo on each slide. **See [Style and themes](https://dmetivie.github.io/PlutoSlides.jl/dev/style/) and the `logo` option.**
