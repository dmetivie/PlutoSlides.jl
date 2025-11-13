module PlutoSlides

using HypertextLiteral: @htl, @htl_str
using PlutoUI
using Printf
include("colors.jl")

"""
    slidemode(; h3_title=true, footer_left=" ", footer_center="", max_width="100%", font_family=nothing, font_size=nothing,
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
slidemode(footer_left="My Presentation", footer_center="Conference 2025")

# Custom width for wider screens
slidemode(footer_left="My Presentation", footer_center="Conference 2025", max_width="1800px")

# Narrow width for smaller screens or projectors
slidemode(footer_left="My Presentation", footer_center="Conference 2025", max_width="1200px")

# Set typography globally
slidemode(footer_left="My Presentation", footer_center="Conference 2025", font_family="'Fira Sans', Helvetica, Arial, sans-serif", font_size=18)

# Customize palette (set right; others derive automatically like Beamer)
slidemode(color_footer_right_bg="#ff7f50")
```
"""
function slidemode(; h3_title=true, footer_left=" ", footer_center="", max_width="100%", font_family=nothing, font_size=nothing,
    color_subtitle_bg="#3333B3", color_band_text="#ffffff",
    color_title_bg=mix_black(color_subtitle_bg, 0.50), 
    color_title_right_bg=color_subtitle_bg,
    color_controls_bg=color_subtitle_bg,
    color_footer_right_bg=color_subtitle_bg,
    color_footer_center_bg=mix_black(color_footer_right_bg, 0.25),
    color_footer_left_bg=mix_black(color_footer_right_bg, 0.50),
    color_h1="#000000", color_h3="#333333", color_h3_border=color_subtitle_bg, color_h3_bg=mix_black(color_footer_right_bg, 0.25))
    css_code = read(joinpath(@__DIR__, "..", "css", "always.css"), String)
    css_code_slide = read(joinpath(@__DIR__, "..", "css", "slidecss.css"), String)
    # Add custom max-width styling
    custom_width = """
    main {
        max-width: $(max_width) !important;
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
  $(PlutoUI.LocalResource(joinpath(@__DIR__, "..", "js", "slidework.js")))
     """)
end

function button_slide_mode()
    return @htl("""
    <span>
        <input id="toggle_slide_input" type="checkbox">
        <button>⧉ Slide Mode</button>
        
        <script>
        const span = currentScript.parentElement
        const checkbox = span.querySelector("input")
        const button = span.querySelector("button")
        
        button.addEventListener("click", () => {
            checkbox.click()
        })
        </script>
    </span>
    """)
end
function myWebPage(url::AbstractString; width="75%", ratio="55%", title="", offset=0)
    # Normalize offset to a CSS length
    offset_css = offset isa AbstractString ? offset : string(offset, "px")
    # Use a negative value to shift content up by `offset`
    neg_offset = startswith(offset_css, '-') ? offset_css : "-" * offset_css
    # Increase iframe height if offset is numeric to avoid cropping
    height_style = offset isa Real ? "calc(100% + $(abs(offset))px)" : "100%"

    return htl"""
    <div style="position: relative; padding-top: $(ratio); overflow: hidden;">
        <iframe 
            src=$(url)
            style="
                position: absolute;
                top: $(neg_offset);
                left: 0%;
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
    myTitle(; title, author, figures, footnote=nothing)

Display a formatted title slide for a Pluto presentation.

# Arguments
- `title`: String, HTML, Markdown, etc. content for the main title.
- `author`: String, HTML, Markdown, etc. content for the author and affiliation.
- `figures`: Array of `Resource` objects for logos or images.
- `footnote`: Optional Markdown or HTML footnote.

# Example
myTitle(
    title=html"<b>My Presentation</b>",
    author=html"<center>Jane Doe</center>",
    figures=[Resource("logo.png", :width => 100)]
)
"""
function myTitle(; title=nothing,
    author=nothing,
    footnote=nothing,
    figures=nothing,
    color_myTitle="#3333B3")
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
    	background-color: $(color_myTitle);
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

export myTitle, button_slide_mode, slidemode, myWebPage, notebook_font_size, pause

end
