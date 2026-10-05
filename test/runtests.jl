using PlutoSlides
using Test

using PlutoSlides: THEMES, THEME_DESCRIPTIONS, _theme_get, _settings_keywords,
    _pdf_aspect, _pdf_stretch, _css_len, _recycle, _logo_placement, _parse_hex,
    mix_black, mix_white

# The whole package is a renderer: everything below asks what HTML/CSS a call
# produces, which needs no browser and no Pluto session.
render(; kw...) = repr(MIME"text/html"(), slide_mode_settings(; kw...))

# Relative luminance / contrast ratio (WCAG), to check that text on a colored
# block stays readable.
function luminance(hex)
    rgb = _parse_hex(hex)
    isnothing(rgb) && return nothing
    c = map(rgb) do v
        s = v / 255
        s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055)^2.4
    end
    return 0.2126c[1] + 0.7152c[2] + 0.0722c[3]
end

function contrast(a, b)
    la, lb = luminance(a), luminance(b)
    (isnothing(la) || isnothing(lb)) && return nothing
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
end

# The value a keyword resolves to for a given theme, i.e. what the renderer sees.
themed(theme, key, default) = _theme_get(theme, key, default)

@testset "PlutoSlides.jl" begin

    @testset "exports" begin
        # Catches an export left behind after a rename: `export foo` for a name
        # that no longer exists is legal Julia and only fails at the call site.
        for name in names(PlutoSlides)
            @test isdefined(PlutoSlides, name)
        end
    end

    @testset "themes" begin
        allowed = _settings_keywords()
        for (name, nt) in THEMES
            for key in keys(nt)
                @test key in allowed  # a key no keyword reads is silently dropped
            end
            @test haskey(THEME_DESCRIPTIONS, name)
        end
        @test issetequal(keys(THEMES), keys(THEME_DESCRIPTIONS))
        @test issetequal(available_themes(), sort(collect(keys(THEMES))))
        @test length(available_themes(; descriptions=true)) == length(THEMES)

        # A theme may set any keyword of slide_mode_settings, and nothing else.
        @test occursin("1200px", render(theme=(max_width="1200px",)))
        @test occursin("data-h3-title=\"false\"", render(theme=(h3_title=false,)))
        @test occursin("1200px", render(theme=Dict(:max_width => "1200px")))
        @test_throws ArgumentError render(theme=(typo_key=42,))
        @test_throws ArgumentError render(theme=:NoSuchTheme)

        # An explicit keyword always wins over the theme.
        @test occursin("font-size: 30px", render(theme=:Warsaw, font_size=30))
    end

    @testset "rendering" begin
        for theme in [nothing; available_themes()]
            html = render(theme=theme)
            @test !isempty(html)
            @test occursin("slide-config", html)
            # Assets actually found and embedded, rather than silently missing.
            @test occursin("pluto-cell.slide-hidden", html)        # css/slidecss.css
            @test occursin("pluto-output>div>img", html)           # css/always.css
            @test occursin(".pdf-sheet", html)                     # css/print.css
            @test count("text/javascript", html) >= 2              # both scripts
        end
    end

    @testset "css variables" begin
        html = render(font_family="Inter, sans-serif")
        css = join(read.(joinpath.(pkgdir(PlutoSlides), "css",
                ["always.css", "slidecss.css", "print.css"]), String), "\n")
        # Every --ps-* variable the stylesheets read must either be written by
        # slide_mode_settings or carry a fallback of its own; otherwise the
        # declaration is invalid at computed-value time and silently does nothing.
        for m in eachmatch(r"var\((--ps-[a-z0-9-]+)(,)?", css)
            name, fallback = m.captures[1], m.captures[2]
            @test !isnothing(fallback) || occursin("$(name):", html)
        end
    end

    @testset "font size" begin
        rule = r"body, main, .markdown, pluto-output, html \{ font-size: ([^}]+)\}"
        @test occursin("font-size: 19px", match(rule, render()).match)
        @test occursin("font-size: 22px", match(rule, render(font_size=22)).match)
        @test isnothing(match(rule, render(font_size=nothing)))
    end

    @testset "h3 contrast" begin
        # color_h3 is dark text; the block behind it must stay light enough to
        # read (and a dark theme must darken the text instead).
        for theme in [nothing; available_themes()]
            fg = themed(theme, :color_h3, "#333333")
            subtitle = themed(theme, :color_subtitle_bg, "#3333B3")
            right = themed(theme, :color_footer_right_bg, subtitle)
            bg = themed(theme, :color_h3_bg, mix_white(right, 0.85))
            ratio = contrast(fg, bg)
            isnothing(ratio) && continue  # "transparent" and friends: no block
            @test ratio >= 3
        end
    end

    @testset "colors" begin
        @test mix_black("#3333B3", 0.25) == "#262686"
        @test mix_black("#ffffff", 1) == "#000000"
        @test mix_white("#000000", 1) == "#ffffff"
        @test mix_white("#3333B3", 0) == "#3333b3"
        @test mix_black("#abc", 0) == "#aabbcc"      # 3-digit form expands
        @test mix_black("transparent", 0.5) == "transparent"  # passed through
        @test mix_white("not a color", 0.5) == "not a color"
        @test mix_black("#3333B3", 5) == mix_black("#3333B3", 1)  # p is clamped
    end

    @testset "pdf geometry" begin
        @test _pdf_aspect("a4") ≈ 297 / 210
        @test _pdf_aspect("A4 ") ≈ 297 / 210
        @test _pdf_aspect("letter") ≈ 11 / 8.5
        @test isnothing(_pdf_aspect("screen"))
        @test isnothing(_pdf_aspect(nothing))
        @test _pdf_aspect("16:9") ≈ 16 / 9
        @test _pdf_aspect("16/9") ≈ 16 / 9
        @test _pdf_aspect((297, 210)) ≈ 297 / 210
        @test _pdf_aspect(16 / 9) ≈ 16 / 9
        @test_throws ArgumentError _pdf_aspect("nope")
        @test_throws ArgumentError _pdf_aspect(0)
        @test_throws ArgumentError _pdf_aspect(-1)
        @test_throws ArgumentError _pdf_aspect(true)   # Bool <: Real

        @test _pdf_stretch(0.8) == 0.8
        @test_throws ArgumentError _pdf_stretch(0)
        @test_throws ArgumentError _pdf_stretch(-1)

        # The wire format js/print.js reads.
        @test occursin("data-pdf-aspect=\"\"", render(pdf_aspect="screen"))
        @test occursin("data-pdf-stretch=\"0.8\"", render())
        @test occursin("data-h3-title=\"false\"", render(h3_title=false))
    end

    @testset "helpers" begin
        @test _css_len(60) == "60px"
        @test _css_len("4em") == "4em"
        @test _css_len("10%") == "10%"

        @test _recycle("x", 3) == ["x", "x", "x"]
        @test _recycle(["a", "b"], 2) == ["a", "b"]
        @test_throws ArgumentError _recycle(["a", "b"], 3)

        @test _logo_placement("top-right") == ("pos-top-right", "")
        @test_throws ArgumentError _logo_placement("middle-of-nowhere")
        @test _logo_placement((top="15%", left="4em")) == ("pos-custom", "top:15%;left:4em;")
        @test _logo_placement((2, 3)) == ("pos-custom", "left:2px;top:3px;")
        # Whichever axis is left out gets pinned, so placement never falls back
        # to the element's static position.
        @test _logo_placement((left="1em",)) == ("pos-custom", "left:1em;top:0;")
        @test_throws ArgumentError _logo_placement((nope="1em",))
    end

    @testset "webpage" begin
        @test occursin("top: -50px", repr(MIME"text/html"(), webpage("https://example.org"; offset=50)))
        # A negative offset pushes the page down instead of cropping its top.
        @test occursin("top: 50px", repr(MIME"text/html"(), webpage("https://example.org"; offset=-50)))
        @test occursin("https://example.org", repr(MIME"text/html"(), webpage("https://example.org")))
        # The old name still forwards to `webpage`.
        @test repr(MIME"text/html"(), myWebPage("https://example.org"; offset=50)) ==
              repr(MIME"text/html"(), webpage("https://example.org"; offset=50))
    end

    @testset "title slide" begin
        html = repr(MIME"text/html"(), slide_mode_title(title="T", author="A", footnote="F"))
        @test occursin("my-title-slide", html)
        @test occursin("hidden-h1", html)
        # Classes that are styled but never emitted (or vice versa) are dead CSS.
        @test occursin("footnote", html)
        @test !occursin("credit", html)
    end
end
