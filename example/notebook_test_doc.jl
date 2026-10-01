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
using PlutoSlides

# ╔═╡ 538e71c7-e425-466e-b004-5e4ed4bf026c
using HypertextLiteral

# ╔═╡ e719a33e-13f8-449e-a8f3-3f16c5ecbed0
import MarkdownLiteral: @markdown

# ╔═╡ 2aff06d6-cf3c-4bc9-bfdc-ca3f9e24ed09
md"""
Authors PlutoSlides.jl
"""

# ╔═╡ 19b05b91-1e11-43dd-ae84-5e064e7466d3
slide_mode_button(start_in_slide_mode_html=true)

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

# ╔═╡ ee5b7844-8f79-4b81-ac10-6b914c54d2b4
md"""
## Other Subtitle
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
## Webpages
"""

# ╔═╡ 30c727be-321e-474d-a277-14c9221e1f62
myWebPage("https://julialang.org/")

# ╔═╡ 0d557219-6b7c-4cbc-ad8c-e29d33786749
md"""
## Pause feature
"""

# ╔═╡ ba1cdebb-ba89-46ae-a856-73fc569ff759
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

# ╔═╡ e91261be-5708-43ad-9f52-fcf32cb5fad1
@markdown("""
``n = `` $(aa)
""")

# ╔═╡ ddb3482a-dca5-4432-8bcb-237fef1cf299
x = range(0, 10, length=n)

# ╔═╡ e89fc5b2-d7f1-477f-baa2-243d4c23c5d2
y = sin.(x)

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
PlutoLinks = "0ff47ea0-7a50-410d-8455-4348d5de0420"
PlutoSlides = "ccaada3e-fbb3-407e-96e9-78c3ad6e4026"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[sources]
PlutoSlides = {rev = "master", url = "https://github.com/dmetivie/PlutoSlides.jl"}

[compat]
HypertextLiteral = "~1.0.0"
MarkdownLiteral = "~0.1.5"
PlutoLinks = "~0.1.8"
PlutoSlides = "~0.3.1"
PlutoTeachingTools = "~0.4.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.1"
manifest_format = "2.1"
project_hash = "cf37f997a816fb4228a65b5a0363693d07449092"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
registries = "General"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"
version = "1.11.0"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "REPL", "UUIDs"]
git-tree-sha1 = "cfb7a2e89e245a9d5016b70323db412b3a7438d5"
registries = "General"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "3.0.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "61761f58648aa7217445f24f841839b78c712232"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.3"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.CommonMark]]
deps = ["PrecompileTools"]
git-tree-sha1 = "7c8fe02c7eb6fe22e89d3990123a2a931ca8fcfb"
registries = "General"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "1.0.4"

    [deps.CommonMark.extensions]
    CommonMarkMarkdownASTExt = "MarkdownAST"
    CommonMarkMarkdownExt = "Markdown"

    [deps.CommonMark.weakdeps]
    Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
    MarkdownAST = "d0879d2d-cac2-40c8-9cee-1863dc0c7391"

[[deps.Compiler]]
git-tree-sha1 = "382d79bfe72a406294faca39ef0c3cef6e6ce1f1"
registries = "General"
uuid = "807dbc54-b67e-4c79-8afb-eafe4df6f2e1"
version = "0.1.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.5.5+2"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
registries = "General"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
registries = "General"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
registries = "General"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
registries = "General"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
registries = "General"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
registries = "General"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
registries = "General"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
registries = "General"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random"]
git-tree-sha1 = "24a00d415eac260385b0f260340457664a7b2bca"
registries = "General"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.11.5"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f88f3ccef05a6a72a0cf0ed417c8fd68530f4ab2"
registries = "General"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.1"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "df7566479bd64f20bd16b09960145e70160ffb3b"
registries = "General"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.12"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "1.0.0"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "Zstd_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.18.0+1"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.1+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "OpenSSL_jll", "Zlib_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.104+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoweredCodeUtils]]
deps = ["CodeTracking", "Compiler", "JuliaInterpreter"]
git-tree-sha1 = "e16fd69604bef06cb3fe9da09b315005c9c34564"
registries = "General"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "3.9.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
registries = "General"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
registries = "General"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "e88f9af659a0cc9326fa464427f71ae6c9a83381"
registries = "General"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.5"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2026.8.13"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.30+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05f45c2e0de6259db764adbfd2f1dc6d3f8de13c"
registries = "General"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.46.0+0"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "844a829c8dc9fd0fe62eced22bc2d0dfd66a3f51"
registries = "General"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.1.0"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "aea4eede5ab3ee188906d0cf3bbfa36eb543dccc"
registries = "General"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.8"

[[deps.PlutoSlides]]
deps = ["Base64", "HypertextLiteral", "MIMEs", "PlutoUI", "Printf"]
git-tree-sha1 = "10d7ebd3f0f92b132991ed0da16b4c88f10175c8"
repo-rev = "master"
repo-url = "https://github.com/dmetivie/PlutoSlides.jl"
uuid = "ccaada3e-fbb3-407e-96e9-78c3ad6e4026"
version = "0.3.1"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "Latexify", "Markdown", "PlutoUI"]
git-tree-sha1 = "90b41ced6bacd8c01bd05da8aed35c5458891749"
registries = "General"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.7"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
registries = "General"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
registries = "General"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
registries = "General"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["Base64", "Dates", "FileWatching", "InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
registries = "General"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
registries = "General"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Revise]]
deps = ["CRC32c", "CodeTracking", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Preferences", "REPL", "UUIDs"]
git-tree-sha1 = "82ac67271b84f674fccccbc9f92b106941fb8c65"
registries = "General"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.17.1"

    [deps.Revise.extensions]
    DistributedExt = "Distributed"

    [deps.Revise.weakdeps]
    Distributed = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "1.0.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
registries = "General"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
registries = "General"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
registries = "General"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["CompilerSupportLibraries_jll", "Libdl"]
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.67.1+0"

[registries.General]
url = "https://github.com/JuliaRegistries/General.git"
uuid = "23338594-aafe-5451-b93e-139f81909106"
"""

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
# ╟─e91261be-5708-43ad-9f52-fcf32cb5fad1
# ╠═ddb3482a-dca5-4432-8bcb-237fef1cf299
# ╠═e89fc5b2-d7f1-477f-baa2-243d4c23c5d2
# ╟─ee5b7844-8f79-4b81-ac10-6b914c54d2b4
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
# ╟─0d557219-6b7c-4cbc-ad8c-e29d33786749
# ╟─ba1cdebb-ba89-46ae-a856-73fc569ff759
# ╟─4eb97dfc-5791-41a2-b898-a9b1e2af2ff4
# ╟─458dd18c-1cf5-4e90-92fa-d2b15a276d0f
# ╟─38eaf5f1-c8f8-4371-8f12-7505eb7c1ace
# ╠═756fe1d4-a59d-4a7d-98cd-8c375a547623
# ╠═2ddc54a2-ea61-4372-a205-dc2a5d97a391
# ╠═89316786-bae7-43fa-8047-7942e9cc8106
# ╠═2dbf7891-6e13-4e4f-83a2-f611fb7def8d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
