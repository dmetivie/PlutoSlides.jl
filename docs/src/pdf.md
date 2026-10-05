# PDF export

```@meta
CurrentModule = PlutoSlides
```

!!! warning "Experimental"
    Tuned with Firefox's *Save to PDF* on A4 landscape. Chromium browsers should work
    (they follow `pdf_aspect` exactly, with no letterboxing) but are less tested.

## Printing

1. Enter slide mode with [`slide_mode_button`](@ref).
2. Click the printer button (🖨) in the slide controls.
3. In the browser's print dialog, choose *Save to PDF*.

Each slide becomes one page, with its bands, footer and logos. See
[this example PDF](assets/edit_pluto.pdf).

## Page shape

A slide keeps the browser window's width when printed, so the content has the same scale
as on screen. Two keywords of [`slide_mode_settings`](@ref) set its height:

| keyword | default | effect |
|:--|:--|:--|
| `pdf_aspect` | `"a4"` | width/height of a printed slide |
| `pdf_stretch` | `0.8` | multiplies the slide height only |

`pdf_aspect` accepts:

- a paper name: `"a4"`, `"letter"` (landscape);
- `"screen"`: the browser window's ratio, so the page looks like the live slide;
- a number `16/9`, a string `"16:9"` or a tuple `(297, 210)`.

A `"screen"`-shaped slide on a relatively taller sheet (16:9 on A4) leaves a blank band at
the bottom. `pdf_stretch` takes part of that band back. The two combine: a printed slide's
ratio is `pdf_aspect / pdf_stretch`, so the defaults (`"a4"` over `0.8`) come out at about
16:9. Matching the paper's own ratio fills the sheet; a slide taller than the sheet is
cropped by the paper, not scaled down.

!!! note "Never shorter than the live slide"
    A slide is laid out at the window's width, so it is as tall as it is on screen and a
    shorter page would cut its bottom off: these keywords can only make it taller. Export
    from the window -- and the `F11` state -- you will present with.

```julia
slide_mode_settings(pdf_aspect="a4", pdf_stretch=1)        # the A4 landscape shape itself
slide_mode_settings(pdf_aspect="screen", pdf_stretch=1.1)  # as on screen, 10% taller
slide_mode_settings(pdf_aspect=16/9)
```

`font_size` also applies to the PDF, so a smaller font puts more on each page.

## Known limitations

- Each slide prints fully revealed: [`pause`](@ref) steps are not split into pages.
- [`myWebPage`](@ref) embeds restart when the pages are built, so the export waits a few
  seconds for them ("Preparing PDF…"); one that refuses to be framed, or that draws itself
  late, prints blank. Firefox's print *preview* can show an embed empty even when the saved
  PDF has it -- trust the file, not the preview.
- This is not pixel perfect e.g. there is a blank space at the right. Moreover, Julia types like `x::Float64` are rendered differently in the browser and in the PDF.