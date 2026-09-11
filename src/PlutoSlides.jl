module PlutoSlides

using HypertextLiteral: @htl, @htl_str
using PlutoUI
using Printf
include("colors.jl")

"""
    slide_mode_settings(; h3_title=true, footer_left=" ", footer_center="", max_width="100%", font_family=nothing, font_size=nothing,
    color_subtitle_bg="#3333B3", color_band_text="#ffffff",
    color_title_bg=mix_black(color_subtitle_bg, 0.50), 
    color_title_right_bg=color_subtitle_bg,
    color_controls_bg=color_subtitle_bg,
    color_footer_right_bg=color_subtitle_bg,
    color_footer_center_bg=mix_black(color_footer_right_bg, 0.25),
    color_footer_left_bg=mix_black(color_footer_right_bg, 0.50),
    color_h1="#000000", color_h3="#333333", color_h3_border=color_subtitle_bg, color_h3_bg=mix_black(color_footer_right_bg, 0.25))

Configure slide mode for PlutoSlides presentations.

**Arguments**
- `footer_left`: Text to display in the left footer section
- `footer_center`: Text to display in the center footer section
- `max_width`: Maximum width of the notebook content (default: "100%")
- `font_family`: Optional CSS font-family stack to use everywhere (e.g., "'Fira Sans', Helvetica, Arial, sans-serif")
- `font_size`: Optional base font size in pixels; affects rem/em-based sizing (e.g., 16, 18, 20)
- `color_*`: Palette colors for bands and headings. By default, the footer center and left colors are derived from the right color using Beamer-like mixes with black:
    - center = mix_black(right, 0.25)
    - left   = mix_black(right, 0.50)

**Examples**
```julia
# Basic usage (full width)
slide_mode_settings(footer_left="My Presentation", footer_center="Conference 2025")

# Custom width for wider screens
slide_mode_settings(footer_left="My Presentation", footer_center="Conference 2025", max_width="1800px")

# Narrow width for smaller screens or projectors
slide_mode_settings(footer_left="My Presentation", footer_center="Conference 2025", max_width="1200px")

# Set typography globally
slide_mode_settings(footer_left="My Presentation", footer_center="Conference 2025", font_family="'Fira Sans', Helvetica, Arial, sans-serif", font_size=18)

# Customize palette (set right; others derive automatically like Beamer)
slide_mode_settings(color_footer_right_bg="#ff7f50")

# Use a built-in Beamer-like theme
slide_mode_settings(theme=:Berlin, footer_left="My Presentation")

# Theme + a logo on every slide (slide mode only)
slide_mode_settings(theme=:Madrid, logo=Resource("https://julialang.org/assets/infra/logo.svg"), logo_height=50)

# Several logos with individual positions
slide_mode_settings(
    logo=[LocalResource("uni.png"), md"![](https://example.com/lab.png)"],
    logo_position=["top-right", "bottom-left"],
    logo_height=["48px", "36px"],
)

# Place a logo by hand instead of using an anchor
slide_mode_settings(logo="logo.png", logo_position=(top="12%", right="3em"))

# Dead-center, using transform to compensate for the logo's own size
slide_mode_settings(
    logo="watermark.png",
    logo_position=(top="50%", left="50%", transform="translate(-50%, -50%)"),
    logo_opacity=0.15,
)
```
"""
    logo=nothing, logo_position="top-right", logo_height=nothing, logo_opacity=nothing,
    logo_offset_x=nothing, logo_offset_y=nothing,
    css_code = read(joinpath(@__DIR__, "..", "css", "always.css"), String)
    css_code_slide = read(joinpath(@__DIR__, "..", "css", "slidecss.css"), String)
    # Add custom max-width styling
    custom_width = """
    main {
        max-width: $(max_width) !important;
        margin-left: 1%;
        margin-right: 2% !important;
    }
    """

    # Optional font overrides via CSS variables
    custom_fonts = """
    :root {
        --ps-color-title-bg: $(color_title_bg);
        --ps-color-title-right-bg: $(color_title_right_bg);
        --ps-color-subtitle-bg: $(color_subtitle_bg);
        --ps-color-band-text: $(color_band_text);
        --ps-color-controls-bg: $(color_controls_bg);
        --ps-color-footer-left-bg: $(color_footer_left_bg);
        --ps-color-footer-center-bg: $(color_footer_center_bg);
        --ps-color-footer-right-bg: $(color_footer_right_bg);
        --ps-color-h1: $(color_h1);
        --ps-color-h3: $(color_h3);
        --ps-color-h3-border: $(color_h3_border);
        --ps-color-h3-bg: $(color_h3_bg);
    }
    $(isnothing(font_family) ? "" : "body, main, .markdown, pluto-output, html, h1, h2, h3, h4, h5, h6, #slide-footer-band, .my-title-slide { font-family: $(font_family) !important; }")
    $(isnothing(font_size) ? "" : "body, main, .markdown, pluto-output, html { font-size: $(font_size)px; }")
    """

    logo_block = _logo_block(; logo, logo_position, logo_height, logo_opacity, logo_offset_x, logo_offset_y)

    return @htl("""
     <div id="slide-config" 
          data-footer-left="$(footer_left)" 
          data-footer-center="$(footer_center)"
          data-h3-title="$(h3_title)" 
          style="display: none;"></div>
     <style>
     $(css_code_slide)
     $(css_code)
     $(custom_width)
     $(custom_fonts)

     </style>
  $(logo_block)
  $(PlutoUI.LocalResource(joinpath(@__DIR__, "..", "js", "slidework.js")))
     """)
end

# Normalize a value to a CSS length: numbers become pixels, everything else is
# passed through unchanged (so "60px", "4em", "10%" all work).
_css_len(x::Real) = string(x, "px")
_css_len(x) = string(x)

# Treat a single logo / option as a 1-element vector; pass arrays through.
_as_vec(x) = x isa AbstractArray ? collect(x) : Any[x]

# Recycle a scalar option to length `n` so per-logo options can also be given as
# a single shared value.
function _recycle(x, n)
    v = _as_vec(x)
    length(v) == n && return v
    length(v) == 1 && return fill(v[1], n)
    throw(ArgumentError("expected 1 or $n values, got $(length(v))"))
end

# Normalize one logo to content that actually renders.
#
# `PlutoUI.Resource` guesses its MIME type from the file *extension*, so a
# perfectly good image URL without one (e.g. "https://example.org/logo", or a
# CMS route that serves a PNG) falls back to an empty `<data>` element and the
# logo silently disappears. To avoid that trap, plain strings and resources with
# an unusable MIME type are rendered as a plain `<img>`; everything else
# (Markdown, raw HTML, an inline `<svg>`, an `<iframe>`, ...) is passed through
# untouched.
_is_media_mime(m) = !isnothing(m) && any(p -> startswith(string(m), p), ("image/", "video/", "audio/"))

_logo_content(x::AbstractString) = isfile(x) ? _logo_content(PlutoUI.LocalResource(x)) : @htl("<img src=$(x)>")
_logo_content(r::PlutoUI.Resource) = _is_media_mime(r.mime) ? r : @htl("<img src=$(r.src)>")
_logo_content(x) = x

# Predefined placement anchors; each has a matching `.ps-logo.pos-*` rule in
# css/slidecss.css and is nudged by `logo_offset_x` / `logo_offset_y`.
const LOGO_ANCHORS = ("top-right", "top-left", "bottom-right", "bottom-left",
    "top-center", "bottom-center")

# Resolve one `logo_position` entry into (css class, inline placement rules).
#
# A `String` picks one of `LOGO_ANCHORS`. A `NamedTuple` / `Dict` / `(x, y)` tuple
# instead places the logo by hand: `top`, `bottom`, `left`, `right` and `transform`
# are written straight into the element's style. Manual placement is absolute, so
# `logo_offset_x` / `logo_offset_y` (which only nudge an anchor) no longer apply --
# put the offset in the coordinate itself.
function _logo_placement(p::AbstractString)
    s = String(p)
    s in LOGO_ANCHORS || throw(ArgumentError(
        "Unknown logo_position $(repr(s)). Use one of $(LOGO_ANCHORS), or place the " *
        "logo by hand with e.g. logo_position = (top = \"15%\", left = \"4em\")."))
    return ("pos-$(s)", "")
end

function _logo_placement(p::Union{NamedTuple,AbstractDict})
    allowed = (:top, :bottom, :left, :right, :transform)
    rules = IOBuffer()
    seen = Symbol[]
    for (k, v) in pairs(p)
        key = Symbol(k)
        key in allowed || throw(ArgumentError(
            "Unknown logo_position key $(repr(key)). Allowed keys: $(allowed)."))
        isnothing(v) && continue
        push!(seen, key)
        print(rules, key, ":", key === :transform ? string(v) : _css_len(v), ";")
    end
    # Pin whichever axis the caller left out, so placement never falls back to the
    # element's static position. Only one edge per axis is ever emitted: setting
    # both `top` and `bottom` on a fixed-height box makes the browser drop one.
    (:top in seen || :bottom in seen) || print(rules, "top:0;")
    (:left in seen || :right in seen) || print(rules, "left:0;")
    return ("pos-custom", String(take!(rules)))
end

# `(x, y)` shorthand for `(left = x, top = y)`.
_logo_placement(p::Tuple{Any,Any}) = _logo_placement((left=p[1], top=p[2]))

# Build the hidden logo holder. Each logo is arbitrary HTML-able content
# (`Resource`, `LocalResource`, `md"..."`, raw HTML, ...). slidework.js relocates
# these nodes into a fixed `#slide-logo-layer` that is only visible in slide mode.
function _logo_block(; logo=nothing, logo_position="top-right", logo_height=nothing,
    logo_opacity=nothing, logo_offset_x=nothing, logo_offset_y=nothing)
    isnothing(logo) && return nothing
    logos = _as_vec(logo)
    n = length(logos)
    pos = _recycle(logo_position, n)
    hgt = _recycle(logo_height, n)
    opa = _recycle(logo_opacity, n)
    ox = _recycle(logo_offset_x, n)
    oy = _recycle(logo_offset_y, n)
    items = map(1:n) do i
        cls, placement = _logo_placement(pos[i])
        style = string(
            placement,
            isnothing(hgt[i]) ? "" : "--ps-logo-height:$(_css_len(hgt[i]));",
            isnothing(opa[i]) ? "" : "--ps-logo-opacity:$(opa[i]);",
            isnothing(ox[i]) ? "" : "--ps-logo-x:$(_css_len(ox[i]));",
            isnothing(oy[i]) ? "" : "--ps-logo-y:$(_css_len(oy[i]));",
        )
        @htl("""<div class="ps-logo $(cls)" style="$(style)">$(_logo_content(logos[i]))</div>""")
    end
    return @htl("""<div id="slide-logo-source" style="display:none">$(items...)</div>""")
end

function slide_mode_button()
    return @htl("""
    <span class="pluto-slides-toggle">
        <button>⧉ Slide Mode</button>

        <script>
        const span = currentScript.parentElement
        const button = span.querySelector("button")

        // Drive the toggle through the stable global exposed by slidework.js.
        // This handler is re-attached every time the cell renders, so the button
        // keeps working even after the cell is re-executed (no F5 needed).
        button.addEventListener("click", () => {
            const tryToggle = (tries) => {
                if (window.PlutoSlides && typeof window.PlutoSlides.toggle === "function") {
                    window.PlutoSlides.toggle()
                } else if (tries > 0) {
                    // slidework.js may still be loading; retry briefly.
                    setTimeout(() => tryToggle(tries - 1), 50)
                } else {
                    // Last resort: notify whenever the script finishes loading.
                    document.dispatchEvent(new CustomEvent("pluto-slides-toggle"))
                }
            }
            tryToggle(20)
        })
        </script>
    </span>
    """)
end

function myWebPage(url::AbstractString; width="75%", ratio="50%", title="", offset=0, center=true)
    # Normalize offset to a CSS length
    offset_css = offset isa AbstractString ? offset : string(offset, "px")
    # Use a negative value to shift content up by `offset`
    neg_offset = startswith(offset_css, '-') ? offset_css : "-" * offset_css
    # Increase iframe height if offset is numeric to avoid cropping
    height_style = offset isa Real ? "calc(100% + $(abs(offset))px)" : "100%"
    # Center horizontally using left+transform, or align to left edge
    left_style = center ? "50%" : "0%"
    transform_style = center ? "translateX(-50%)" : "none"

    return htl"""
    <div style="position: relative; padding-top: $(ratio); overflow: hidden;">
        <iframe 
            src=$(url)
            style="
                position: absolute;
                top: $(neg_offset);
                left: $(left_style);
                transform: $(transform_style);
                width: $(width);
                height: $(height_style);
                border: none;
            "
            title=$(title)
            allowfullscreen>
        </iframe> 
    </div>
    """
end

"""
    slide_mode_title(; title, author, figures, footnote=nothing)

Display a formatted title slide for a Pluto presentation.

# Arguments
- `title`: String, HTML, Markdown, etc. content for the main title.
- `author`: String, HTML, Markdown, etc. content for the author and affiliation.
- `figures`: Array of `Resource` objects for logos or images.
- `footnote`: Optional Markdown or HTML footnote.

# Example
slide_mode_title(
    title=html"<b>My Presentation</b>",
    author=html"<center>Jane Doe</center>",
    figures=[Resource("logo.png", :width => 100)]
)
"""
function slide_mode_title(; title=nothing,
    author=nothing,
    footnote=nothing,
    figures=nothing,
    color="#3333B3")
    if isa(figures, AbstractArray)
        figs = [@htl("<div>$f</div>") for f in figures]
    else
        figs = isnothing(figures) ? nothing : [@htl("<div>$figures</div>")]
    end
    nfigs = isnothing(figs) ? 1 : max(length(figs), 1)
    figures_block = isnothing(figs) ? nothing : @htl("<div class='figures'>$(figs...)</div>")
    author_block = isnothing(author) ? nothing : @htl("<div class='author'>$author</div>")
    footnote_block = isnothing(footnote) ? nothing : @htl("<div class='footnote'>$footnote</div>")
    return @htl("""
    <style>
    .my-title-slide {
    	display: flex;
    	flex-direction: column;
    	align-items: center;
    	justify-content: space-between;
    	height: 90vh;
    	padding: 2em;
    }
    .title-band {
    	background-color: $(color);
    	color: var(--ps-color-band-text, white);
    	padding: 1em 2em;
    	font-size: 2rem;
    	font-weight: bold;
    	border-radius: 1em;
    	text-align: center;
    	width: 100%;
    }
    .author {
    	font-size: 1.25rem;
    	margin-top: 1em;
    	color: #444;
    }
    .figures {
    	display: flex;
    	justify-content: space-around;
    	gap: 1em;
    	width: 100%;
    	margin-top: auto;
    	margin-bottom: 2em;
    	flex-wrap: wrap;
    }
    .figures div {
    	background: none;
    	height: 150px;
    	display: flex;
    	align-items: center;
    	justify-content: center;
    	font-size: 1em;
    	flex: 1 1 calc(100% / $(nfigs) - 1em);
    	min-width: 140px;
    }
    .credit {
    	font-size: 0.9rem;
    	color: #888;
    	margin-top: 1em;
    }
    .hidden-h1 { display: none; }
    </style>
    <h1 class="hidden-h1">$title</h1>
    <div class="my-title-slide">
    	<div class="title-band">$title</div>
    	$author_block
    	$figures_block
    	$footnote_block
    </div>
    """)
end

"""
	PlutoUI.LocalResource(dir::AbstractString, path::AbstractString, html_attributes::Pair...)
Search recursively for `path` inside directory `dir` (including all subdirectories) and return `PlutoUI.LocalResource(joinpath(found_dir, path))` for the first match.
Throws an ArgumentError if not found.
Remember that to share your notebook it is best to have online resources.
"""
function PlutoUI.LocalResource(dir::AbstractString, path::AbstractString, html_attributes::Pair...)
    # Quick direct check (path may already include subfolders)
    direct = joinpath(dir, path)
    if isfile(direct)
        return PlutoUI.LocalResource(direct)
    end

    roots = String[]
    hits = Bool[]
    for (root, _, _) in walkdir(dir)
        push!(roots, root)
        push!(hits, isfile(joinpath(root, path)))
    end

    idx = findfirst(hits)
    if isnothing(idx)
        throw(ArgumentError("File '$path' not found under directory '$dir'"))
    end

    return PlutoUI.LocalResource(joinpath(roots[idx], path), html_attributes...)
end

"""
    pause()

Creates an invisible pause marker for incremental slide reveals.
Use this between content elements in your Pluto cells to create step-by-step reveals.
"""
function pause()
    return @htl("<span class='pause-marker' style='display:none;'></span>")
end

"""
    pause(n::Integer)

Creates an invisible numbered pause marker for incremental slide reveals.
Mimics beamer's \\pause[n] behavior - content after this marker will be visible
starting from fragment n.

# Arguments
- `n`: Fragment number (1-based) when this content should become visible

# Example
```julia
md"First content is always visible"
pause(2)
md"This appears on fragment 2"
pause(4) 
md"This appears on fragment 4"
```
"""
function pause(n::Integer)
    return @htl("<span class='pause-marker' data-fragment='$(n)' style='display:none;'></span>")
end

export slide_mode_title, slide_mode_button, slide_mode_settings, myWebPage, notebook_font_size, pause

end
