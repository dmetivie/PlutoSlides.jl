# Beamer-like themes for PlutoSlides.
#
# A theme is just a named bundle of the keywords accepted by
# `slide_mode_settings`. Picking one (`slide_mode_settings(theme=:Warsaw)`) is
# like Beamer's `\usetheme{Warsaw}`: it sets a coherent look, while any explicit
# keyword you pass still wins over the theme.
#
# Beamer splits this in two -- a *color* theme and an *outer* theme (where the
# bands are, what they are filled with) -- and the themes below do the same. The
# structural half is expressed with the non-color keywords of
# `slide_mode_settings`, each of which maps to one CSS variable read by both
# css/slidecss.css (presenting) and css/print.css (exporting), so a theme prints
# the way it presents:
#
#   band_overlay     a background image painted OVER every band colour, i.e. the
#                    gloss that separates a flat theme from a shaded one. Keep it
#                    a vertical (`to bottom`) gradient: the footer is three
#                    separate boxes, and only a vertical gradient repeats across
#                    them as one continuous bar.
#   band_radius      rounds the free corners of the bands (the ones that do not
#                    touch a screen edge or the seam between two bands), which is
#                    what makes a band read as a floating bar.
#   band_shadow      one shadow for the headline and the frametitle, or "none".
#   subtitle_border  a rule under the frametitle -- the substitute for a fill in
#                    themes whose frametitle has none.
#   subtitle_align   "left" (default) or "center".
#   footer_border    a hairline above the footer, likewise.
#   show_title_band  false drops the headline entirely.
#   color_page_bg /
#   color_text       the slide surface, for dark themes.
#
# Geometry is deliberately NOT part of a theme: every band keeps the height and
# padding it has in the default look, because the vertical offset at which slide
# content starts is computed from those values in js/slidework.js. Themes change
# what a band is painted with, never how much room it takes.

# Shared paint recipes, so related themes stay related.
# A bright top edge fading to a dark bottom one: Beamer's `shadow` look.
const THEME_GLOSS = "linear-gradient(to bottom, rgba(255, 255, 255, 0.22), rgba(255, 255, 255, 0.03) 45%, rgba(0, 0, 0, 0.16))"
# The same idea at a fraction of the strength, for themes that want a hint of
# depth without looking like a button.
const THEME_SHEEN = "linear-gradient(to bottom, rgba(255, 255, 255, 0.13), rgba(0, 0, 0, 0.09))"

const THEMES = Dict{Symbol,NamedTuple}(

    # --- Split bands: the default PlutoSlides look ------------------------
    # Headline cut in two (deck title | section), three-tone footer, soft
    # shadows. `:Madrid` is what you get with no theme at all.

    :Madrid => (color_subtitle_bg = "#3333B3",),

    # The historical PlutoSlides palette.
    :Coral => (color_subtitle_bg = "#ff7f50", color_title_bg = "#804028"),

    # --- Shaded: glossy bands over a deep colour, pronounced shadow -------

    :Berlin => (
        color_subtitle_bg = "#1A237E", color_title_bg = "#0D1240",
        color_title_right_bg = "#283593",
        band_overlay = THEME_GLOSS, band_shadow = "0 3px 10px rgba(0, 0, 0, 0.30)",
    ),

    :Warsaw => (
        color_subtitle_bg = "#4A148C", color_title_bg = "#2A0A50",
        color_title_right_bg = "#6A1B9A",
        band_overlay = THEME_GLOSS, band_shadow = "0 3px 10px rgba(0, 0, 0, 0.30)",
        color_h3 = "#4A148C", color_h3_bg = "#EDE7F6",
    ),

    # --- Smooth bars: rounded, flat, one colour per bar -------------------

    :Singapore => (
        color_subtitle_bg = "#1565C0",
        color_title_bg = "#0D47A1", color_title_right_bg = "#0D47A1",
        color_footer_left_bg = "#0D47A1", color_footer_center_bg = "#0D47A1",
        color_footer_right_bg = "#0D47A1",
        band_radius = "12px", band_shadow = "none", band_overlay = THEME_SHEEN,
    ),

    :Copenhagen => (
        color_subtitle_bg = "#00695C",
        color_title_bg = "#004D40", color_title_right_bg = "#00897B",
        band_radius = "8px", band_shadow = "none",
        subtitle_border = "3px solid #B2DFDB",
    ),

    # --- Plain: no fills anywhere, structure carried by rules alone -------
    # No headline, a frametitle set as coloured text on the page with a rule
    # under it, and a footer that is just small text over a hairline.

    :Boadilla => (
        show_title_band = false,
        color_subtitle_bg = "transparent", color_subtitle_text = "#1F3864",
        subtitle_border = "2px solid #1F3864", band_shadow = "none",
        color_footer_left_bg = "transparent", color_footer_center_bg = "transparent",
        color_footer_right_bg = "transparent", color_footer_text = "#5B6570",
        footer_border = "1px solid #D6DAE0",
        color_controls_bg = "#1F3864", color_h1 = "#1F3864",
        color_h3 = "#1F3864", color_h3_bg = "transparent", color_h3_border = "#1F3864",
    ),

    # The same skeleton, set in a serif face with a printer's red accent.
    :Journal => (
        font_family = "Palatino, 'Palatino Linotype', 'Book Antiqua', Georgia, 'Times New Roman', serif",
        show_title_band = false,
        color_subtitle_bg = "transparent", color_subtitle_text = "#1B1B1B",
        subtitle_border = "1px solid #8C2F1F", band_shadow = "none",
        color_footer_left_bg = "transparent", color_footer_center_bg = "transparent",
        color_footer_right_bg = "transparent", color_footer_text = "#8C2F1F",
        footer_border = "1px solid #CFC7BB",
        color_controls_bg = "#8C2F1F", color_h1 = "#1B1B1B",
        color_h3 = "#8C2F1F", color_h3_bg = "transparent", color_h3_border = "#8C2F1F",
    ),

    # --- Block: one solid colour, no headline -----------------------------

    # Frametitle centred on a single deep band, footer in the same colour.
    :Rochester => (
        show_title_band = false, subtitle_align = "center",
        color_subtitle_bg = "#6D1B3E",
        color_footer_left_bg = "#6D1B3E", color_footer_center_bg = "#6D1B3E",
        color_footer_right_bg = "#6D1B3E",
        band_shadow = "none", color_h1 = "#6D1B3E",
    ),

    # Slate, left-aligned, with a pale rule under the frametitle and a footer
    # that steps from near-black to grey.
    :Frankfurt => (
        show_title_band = false,
        color_subtitle_bg = "#37474F", subtitle_border = "3px solid #90A4AE",
        color_footer_left_bg = "#263238", color_footer_center_bg = "#37474F",
        color_footer_right_bg = "#546E7A",
        band_shadow = "none",
    ),

    # --- Dark: the slide surface itself is dark ---------------------------
    # These are the only themes that repaint the page behind the content, so
    # check any plot with a transparent background before presenting.

    :Dracula => (
        color_page_bg = "#282A36", color_text = "#F8F8F2",
        color_subtitle_bg = "#44475A", color_title_bg = "#21222C",
        color_title_right_bg = "#6272A4", color_band_text = "#F8F8F2",
        color_footer_left_bg = "#21222C", color_footer_center_bg = "#343746",
        color_footer_right_bg = "#6272A4", color_controls_bg = "#6272A4",
        subtitle_border = "2px solid #BD93F9", band_shadow = "none",
        color_h1 = "#BD93F9", color_h3 = "#F8F8F2",
        color_h3_bg = "#44475A", color_h3_border = "#BD93F9",
    ),

    :Dark => (
        color_page_bg = "#121417", color_text = "#E8EAED",
        color_subtitle_bg = "#1B1E22", color_title_bg = "#000000",
        color_title_right_bg = "#2A2E34", color_band_text = "#E8EAED",
        color_footer_left_bg = "#000000", color_footer_center_bg = "#15181B",
        color_footer_right_bg = "#2A2E34", color_controls_bg = "#2A2E34",
        subtitle_border = "2px solid #FFB300", band_shadow = "none",
        color_h1 = "#FFB300", color_h3 = "#E8EAED",
        color_h3_bg = "#1B1E22", color_h3_border = "#FFB300",
    ),
)

# One line per theme, for `available_themes(; descriptions = true)` and the
# `slide_mode_settings` docstring.
const THEME_DESCRIPTIONS = Dict{Symbol,String}(
    :Madrid => "split headline, three-tone footer, soft shadow -- the default look, in blue",
    :Coral => "the default look in the historical PlutoSlides coral palette",
    :Berlin => "glossy navy bands with a pronounced shadow",
    :Warsaw => "glossy royal purple bands with a pronounced shadow",
    :Singapore => "rounded, flat bars in one bright blue",
    :Copenhagen => "rounded flat teal bands under a pale rule",
    :Boadilla => "no fills at all: a blue frametitle over a rule, hairline footer",
    :Journal => "the same bare look set in a serif face with a printer's red accent",
    :Rochester => "no headline, frametitle centred on one solid plum band",
    :Frankfurt => "no headline, slate bands, footer stepping from near-black to grey",
    :Dracula => "dark slide surface, muted blue-grey bands, purple accents",
    :Dark => "near-black slide surface with an amber accent",
)

"""
    available_themes() -> Vector{Symbol}
    available_themes(; descriptions = true) -> Vector{Pair{Symbol,String}}

Return the names of the built-in PlutoSlides themes, usable as
`slide_mode_settings(theme = :Warsaw)`. Pass `descriptions = true` to get each
name paired with a one-line description of the look.

Themes mimic Beamer's: they set a coherent palette *and* a band style (fills,
gloss, rounding, shadow, rules) that you can still override with explicit
keywords. They come in six families:

| family | themes | look |
|:--|:--|:--|
| split | `:Madrid` (default), `:Coral` | headline cut in two, three-tone footer, soft shadow |
| shaded | `:Berlin`, `:Warsaw` | the same bands, glossy and deeply shadowed |
| smooth bars | `:Singapore`, `:Copenhagen` | flat bars with rounded free corners |
| plain | `:Boadilla`, `:Journal` | no fills: rules and coloured text only, no headline |
| block | `:Rochester`, `:Frankfurt` | no headline, one solid band for the frametitle |
| dark | `:Dracula`, `:Dark` | dark slide surface with light text |

# Examples
```julia
slide_mode_settings(theme = :Warsaw)                       # a whole look
slide_mode_settings(theme = :Warsaw, band_radius = "10px")  # ... with rounded bars
available_themes(; descriptions = true)                     # what each one looks like
```
"""
function available_themes(; descriptions::Bool=false)
    names = sort(collect(keys(THEMES)))
    return descriptions ? [t => get(THEME_DESCRIPTIONS, t, "") for t in names] : names
end

# Resolve a theme spec to a NamedTuple of overrides (or an empty NamedTuple).
# `theme` may be `nothing`, a `Symbol`, a `String`, or a `NamedTuple`/`Dict`
# (allowing fully custom inline themes).
function _resolve_theme(theme)
    isnothing(theme) && return (;)
    if theme isa NamedTuple
        return theme
    elseif theme isa AbstractDict
        return NamedTuple(Symbol(k) => v for (k, v) in theme)
    else
        key = theme isa Symbol ? theme : Symbol(theme)
        haskey(THEMES, key) || throw(ArgumentError(
            "Unknown theme $(repr(theme)). Available themes: $(available_themes())"))
        return THEMES[key]
    end
end

# Look up a single keyword from a resolved theme, falling back to `default`.
_theme_get(theme, key::Symbol, default) = get(_resolve_theme(theme), key, default)
