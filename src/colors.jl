"""
    mix_black(color::AbstractString, p::Real) -> String

Return the given hex color mixed with black by fraction p in [0,1].
Supports `#rgb` and `#rrggbb`. On parse errors, returns the input color.
"""
function mix_black(c::AbstractString, p::Real)
    s = strip(c)
    s = startswith(s, "#") ? s[2:end] : s
    s = length(s) == 3 ? string(s[1], s[1], s[2], s[2], s[3], s[3]) : s
    if length(s) != 6
        return c
    end
    try
        r = parse(Int, s[1:2]; base=16)
        g = parse(Int, s[3:4]; base=16)
        b = parse(Int, s[5:6]; base=16)
        f = clamp(Float64(p), 0.0, 1.0)
        r2 = round(Int, r * (1 - f))
        g2 = round(Int, g * (1 - f))
        b2 = round(Int, b * (1 - f))
        return "#" * @sprintf("%02x%02x%02x", r2, g2, b2)
    catch
        return c
    end
end