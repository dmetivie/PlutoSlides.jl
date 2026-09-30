# Suggested workflow

```@meta
CurrentModule = PlutoSlides
```

## Edit the file, watch the notebook

Start Pluto so that it reloads the notebook whenever its `.jl` file changes on disk:

```julia
import Pluto
Pluto.run(auto_reload_from_file=true)
```

You can then edit either the `.jl` file in your editor or the notebook in the browser; the
other side follows.

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

## Richer layouts

Plain Markdown cells are enough for most slides. To mix text with live results (numbers,
figures, widgets...), interpolate them with `@htl` from
[HypertextLiteral.jl](https://github.com/JuliaPluto/HypertextLiteral.jl) or `@mdx` from
[MarkdownLiteral.jl](https://github.com/JuliaPluto/MarkdownLiteral.jl):

```julia
@htl"<p>After $(n) iterations the error is $(round(err; sigdigits=2)).</p>"
```

## Using an LLM assistant

With `auto_reload_from_file=true`, an LLM coding assistant in your editor can work directly
on the notebook file (this is true for any Pluto notebook). It is good at HTML, CSS and
Markdown layouts, and can convert existing LaTeX Beamer slides to a Pluto notebook.

It can often also create new cells, with a valid cell id (`# ╟─xxxx`) that Pluto accepts.
If that fails, add the cell in the notebook: it will appear in the `.jl` file.
