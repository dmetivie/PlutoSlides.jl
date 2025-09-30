### PlutoSlides pause(n) Test Example

# This example demonstrates the new pause(n) function
# which mimics beamer's \pause[n] behavior

using PlutoSlides

# Enable slide mode
slidemode()

# Test slide with numbered pauses
md"""
# Testing pause(n) Function

This content is always visible
"""

pause(2)

md"""
This appears on fragment 2
"""

pause(4)

md"""
This appears on fragment 4
"""

pause(1)

md"""
This appears on fragment 1 (so it's visible early)
"""

pause(3)

md"""
This appears on fragment 3
"""

# Test slide with mixed sequential and numbered pauses
md"""
## Mixed Pauses Example

Content that's always visible
"""

pause()  # Sequential pause (fragment 1)

md"""
Sequential pause - appears on step 1
"""

pause(5)  # Numbered pause

md"""
Numbered pause - appears on fragment 5
"""

pause()  # Sequential pause (fragment 2)

md"""
Another sequential pause - appears on step 2
"""

pause(3)  # Numbered pause

md"""
Another numbered pause - appears on fragment 3
"""

# Button to toggle slide mode
button_slide_mode()