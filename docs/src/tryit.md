# Try it

```@meta
CurrentModule = PlutoSlides
```

Below is the example notebook, opened in slide mode[^1]. Click inside it, then use the arrow
keys; **⧉ Slide Mode** leaves slide  (or press escape or go to slide 0). The printed pdf version is [there](assets/edit_pluto.pdf).
The page might take a few seconds to load.

!!! note "This is a static page"
    This is the notebook's HTML export: no Julia runs behind it. You can browse the slides,
    but the theme, font, color and logo controls do nothing here. To use them, run the
    notebook in Pluto: click *Edit or run this notebook* at the top of the page, or open
    `example/notebook_test_doc.jl` from the repository.

    Note that the HTML version uses CairoMakie because WGLMakie does not render in static exports. The PDF export uses WGLMakie. It is just a matter of `CairoMakie.activate!()` vs `WGLMakie.activate!()` in the notebook, and you can switch between them. 

```@raw html
<style>
/* This page only: widen the main column (Documenter caps it at 52rem). */
#documenter .docs-main { max-width: 75% !important; }
/* The deck is laid out on a 1300x1000 screen and scaled down to fit; keep the box aspect-ratio equal to it. */
.ps-tryit { position: relative; width: 100%; aspect-ratio: 1300/1000; overflow: hidden; border: 1px solid #ccc; border-radius: 6px; }
.ps-tryit iframe { position: absolute; top: 0; left: 0; width: 1300px; height: 1000px; border: 0; transform-origin: 0 0; }
</style>
<div class="ps-tryit">
  <iframe src="https://pluto.land/n/9gl42vym" loading="lazy" allowfullscreen></iframe>
</div>
<script>
(() => {
  const box = document.querySelector(".ps-tryit")
  const frame = box.querySelector("iframe")
  const fit = () => { frame.style.transform = `scale(${box.clientWidth / frame.offsetWidth})` }
  new ResizeObserver(fit).observe(box)
  fit()
})()
</script>
<p><a href="https://pluto.land/n/9gl42vym" target="_blank">Open it full page</a></p>
```

The deck is shown as on a 1300 px wide screen, scaled down to fit this page. For the real
size, open it full page.

!!! tip "Print it to PDF"
    You can print this example notebook to PDF, by clicking the printer button (🖨) at the bottom right of the deck.

The export opens in slide mode because the notebook uses
`slide_mode_button(start_in_slide_mode_html=true)` (see
[Starting in slide mode](@ref)).

[^1]: This is one of my favorite examples of math theorem the Riemann–Lebesgue lemma, and tied to my PhD work on the Vlasov equation and postdoc work.