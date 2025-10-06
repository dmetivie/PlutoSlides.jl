module PlutoSlides

using HypertextLiteral: @htl, @htl_str
using PlutoUI

"""
	notebook_font_size(fontsize_html=24, fontsize_md=24)
"""
function notebook_font_size(fontsize_html=24, fontsize_md=24)
    html_font = "font-size: $(string(fontsize_html))px;"
    md_font = ".markdown{ font-size: $(string(fontsize_md))px; }"
    htl"""
    <style>
    html {
        $(html_font)
    	$(md_font)
    }
    </style>
    """
end
"""
    slidemode(; footer_left=" ", footer_center="", scale_factor=1.0, max_width="1520px")

Configure slide mode for PlutoSlides presentations.

# Arguments
- `footer_left`: Text to display in the left footer section
- `footer_center`: Text to display in the center footer section  
- `scale_factor`: Global scaling factor for all fonts (default: 1.0)
- `max_width`: Maximum width of the notebook content (default: "1520px")

# Examples
```julia
# Basic usage with default width
slidemode(footer_left="My Presentation", footer_center="Conference 2024")

# Custom width for wider screens
slidemode(footer_left="My Presentation", footer_center="Conference 2024", max_width="1800px")

# Narrow width for smaller screens or projectors
slidemode(footer_left="My Presentation", footer_center="Conference 2024", max_width="1200px")

# Full width (no limit)
slidemode(footer_left="My Presentation", footer_center="Conference 2024", max_width="100%")

# Combined with scaling
slidemode(footer_left="My Presentation", footer_center="Conference 2024", 
          scale_factor=1.2, max_width="1600px")
```
"""
function slidemode(; footer_left=" ", footer_center="", max_width="100%")
    css_code = read(joinpath(@__DIR__, "..", "css", "always.css"), String)
    css_code_slide = read(joinpath(@__DIR__, "..", "css", "slidecss.css"), String)

    # Add custom max-width styling
    custom_width = """
    main {
        max-width: $(max_width) !important;
    }
    """

    return @htl("""
     <div id="slide-config" 
          data-footer-left="$(footer_left)" 
          data-footer-center="$(footer_center)" 
          style="display: none;"></div>
     <style>
     $(css_code_slide)
     $(css_code)
     $(custom_width)
     </style>
  $(PlutoUI.LocalResource(joinpath(@__DIR__, "..", "js", "slidework.js")))
     """)
end

function button_slide_mode()
    return html"""
    <input id="toggle_slide_input" type="checkbox">
    <button onclick="toggle_slide_input.click()">⧉ Slide Mode</button>
    """
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
    figures=nothing)
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
    	font-family: "Computer Modern", "Fira Sans", "Helvetica Neue", sans-serif;
    }
    .title-band {
    	background-color: #ff7f50;
    	color: white;
    	padding: 1em 2em;
    	font-size: 2rem;
    	font-weight: bold;
    	border-radius: 1em;
    	text-align: center;
    	width: 100%;
    }
    .author {
    	font-size: 1.5rem;
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
    	font-size: 0.9em;
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
