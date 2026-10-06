# Parse "#rgb" / "#rrggbb" into (r, g, b), or `nothing` if it is not a hex color
# (a named color, `"transparent"`, a gradient, ...), in which case the caller
# returns the input untouched.
function _parse_hex(c::AbstractString)
    s = strip(c)
    s = startswith(s, "#") ? s[2:end] : s
    s = length(s) == 3 ? string(s[1], s[1], s[2], s[2], s[3], s[3]) : s
    length(s) == 6 || return nothing
    try
        return (parse(Int, s[1:2]; base=16), parse(Int, s[3:4]; base=16), parse(Int, s[5:6]; base=16))
    catch
        return nothing
    end
end

# Mix a color towards `target` (a black or white (r, g, b)) by fraction p.
function _mix(c::AbstractString, target::NTuple{3,Int}, p::Real)
    rgb = _parse_hex(c)
    isnothing(rgb) && return c
    f = clamp(Float64(p), 0.0, 1.0)
    r, g, b = (round(Int, x + (t - x) * f) for (x, t) in zip(rgb, target))
    return "#" * @sprintf("%02x%02x%02x", r, g, b)
end

"""
    mix_black(color::AbstractString, p::Real) -> String

Return the given hex color mixed with black by fraction p in [0,1].
Supports `#rgb` and `#rrggbb`. On parse errors, returns the input color.
"""
mix_black(c::AbstractString, p::Real) = _mix(c, (0, 0, 0), p)

"""
    mix_white(color::AbstractString, p::Real) -> String

Return the given hex color mixed with white by fraction p in [0,1], i.e. a tint
of it: `p = 1` is white, `p = 0` is the color itself. The counterpart of
[`mix_black`](@ref), used for the pale block behind `h3` headings.
Supports `#rgb` and `#rrggbb`. On parse errors, returns the input color.
"""
mix_white(c::AbstractString, p::Real) = _mix(c, (255, 255, 255), p)
