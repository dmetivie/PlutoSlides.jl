### A Pluto.jl notebook ###
# v0.20.18

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

# ╔═╡ ea9e8cfe-402d-4d9e-95b1-147615196a79
PlutoSlides.slidemode()

# ╔═╡ 23c6d19f-0331-4238-9f93-796a4013fd43
empty

# ╔═╡ 7c4d1dd2-12bb-4905-94e5-916f6c73a9f8
md"""
Global Font size $(@bind fontsize_html NumberField(1:100, default=24))
"""

# ╔═╡ 98e6aefb-019b-442c-a1ac-16f9a6f5acdd
md"""
Markdown Font size $(@bind fontsize_md NumberField(1:100, default=fontsize_html))
"""

# ╔═╡ 8de786fa-ca6f-4268-ba62-1f87c5bb1ef2
notebook_font_size(fontsize_html, fontsize_md)

# ╔═╡ 19b05b91-1e11-43dd-ae84-5e064e7466d3
button_slide_mode()

# ╔═╡ 2fc6ee50-10ad-4356-a963-d646559231ae
myTitle(title = "The Julia Programming Language", author = "David Métivier",
		footnote = md"[^credit]: This talk was partly inspired by [Guillaume Dalle Julia talk](https://gdalle.github.io/) + [Valentin Churavy](https://vchuravy.dev/talks/Making_Dynamic_Programs_Run_Fast/) + [Tim Holy lectures](https://github.com/timholy/AdvancedScientificComputing/tree/main) + videos and link shown in the notebook", 
		figures = [Resource("https://www.science-accueil.org/wp-content/uploads/2021/11/Logo-INRAE_Transparent-1536x406.png", :width => 450), Resource("https://github.com/dmetivie/MyJuliaIntroDocs.jl/blob/bd54deca5b4a8230ff4ddad73e7429738bba839e/figs/logos/MISTEA_inrae.png?raw=true", :with => 500)]
	   )

# ╔═╡ a8750d23-8b47-4314-970d-865673c82b21
md"""
## How did I started Julia
"""

# ╔═╡ 1d7a6946-e2a2-4352-8e74-5c077393ee49
Columns(
Resource("http://davidmetivier.mistea.inrae.fr/pic/research/flowchart_inrae.svg", :width => 900),
md"""
	**Coding experience**
	
	- Matlab/Mathematica (Internship)
	- C (with GPU) with Gnuplot/xmgrace (School and PhD)
	- Very few Python at (School and PhD)
	- Julia (Los Alamos Postdoc 1 2018)
	""";
widths = [60,40], gap = 0
)

# ╔═╡ 620103da-14c3-43ba-8d9c-25722f18426c
md"""
**Package I contribute**
- [ExpectationMaximization.jl](https://github.com/dmetivie/ExpectationMaximization.jl) (*Developer*)
- [QuasiMonteCarlo.jl](https://github.com/SciML/QuasiMonteCarlo.jl) (*Contributor*)
- [StochasticWeatherGenerator.jl](https://github.com/dmetivie/StochasticWeatherGenerators.jl) (*Developer*)
- Smaller projects [RobustMeans.jl](https://github.com/dmetivie/RobustMeans.jl) + [PeriodicHiddenMarkovModels.jl](https://github.com/dmetivie/PeriodicHiddenMarkovModels.jl) (*Developer*)
"""

# ╔═╡ c9a502d8-7856-46ca-bc47-5566c29908ed
md"""
## Goal of the presentation
"""

# ╔═╡ 33bcdc05-83ed-4071-bbe9-e93753de3b92
md"""
!!! note ""
	- Overviews of Julia's main features, functionalities, tools, and packages
	- This is **NOT** a step-by-step tutorial; see the Resource section at the end for some links.
	- You can follow: Notebooks are available
	At the end of the day, I hope you get a feeling that this is a great modern tool for complex scientific problems and teaching, and that the language favors collaborative work.

!!! tip "Ask Questions!"
"""

# ╔═╡ b19406af-c48c-4f39-9ae9-be79070b2d4a
md"""
# The Julia story
"""

# ╔═╡ 4eb97dfc-5791-41a2-b898-a9b1e2af2ff4
md"""
## 2012: the announcement
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

# ╔═╡ 8753bf78-4b72-4afe-b219-b87d96fa199f
md"""
!!! warning "Disclaimer"
	I will present many things: a lot already exists in other languages, sometimes as add-ons or wrapped C/C++ libraries.
	
	Julia language and most of its packages are inspired by many cool existing things.
	
	In this talk I want to emphasize the simplicity of some features and how far they can take us.
"""

# ╔═╡ 46cd0752-992e-43df-965e-1ecea6f280ff
md"""
## 2017: the SIAM Review article
"""

# ╔═╡ c797d46b-5a9a-4d7b-a988-d876f52e2436
blockquote(
  md"""
  Julia is designed to be easy and fast and questions notions generally held to be “laws of nature” by practitioners of numerical computing:
  1. High-level dynamic programs have to be slow.
  2. **One must prototype in one language and then rewrite in another language for speed or deployment.**
  3. There are parts of a system appropriate for the programmer, and other parts that are best left untouched as they have been built by the experts.
  """, 
  md"""
  [Julia: A Fresh Approach to Numerical Computing](https://epubs.siam.org/doi/10.1137/141000671) -- Jeff Bezanson, Alan Edelman, Stefan Karpinski, and Viral B. Shah
  """
)

# ╔═╡ e9643cb0-5c15-423b-8b8a-5527f9896ef5
md"""
## 2018: a stable language
"""

# ╔═╡ 6757b67e-21fc-4480-b284-63cf2590ca45
md"""
> The single most significant new feature in Julia 1.0, of course, is a commitment to language API stability: code you write for Julia 1.0 will continue to work in Julia 1.1, 1.2, etc. **The language is “fully baked.”** The core language devs and community alike can focus on packages, tools, and new features built upon this solid foundation.

[Announcing the release of Julia 1.0](https://julialang.org/blog/2018/08/one-point-zero/) -- Julia developers
"""

# ╔═╡ 8d895edb-a503-4fb2-b0e6-3c2499566eb4
md"""
Today v1.11 soon 1.12 (with binary compiled stuff)
"""

# ╔═╡ dbbe6add-dd22-4159-9c37-bf76f13c04a0
md"""
## 2022: user testimonies
"""

# ╔═╡ fcb36c30-6d2e-4bd8-b472-e12ee4a54f31
md"""
> With great resentment, I realized that for performance sensitive computing, there can be no such thing as a Python programmer: I could wrap my code in a Python cloak, but I would have to write all the hard stuff in C. A friend who had picked up Julia for theoretical physics taught me that **my frustration was common in scientific computing, and had a name: "The two language problem". Even better, it had a solution: Julia.** (Jakob Nissen)

> I remember working on an R script that needed to loop through 33 million rows of data, doing a complicated lag/join/basket kind of computation that would take 18 hours to run. Literally during one of these 18 hour runs, I saw the Julia announcement post and was immediately desperate for the kind of simple performance it promised. **I read the initial manual over a weekend, rewrote my script the following Monday morning, and it ran in 5 minutes.** (Jacob Quinn)

> What hooked me wasn't the speed (I was using Fortran before, which was more than adequate for that purpose), but **the composability of the whole ecosystem, which lets you easily leverage other people's work.** (Mosè Giordano)

> The Julia community is open, unassuming and inclusive, and works hard everyday to welcome new contributors and **reduce the barrier to entry for students**. It is one of Julia's biggest strengths. (Ranjan Anantharaman)

[Why we use Julia, 10 years later](https://julialang.org/blog/2022/02/10years/) -- The Julia Community
"""

# ╔═╡ 1b7bd762-fea3-4258-8aed-0e7012e99299
md"""
# Two languages problem
"""

# ╔═╡ 86d03bd0-c671-4a89-98cc-34f55f418076
md"""
## Scientists vs Developers
"""

# ╔═╡ f68c1e9f-2054-4649-a3fe-3070f4d95ac6
md"""
### Where is Julia (1/2)
"""

# ╔═╡ eda6ca36-2c98-401b-8066-082e0cc5b04d
Resource("https://cdn.hashnode.com/res/hashnode/image/upload/v1681735971356/91b6e886-7ce1-41a3-9d9f-29b7b096e7f2.png")

# ╔═╡ 2465b461-a8de-41bc-b8aa-120cc59a8698
md"""
### Where is Julia (2/2)
"""

# ╔═╡ 4c91ab1c-1b92-4d4c-8037-ce5bcd1d07e5
Resource("https://cdn.hashnode.com/res/hashnode/image/upload/v1681735992315/62fdd58f-4630-4120-8eb4-5238740543e8.png")

# ╔═╡ 8a16af2b-0b64-4f68-acb0-6528a2e2c8e7
md"""
## Compiled vs Interpreted
"""

# ╔═╡ 917f4674-002c-4f47-ad82-dfe6340423d7
Resource("http://ada-developers-academy.github.io/ada-build/learning-at-ada/ada-languages/images/compiled-interpreted.png", :width => 600)

# ╔═╡ 5460e927-a9cc-4187-9fe0-06ecf3eb00ef
md"""
!!! tip "Compilation"
	- Ahead of time (C, C++, Go, Rust, ...): types are statically defined and the code is compiled before execution
	- Just-In-Time (Julia, numba, JAX...): types inferred dynamically and functions compiled at first execution
	- Runtime (Python, R, ...): types inferred dynamically and functions compiled during runtime
"""

# ╔═╡ 5783675c-4f23-4190-8ded-07927666efd2
md"""
Julia is **dynamically** typed, feels like a scripting language, and has good support for interactive use.
Julia doesn't require you to annotate types: it infers them from the types of the arguments.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoLinks = "0ff47ea0-7a50-410d-8455-4348d5de0420"
PlutoSlides = "ccaada3e-fbb3-407e-96e9-78c3ad6e4026"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.5"
PlutoLinks = "~0.1.6"
PlutoSlides = "~0.0.1"
PlutoTeachingTools = "~0.4.6"
PlutoUI = "~0.7.71"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.7"
manifest_format = "2.0"
project_hash = "c279e25ae7e793505f60c089a7b366c8d083f65f"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "5ac098a7c8660e217ffac31dc2af0964a8c3182a"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "2.0.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.Compiler]]
git-tree-sha1 = "382d79bfe72a406294faca39ef0c3cef6e6ce1f1"
uuid = "807dbc54-b67e-4c79-8afb-eafe4df6f2e1"
version = "0.1.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4255f0032eafd6451d707a51d5f0248b8a165e4d"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.3+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "d8337622fe53c05d16f031df24daf0270e53bc64"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.10.5"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "44f93c47f9cd6c7e431f2f2091fcba8f01cd7e8f"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.10"

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
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoweredCodeUtils]]
deps = ["CodeTracking", "Compiler", "JuliaInterpreter"]
git-tree-sha1 = "73b98709ad811a6f81d84e105f4f695c229385ba"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "3.4.3"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoSlides]]
deps = ["HypertextLiteral", "PlutoUI"]
path = "C:\\Users\\metivier\\.julia\\dev\\PlutoSlides"
uuid = "ccaada3e-fbb3-407e-96e9-78c3ad6e4026"
version = "0.0.1-DEV"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "Latexify", "Markdown", "PlutoUI"]
git-tree-sha1 = "dacc8be63916b078b592806acd13bb5e5137d7e9"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.6"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "8329a3a4f75e178c11c1ce2342778bcbbbfa7e3c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.71"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "0f27480397253da18fe2c12a4ba4eb9eb208bf3d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Revise]]
deps = ["CodeTracking", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "d852eba0cc08181083a58d5eb9dccaec3129cb03"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.9.0"

    [deps.Revise.extensions]
    DistributedExt = "Distributed"

    [deps.Revise.weakdeps]
    Distributed = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

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

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "372b90fe551c019541fafc6ff034199dc19c8436"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.12"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

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
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═beab077f-c8e2-47fa-a4c6-50e0b25f8aff
# ╠═46eda44d-f80e-42d9-b935-6022136cdf02
# ╠═69e29989-1adb-4b06-b77b-5dd15997df2e
# ╠═ffb95f3b-7c02-47c5-ab02-a59fe9019f05
# ╠═538e71c7-e425-466e-b004-5e4ed4bf026c
# ╠═ea9e8cfe-402d-4d9e-95b1-147615196a79
# ╠═23c6d19f-0331-4238-9f93-796a4013fd43
# ╟─7c4d1dd2-12bb-4905-94e5-916f6c73a9f8
# ╟─98e6aefb-019b-442c-a1ac-16f9a6f5acdd
# ╠═8de786fa-ca6f-4268-ba62-1f87c5bb1ef2
# ╟─19b05b91-1e11-43dd-ae84-5e064e7466d3
# ╟─2fc6ee50-10ad-4356-a963-d646559231ae
# ╟─a8750d23-8b47-4314-970d-865673c82b21
# ╟─1d7a6946-e2a2-4352-8e74-5c077393ee49
# ╟─620103da-14c3-43ba-8d9c-25722f18426c
# ╟─c9a502d8-7856-46ca-bc47-5566c29908ed
# ╟─33bcdc05-83ed-4071-bbe9-e93753de3b92
# ╟─b19406af-c48c-4f39-9ae9-be79070b2d4a
# ╟─4eb97dfc-5791-41a2-b898-a9b1e2af2ff4
# ╟─458dd18c-1cf5-4e90-92fa-d2b15a276d0f
# ╟─8753bf78-4b72-4afe-b219-b87d96fa199f
# ╟─46cd0752-992e-43df-965e-1ecea6f280ff
# ╟─c797d46b-5a9a-4d7b-a988-d876f52e2436
# ╟─e9643cb0-5c15-423b-8b8a-5527f9896ef5
# ╟─6757b67e-21fc-4480-b284-63cf2590ca45
# ╟─8d895edb-a503-4fb2-b0e6-3c2499566eb4
# ╟─dbbe6add-dd22-4159-9c37-bf76f13c04a0
# ╟─fcb36c30-6d2e-4bd8-b472-e12ee4a54f31
# ╟─1b7bd762-fea3-4258-8aed-0e7012e99299
# ╟─86d03bd0-c671-4a89-98cc-34f55f418076
# ╟─f68c1e9f-2054-4649-a3fe-3070f4d95ac6
# ╟─eda6ca36-2c98-401b-8066-082e0cc5b04d
# ╟─2465b461-a8de-41bc-b8aa-120cc59a8698
# ╟─4c91ab1c-1b92-4d4c-8037-ce5bcd1d07e5
# ╟─8a16af2b-0b64-4f68-acb0-6528a2e2c8e7
# ╟─917f4674-002c-4f47-ad82-dfe6340423d7
# ╟─5460e927-a9cc-4187-9fe0-06ecf3eb00ef
# ╟─5783675c-4f23-4190-8ded-07927666efd2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
