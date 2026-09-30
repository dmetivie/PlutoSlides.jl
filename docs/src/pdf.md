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
the bottom. Use the paper's ratio to fill the page, or `pdf_stretch > 1` to take back
part of that band. With a stretch that goes past the paper's ratio, the bottom of the
slide is cut off.

```julia
slide_mode_settings(pdf_aspect="a4")                       # fill an A4 landscape sheet
slide_mode_settings(pdf_aspect="screen", pdf_stretch=1.1)  # as on screen, 10% taller
slide_mode_settings(pdf_aspect=16/9)
```

`font_size` also applies to the PDF, so a smaller font puts more on each page.

## Known limitations

- Each slide prints fully revealed: [`pause`](@ref) steps are not split into pages.
- Vertical spacing can differ slightly between a full-screen and a windowed browser.
