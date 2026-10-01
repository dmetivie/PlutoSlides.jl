# Try it!

```@meta
CurrentModule = PlutoSlides
```

Below is the example notebook, opened in slide mode. Click inside it, then use the arrow
keys; **⧉ Slide Mode** leaves slide mode.
The page might take a few seconds to load. 


!!! note "This is a static page"
    This is the notebook's HTML export: no Julia runs behind it. You can browse the slides,
    but the theme, font, color and logo controls do nothing here. To use them, run the
    notebook in Pluto: click *Edit or run this notebook* at the top of the page, or open
    `example/notebook_test_doc.jl` from the repository.

```@raw html
<style>
/* This page only: let the main column use the full window width. */
#documenter .docs-main { max-width: none !important; }
/* The deck is laid out on a laptop-sized screen (1600x1000) and scaled down to fit. */
.ps-tryit { position: relative; width: 100%; aspect-ratio: 16/10; overflow: hidden; border: 1px solid #ccc; border-radius: 6px; }
.ps-tryit iframe { position: absolute; top: 0; left: 0; width: 1600px; height: 1000px; border: 0; transform-origin: 0 0; }
</style>
<div class="ps-tryit">
  <iframe src="https://pluto.land/n/8ysfskpg" loading="lazy" allowfullscreen></iframe>
</div>
<script>
(() => {
  const box = document.querySelector(".ps-tryit")
  const frame = box.querySelector("iframe")
  const fit = () => { frame.style.transform = `scale(${box.clientWidth / 1600})` }
  new ResizeObserver(fit).observe(box)
  fit()
})()
</script>
<p><a href="https://pluto.land/n/8ysfskpg" target="_blank">Open it full page</a></p>
```

The deck is shown as on a 1600 px wide screen, scaled down to fit this page. For the real
size, open it full page.

The export opens in slide mode because the notebook uses
`slide_mode_button(start_in_slide_mode_html=true)` (see
[Starting in slide mode](@ref)).
