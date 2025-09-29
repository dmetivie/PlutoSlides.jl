# PlutoSlides

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://dmetivie.github.io/PlutoSlides.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://dmetivie.github.io/PlutoSlides.jl/dev/)
[![Build Status](https://github.com/dmetivie/PlutoSlides.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/dmetivie/PlutoSlides.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/dmetivie/PlutoSlides.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/dmetivie/PlutoSlides.jl)

Who doesn't love [Pluto.jl](https://plutojl.org/)?
Who doesn't love a nicely formatted slideshow?
This package combines the two!
Actually, it tries to do so! As I have no knowledge of Javascript, almost no comprehension of HTML and CSS, I turned to LLMs to help me out.

I was frustrated by the basic look of the [presentation mode of Pluto](https://plutojl.org/en/docs/presentation/), which did not look like my classic Beamer presentations.
Modifying this classic presentation mode is not easy, because it requires some choice, might depends on the size of your screen and so on ([see here](https://github.com/fonsp/Pluto.jl/discussions/3226)).
However, I still wanted to try and end up creating this package in case you find it useful.

## Features

- Slide mode: it will display `# Section`, `## Subsection/Slide`, and `### Subsubsection` as different slides. The convention is similar as in Pluto's presentation mode (so the original presentation mode should also work).  The last title appear in a band at the top of the slide.
- Navigation: you can navigate through the slides with the arrow keys, or with a click on the left/right part of the screen and leave slide mode.
- Title slide: it will display the title (`# Title`) of the notebook as the title slide.
- `pause()` command: it will create a pause in the slide, allowing you to reveal content step by step. It is very experimental and seems to work inside markdown cells like

```julia
"""md 
First part of a joke
$(pause())
End of the joke!
"""
```

- Slide counter: it will display the current slide number and the total number of slides (it should be an option).
- Size of fonts for your screen.

!!! warning
    This package is very experimental. Keep in mind that the display of the slides might depend on your screen size. Sometime of good old `F5` (refresh) might be needed.

## Workflow

My typical workflow **at work** is

1. Open a Pluto notebook with `import Pluto;Pluto.run(auto_reload_from_file=true)`
2. Have the `.jl` script open in a larger screen
3. Using the laptop I'll use for the presentation as a second screen, I open the Pluto notebook. This is the only way to be sure that what will be displayed is exactly what I want.
4. Edit either the `.jl` script or the Pluto notebook. The notebook will reload automatically.

Obviously, if you don't have a second screen e.g. **on the road**, you can just open the notebook on your presentation laptop.

## TODO

- [ ] More options (font size for code output, font family, etc.). In fact if you know a bit of CSS, HTML and Pluto you could already do so easily, but it would be nice to have like in Beamer an option at the beginning of the notebook.
- [ ] Template like Beamer themes (where do you put title band etc., colors).
- [ ] More testing (I have only tested on my computer, with Firefox).
