# [Suggested workflow and tips](@id Suggested-workflow)

```@meta
CurrentModule = PlutoSlides
```

## Why PlutoSlides?

The goal is an *interactive Beamer*: slides that look like a classic deck, but where you
can change the code during the talk and everything that depends on it updates.

| tool | how it works | interactivity during the talk |
| :-- | :-- | :-- |
| LaTeX Beamer, Typst | write, compile, present the PDF | none: static pages (at best a GIF or a video) |
| PowerPoint | edit and present in the same app | animations and edits, but no code |
| Quarto (reveal.js) | write, render to HTML, present | the code ran at render time; some widgets, but you cannot change and rerun code live |
| Pluto's [presentation mode](https://plutojl.org/en/docs/presentation/) | the notebook, one section per slide | full, but a plain look: no title/subtitle bands, footer or slide numbers, no pauses, no PDF export, and harder to present from an HTML export |
| PlutoSlides | the Pluto notebook *is* the deck | full: edit any cell, move a slider, and every slide using it updates; Beamer-like bands, footer and slide numbers, `pause`, PDF export, and an HTML export that presents as is |

Because Pluto is reactive, a slide can hold a live computation: change a parameter and
the figures, numbers and text that depend on it update on every slide, while the deck
keeps its Beamer-like layout.

The package started because Pluto's own
[presentation mode](https://plutojl.org/en/docs/presentation/) did not look like a usual
Beamer deck, and changing it is not straightforward: it involves layout choices that
depend on the screen ([see this discussion](https://github.com/fonsp/Pluto.jl/discussions/3226)).
There is plenty of room for improvement: issues and PRs are welcome.

## Edit the file, watch the notebook

Start Pluto so that it reloads the notebook whenever its `.jl` file changes on disk:

```julia
import Pluto
Pluto.run(auto_reload_from_file=true)
```

You can then edit either the `.jl` file in your editor or the notebook in the browser; the
other side follows.

Note that this seems to work with [SpaceStation](https://github.com/GroupTherapyOrg/SpaceStation.jl) but not with [Snapshot.jl](https://github.com/GroupTherapyOrg/Snapshot.jl) export.

**With a second screen** (e.g. at the office):

1. Keep the `.jl` file open on the large screen.
2. Open the notebook, full screen, on the laptop you will present with.
3. Edit the file and check the result on the laptop.

The laptop shows exactly what the audience will see.

**On the road**, just open the notebook on the presentation laptop.

## Check on the presentation screen

How much fits on a slide depends on the screen size, the resolution and the browser.
There is no way yet to make the rendering identical everywhere, so check the deck on the
laptop and in the browser you will present with.

To make everything bigger or smaller, either use the browser zoom (`Ctrl` `+` / `Ctrl` `-`)
or change `font_size` in [`slide_mode_settings`](@ref), which rescales the whole slide
(see [Style and themes](@ref)).

!!! warning "Always have a backup of the notebook"
    In live demo, things often go wrong. Keep a copy of the notebook in `.html` or/and the export `.pdf`.
    Also the original Pluto presentation mode is a good backup, or plain Pluto notebook.
    You can also use [pluto.land](https://pluto.land/) to have your static deck online.

## Richer layouts

Plain Markdown cells are enough for most slides. To get really nice looking slides with sliders, LaTeX fonts, numbers etc, mix text with live results (numbers,
figures, widgets...), interpolate them with `@htl` from
[HypertextLiteral.jl](https://github.com/JuliaPluto/HypertextLiteral.jl) or `@markdown` from
[MarkdownLiteral.jl](https://github.com/JuliaPluto/MarkdownLiteral.jl):

Do use a lot [`PlutoTeachingTools.Columns`](https://github.com/JuliaPluto/PlutoTeachingTools.jl/blob/2b8121f4cc6d9778bef7ee4d35ccf08b9f0165d2/src/present.jl#L37) to put figures, result of code and text side by side, or to put multiple figures on the same slide.

!!! note
    I did not succeed yet in having Pluto code cell next to a Markdown cell. This would be cool

## Using an LLM assistant

With `auto_reload_from_file=true`, an LLM coding assistant in your editor can work directly
on the notebook file (this is true for any Pluto notebook). It is good at HTML, CSS and
Markdown layouts, and can convert existing LaTeX Beamer slides to a Pluto notebook.

It can often also create new cells, with a valid cell id (`# ╟─xxxx`) that Pluto accepts.
If that fails, add the cell in the notebook: it will appear in the `.jl` file.

Note that using stuff like [SpaceStation.jl](https://github.com/GroupTherapyOrg/SpaceStation.jl) or the [advanced-vscode-extension](https://github.com/JuliaPluto/advanced-vscode-extension) do provide facilities to edit Pluto notebooks with LLMs.
