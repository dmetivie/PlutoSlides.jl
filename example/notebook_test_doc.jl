### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ beab077f-c8e2-47fa-a4c6-50e0b25f8aff
using PlutoUI

# ╔═╡ 46eda44d-f80e-42d9-b935-6022136cdf02
using PlutoLinks

# ╔═╡ 69e29989-1adb-4b06-b77b-5dd15997df2e
using PlutoTeachingTools

# ╔═╡ ffb95f3b-7c02-47c5-ab02-a59fe9019f05
@revise using PlutoSlides

# ╔═╡ 538e71c7-e425-466e-b004-5e4ed4bf026c
using HypertextLiteral

# ╔═╡ e719a33e-13f8-449e-a8f3-3f16c5ecbed0
import MarkdownLiteral: @markdown

# ╔═╡ 2aff06d6-cf3c-4bc9-bfdc-ca3f9e24ed09
md"""
Authors PlutoSlides.jl
"""

# ╔═╡ 19b05b91-1e11-43dd-ae84-5e064e7466d3
slide_mode_button()

# ╔═╡ a8750d23-8b47-4314-970d-865673c82b21
md"""
# Features
"""

# ╔═╡ a27a9dc4-58c1-4703-8e4a-f6e8eed6080a
md"""
## Appearance
"""

# ╔═╡ 484dbfc7-a76f-4556-815a-ba647c593b21
md"""
Play with the appearance of your slides, themes, colors, fonts, logos, and more.
"""

# ╔═╡ 350c3667-787f-4d4c-85fd-691c22e83e88
md"""Choose your Pluto Slides color theme $(@bind main_color ColorStringPicker(default = "#3333B3")) override the theme color $(@bind custom_color CheckBox(default = false))"""

# ╔═╡ 2fc6ee50-10ad-4356-a963-d646559231ae
slide_mode_title(
    title="PlutoSlides.jl: the Pluto slideshow!",
    author="David Métivier",
	color = custom_color ? main_color : nothing,
    footnote=md"[^Note]: This is not an official Pluto Project",
    figures=[Resource("https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/refs/heads/master/assets/logo_pluto_slides.svg", :with => "100%")]
)

# ╔═╡ d172b63a-e8b5-4e65-a776-5b445a9943c4
md"""
Theme $(@bind theme_name Select([t => string(t,": ", d) for (t, d) in available_themes(; descriptions=true)], default = :Madrid))
"""

# ╔═╡ 7c4d1dd2-12bb-4905-94e5-916f6c73a9f8
md"""
Font size $(@bind fontsize_html NumberField(1:100, default=19))
"""

# ╔═╡ 82a9cdbc-ec90-4e19-8338-4d031b1dcc73
md"""
Max Width  $(@bind max_width Slider(70:100, default=98, show_value=true))%
"""

# ╔═╡ d2a53812-00a6-43c7-92fc-6cef0ec28ccb
md"""
Logo 

↔ $(@bind logo_x Slider(0:100, default=99, show_value=true))% 

↕ $(@bind logo_y Slider(0:100, default=96, show_value=true))% 

height $(@bind logo_h Slider(20:200, default=50, show_value=true)) px
"""

# ╔═╡ 6f314bab-3738-47ea-919e-98ed049a38ac
md"""
!!! note "Riemann-Lebesgue lemma: Same theorem different fonts!"
    Let ``f\in L^1(\mathbb{R}^n)`` be an integrable function, i.e. ``f\colon\mathbb{R}^n \rightarrow \mathbb{C}`` is a [measurable function](https://en.wikipedia.org/wiki/Measurable_function) such that
    :``\|f\|_{L^1} = \int_{\mathbb{R}^n} |f(x)| \mathrm{d}x < \infty, ``
    and let ``\hat{f}`` be the Fourier transform of ``f``, i.e.
    :
    ``\hat{f}\colon\mathbb{R}^n \rightarrow \mathbb{C}, \ \xi\mapsto \int_{\mathbb{R}^n} f(x) \mathrm{e}^{-\mathrm{i}x\cdot\xi}\mathrm{d}x.``

    Then ``\hat{f}`` vanishes at infinity: ``|\hat{f}(\xi)| \to 0`` as `` |\xi| \to\infty ``.
"""

# ╔═╡ 6d981650-6ec6-4324-8c9c-ca0fd10e0401
md"""
## Slide mode doc
"""

# ╔═╡ c9a502d8-7856-46ca-bc47-5566c29908ed
md"""
## Subsubtitles
"""

# ╔═╡ 4cf38fc9-e6f8-45cd-a874-7afdf307f59a
md"""
!!! warning
	Currently, for correct display of titles, you need to write `h1`, `h2`, and `h3` titles in separate markdown cells without any other content.
    See [Readme.md](https://github.com/dmetivie/PlutoSlides.jl/blob/52f94096e63040da44db79b8bca8e773eceb406e/README.md) for more details.
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

# ╔═╡ bcd56f3e-be12-478c-bc40-5d41de133a89
md"""
The other matrix:
"""

# ╔═╡ 38b39ef6-b0ac-4964-8262-d7c8afc3db01
B = rand(5, 5)

# ╔═╡ b27c5860-a6ec-4c74-bdb5-b7f2b605dbf4
md"""
### Subsub title 2
"""

# ╔═╡ da8b64ed-3e26-4739-bc74-1a45e067da29
md"""
Final matrix multiplication:
"""

# ╔═╡ dad08817-7cce-47dc-bd3f-703b3d257470
md"""
### Webpages (in another subsection)
"""

# ╔═╡ 30c727be-321e-474d-a277-14c9221e1f62
myWebPage("https://julialang.org/")

# ╔═╡ 33bcdc05-83ed-4071-bbe9-e93753de3b92
md"""
## Pause feature
"""

# ╔═╡ 816aa436-b68a-4af9-8ebe-b825e3b9a7ca
md"""
$(pause(3))

When doing presentations,

$(pause(0))

I like to present stuff,

$(pause(1))

with pauses,

$(pause(2))

to highlight the chain of thoughts.
"""

# ╔═╡ b19406af-c48c-4f39-9ae9-be79070b2d4a
md"""
# Example
"""

# ╔═╡ 06b554bc-5b6f-49c4-8f45-90b5fee60d8b
md"""
## Image with pause
"""

# ╔═╡ 4db8ab89-aa29-4b3a-94e6-bc24b84b732b
Columns(
    md"""
    - **Extremes and risks:**  
      impact on agriculture, health, energy...
    - **Climate change:**  
      changes in frequency, intensity,...

    \

    \

    \

    \

    **Can we estimate (future) risks quantitatively?**
    Examples:
    - Large-scale extremes (heatwaves)     
      or local (`RainMaker.jl` challenge 😉)
    - Compound extremes e.g. high temperature + humidity
    - Long-lasting events (e.g. droughts)
    """,
    md"""
    $(Resource("https://i.imgur.com/bcO30aD.png", :width => "90%"))
    """;
    widths=[45, 55], gap=10
)

# ╔═╡ 6b23b3a9-fd43-4b80-92b7-c03e8f935e7a
md"""$(pause()) ⟶ **Need** weather generators to estimate probabilities of rare events"""

# ╔═╡ 4eb97dfc-5791-41a2-b898-a9b1e2af2ff4
md"""
## Combining with PlutoTeachingTools.jl
"""

# ╔═╡ 458dd18c-1cf5-4e90-92fa-d2b15a276d0f
blockquote(
    md"""
    We are power **Matlab** users. Some of us are **Lisp** hackers. Some are **Pythonistas**, others **Rubyists**, still others **Perl** hackers. There are those of us who used **Mathematica** before we could grow facial hair. There are those who still can't grow facial hair. We've generated more **R** plots than any sane person should. **C** is our desert island programming language.

    **We love all of these languages**; they are wonderful and powerful. For the work we do — **scientific computing, machine learning, data mining, large-scale linear algebra, distributed and parallel computing** — each one is perfect for some aspects of the work and terrible for others. **Each one is a trade-off**.

    **We are greedy: we want more.**
    """,
    md"""
    [Why we created Julia](https://julialang.org/blog/2012/02/why-we-created-julia/) -- Jeff Bezanson, Stefan Karpinski, Viral B. Shah, and Alan Edelman
    """
)

# ╔═╡ 38eaf5f1-c8f8-4371-8f12-7505eb7c1ace
md"""
# Stuff you wanna hide
"""

# ╔═╡ 756fe1d4-a59d-4a7d-98cd-8c375a547623
const COMMON_FONT_STACKS = [
    "Default",
    # Sans-serif
    "Computer Modern Sans",
    "Computer Modern Sans, Fira Sans, Helvetica Neue, Arial, sans-serif",
    "Fira Sans, Helvetica, Arial, sans-serif",
    "Inter, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, Apple Color Emoji, Segoe UI Emoji",
    "Helvetica Neue, Helvetica, Arial, sans-serif",
    "Arial, Helvetica, sans-serif",
    "system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, Apple Color Emoji, Segoe UI Emoji",
    "Open Sans, Helvetica Neue, Arial, sans-serif",
    "Roboto, Helvetica Neue, Arial, sans-serif",
    "Noto Sans, Arial, sans-serif",
    "Source Sans Pro, Helvetica, Arial, sans-serif",

    # Serif
    "Georgia, Times New Roman, Times, serif",
    "Times New Roman, Times, Georgia, serif",
    "PT Serif, Georgia, Times New Roman, serif",
    "Computer Modern, Latin Modern Roman, Times New Roman, serif",

    # Monospace (for code blocks or UI)
    "JuliaMono, Menlo, Monaco, Consolas, Liberation Mono, Courier New, monospace",
    "Menlo, Monaco, Consolas, Liberation Mono, Courier New, monospace",
    "JetBrains Mono, Menlo, Consolas, monospace",
    "Fira Code, Consolas, Menlo, monospace",
]

# ╔═╡ 7f62e6ef-edc0-42cd-971d-38b94d9635ee
md"""
Font Family $(@bind font_family Select(COMMON_FONT_STACKS))
"""

# ╔═╡ ea9e8cfe-402d-4d9e-95b1-147615196a79
PlutoSlides.slide_mode_settings(footer_left="Authors", footer_center=md"PlutoSlides.jl", max_width=string(max_width, "%"), font_family=font_family, font_size=fontsize_html, h3_title=true,
    pdf_aspect="a4", pdf_stretch=0.80,#1.0495,
    logo = [Resource("https://raw.githubusercontent.com/dmetivie/PlutoSlides.jl/master/assets/logo_pluto_slides.svg")],
    # x% of the screen width lines up with x% of the logo's own width, so 0 and 100 keep it on screen
    logo_position = [(left="$(logo_x)%", top="$(logo_y)%", transform="translate(-$(logo_x)%, -$(logo_y)%)")],
    logo_height = logo_h,
    theme=theme_name;
    (custom_color ? (; color_subtitle_bg=main_color) : (;))...)

# ╔═╡ 2ddc54a2-ea61-4372-a205-dc2a5d97a391
aa = @bind n NumberField(2:1000, default = 100)

# ╔═╡ f1a98bbb-8474-4da8-94ef-229c1a52ef17
@markdown("""
By the way that's the same ``n`` as before ``n = `` $(aa). 
Changing it here updates every other slide using ``n`` (I mean that's just Pluto) without affecting the slide display (that's the hardest part to do).
""")

# ╔═╡ 5fe14d97-497d-40ae-8066-fed7dcd18927
A = rand(n, 5)

# ╔═╡ 795ef7d5-e187-4c38-938a-a08c9c354c30
A*B

# ╔═╡ 89316786-bae7-43fa-8047-7942e9cc8106
HiddenDocs(mod, name) = details(
	@htl("Show docstring for <code>$name</code>"), 
	@htl """
	<div class="pluto-docs-binding">
	<span id="$(name)">$(name)</span>
	$(Base.Docs.doc(Base.Docs.Binding(mod, name)))
	</div>
	""")

# ╔═╡ 2dbf7891-6e13-4e4f-83a2-f611fb7def8d
HiddenDocs(name::Symbol) = HiddenDocs(PlutoSlides, name)

# ╔═╡ e737be8e-6980-44ed-aaa9-030477561837
HiddenDocs(:slide_mode_settings)

# ╔═╡ Cell order:
# ╠═beab077f-c8e2-47fa-a4c6-50e0b25f8aff
# ╠═46eda44d-f80e-42d9-b935-6022136cdf02
# ╠═69e29989-1adb-4b06-b77b-5dd15997df2e
# ╠═ffb95f3b-7c02-47c5-ab02-a59fe9019f05
# ╠═e719a33e-13f8-449e-a8f3-3f16c5ecbed0
# ╠═538e71c7-e425-466e-b004-5e4ed4bf026c
# ╠═ea9e8cfe-402d-4d9e-95b1-147615196a79
# ╟─2aff06d6-cf3c-4bc9-bfdc-ca3f9e24ed09
# ╟─19b05b91-1e11-43dd-ae84-5e064e7466d3
# ╟─2fc6ee50-10ad-4356-a963-d646559231ae
# ╟─a8750d23-8b47-4314-970d-865673c82b21
# ╟─a27a9dc4-58c1-4703-8e4a-f6e8eed6080a
# ╟─484dbfc7-a76f-4556-815a-ba647c593b21
# ╟─350c3667-787f-4d4c-85fd-691c22e83e88
# ╟─d172b63a-e8b5-4e65-a776-5b445a9943c4
# ╟─7f62e6ef-edc0-42cd-971d-38b94d9635ee
# ╟─7c4d1dd2-12bb-4905-94e5-916f6c73a9f8
# ╟─82a9cdbc-ec90-4e19-8338-4d031b1dcc73
# ╟─d2a53812-00a6-43c7-92fc-6cef0ec28ccb
# ╟─6f314bab-3738-47ea-919e-98ed049a38ac
# ╟─6d981650-6ec6-4324-8c9c-ca0fd10e0401
# ╟─e737be8e-6980-44ed-aaa9-030477561837
# ╟─c9a502d8-7856-46ca-bc47-5566c29908ed
# ╟─4cf38fc9-e6f8-45cd-a874-7afdf307f59a
# ╟─a12e0d99-3f30-4fd0-81b0-78153cf6ed4c
# ╟─f1a98bbb-8474-4da8-94ef-229c1a52ef17
# ╠═5fe14d97-497d-40ae-8066-fed7dcd18927
# ╠═e08a2697-bf8f-40b9-8fbe-50ff6544d4b7
# ╟─0ba7fe0b-3a5f-4a68-a13c-3f1bfabffb53
# ╟─bcd56f3e-be12-478c-bc40-5d41de133a89
# ╠═38b39ef6-b0ac-4964-8262-d7c8afc3db01
# ╟─b27c5860-a6ec-4c74-bdb5-b7f2b605dbf4
# ╟─da8b64ed-3e26-4739-bc74-1a45e067da29
# ╠═795ef7d5-e187-4c38-938a-a08c9c354c30
# ╟─dad08817-7cce-47dc-bd3f-703b3d257470
# ╠═30c727be-321e-474d-a277-14c9221e1f62
# ╟─33bcdc05-83ed-4071-bbe9-e93753de3b92
# ╟─816aa436-b68a-4af9-8ebe-b825e3b9a7ca
# ╟─b19406af-c48c-4f39-9ae9-be79070b2d4a
# ╟─06b554bc-5b6f-49c4-8f45-90b5fee60d8b
# ╟─4db8ab89-aa29-4b3a-94e6-bc24b84b732b
# ╟─6b23b3a9-fd43-4b80-92b7-c03e8f935e7a
# ╟─4eb97dfc-5791-41a2-b898-a9b1e2af2ff4
# ╟─458dd18c-1cf5-4e90-92fa-d2b15a276d0f
# ╟─38eaf5f1-c8f8-4371-8f12-7505eb7c1ace
# ╠═756fe1d4-a59d-4a7d-98cd-8c375a547623
# ╠═2ddc54a2-ea61-4372-a205-dc2a5d97a391
# ╠═89316786-bae7-43fa-8047-7942e9cc8106
# ╠═2dbf7891-6e13-4e4f-83a2-f611fb7def8d
