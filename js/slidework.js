(() => {
    let slides = []
    let current = []
    let currentSlideIndex = 0
    let currentFragmentIndex = 0
    let inSlideMode = false

    // Create and insert control bar into the DOM
    function injectSlideControls() {
        if (document.getElementById("slide-controls")) return

        // Get footer configuration from data attributes
        const config = document.getElementById("slide-config")
        const footerLeft = config?.getAttribute("data-footer-left") || ""
        const footerCenter = config?.getAttribute("data-footer-center") || ""

        // Create footer band and slide indicator
        const footerBand = document.createElement("div")
        footerBand.id = "slide-footer-band"
        footerBand.innerHTML = `
        <div id="slide-footer-left"> ${footerLeft}</div>
        <div id="slide-footer-center"> ${footerCenter}</div>
        <div id="slide-indicator">
            <span id="slide-controls">
                <button id="prev-btn">←</button>
                <button id="toggle-btn">⧉</button>
                <button id="next-btn">→</button>
            </span>
            <span id="slide-number"></span>
        </div>
    `
        document.body.appendChild(footerBand)

        const titleBand = document.createElement("div")
        titleBand.id = "slide-title-band"
        titleBand.textContent = ""
        document.body.appendChild(titleBand)

        const subtitleBand = document.createElement("div")
        subtitleBand.id = "slide-subtitle-band"
        subtitleBand.textContent = ""
        document.body.appendChild(subtitleBand)

        // Button handlers
        document.getElementById("prev-btn")?.addEventListener("click", () => changeSlide(-1))
        document.getElementById("next-btn")?.addEventListener("click", () => changeSlide(1))
        document.getElementById("toggle-btn")?.addEventListener("click", toggleSlides)
    }

    let allCells = []  // declare at top scope

    function gatherSlides() {
        slides = []
        current = []
        allCells = Array.from(document.querySelectorAll("pluto-cell"))  // cache once

        for (const cell of allCells) {
            const hasHeading = cell.querySelector("pluto-output h1, pluto-output h2, pluto-output h3") !== null
            if (hasHeading) {
                if (current.length > 0) slides.push(current)
                current = [cell]
            } else {
                current.push(cell)
            }
        }
        if (current.length > 0) slides.push(current)
    }

    function showSlide(index, fragmentIndex = 0, shouldScroll = true) {
        const newSlideIndex = Math.max(0, Math.min(slides.length - 1, index));
        
        // Only scroll to top if we're actually changing slides
        if (shouldScroll && newSlideIndex !== currentSlideIndex) {
            window.scrollTo({ top: 0 });
        }
        
        currentSlideIndex = newSlideIndex;

        // Always get fresh cell references to handle re-executed cells
        const currentCells = Array.from(document.querySelectorAll("pluto-cell"));
        currentCells.forEach(cell => cell.classList.add("slide-hidden"));

        // Re-gather slides with fresh references if needed
        gatherSlides();
        
        slides[currentSlideIndex].forEach(cell => cell.classList.remove("slide-hidden"));

        // Handle fragments (pause functionality)
        const slideCells = slides[currentSlideIndex]
        const pauseMarkers = []
        slideCells.forEach(cell => {
            const markers = cell.querySelectorAll('.pause-marker')
            pauseMarkers.push(...markers)
        })
        
        currentFragmentIndex = Math.max(0, Math.min(pauseMarkers.length, fragmentIndex))
        
        // Hide content after pause markers based on current fragment
        pauseMarkers.forEach((marker, idx) => {
            if (idx >= currentFragmentIndex) {
                let next = marker.nextElementSibling
                while (next && !next.matches('.pause-marker')) {
                    next.style.display = 'none'
                    next = next.nextElementSibling
                }
            } else {
                let next = marker.nextElementSibling
                while (next && !next.matches('.pause-marker')) {
                    next.style.display = ''
                    next = next.nextElementSibling
                }
            }
        })

        // Update slide number (keep same number for all fragments)
        const number = document.getElementById("slide-number");
        if (number) {
            number.textContent = `${currentSlideIndex}`;            
        }

        const titleBand = document.getElementById("slide-title-band");
        const subtitleBand = document.getElementById("slide-subtitle-band");

        const h1Cell = slides[currentSlideIndex].find(cell =>
            cell.querySelector("pluto-output h1")
        );

        if (h1Cell) {
            titleBand.style.display = "none";
            subtitleBand.style.display = "none";
        } else {
            let title = "", subtitle = "";
            for (let i = currentSlideIndex; i >= 0; i--) {
                if (!title) {
                    const h1 = slides[i].find(cell => cell.querySelector("pluto-output h1"));
                    if (h1) title = h1.querySelector("h1")?.textContent ?? "";
                }
                if (!subtitle) {
                    const h2 = slides[i].find(cell => cell.querySelector("pluto-output h2"));
                    if (h2) subtitle = h2.querySelector("h2")?.textContent ?? "";
                }
                if (title && subtitle) break;
            }

            titleBand.textContent = title;
            titleBand.style.display = title ? "block" : "none";
            subtitleBand.textContent = subtitle;
            subtitleBand.style.display = subtitle ? "block" : "none";
        }

        // Update notebook offset
        updateNotebookOffset();
    }

    function toggleSlides() {
        inSlideMode = !inSlideMode;
        if (inSlideMode) {
            document.body.classList.add("slide-mode");
            gatherSlides();
            showSlide(0, 0);

            // Update notebook offset
            updateNotebookOffset();

            // Show footer band when re-entering slide mode
            const footerBand = document.getElementById("slide-footer-band");
            if (footerBand) footerBand.style.display = "flex";

            // Start watching for DOM changes
            mutationObserver = setupMutationObserver();
        } else {
            document.body.classList.remove("slide-mode");
            document.querySelectorAll("pluto-cell").forEach(cell =>
                cell.classList.remove("slide-hidden")
            );

            const titleBand = document.getElementById("slide-title-band");
            if (titleBand) titleBand.style.display = "none";

            const subtitleBand = document.getElementById("slide-subtitle-band");
            if (subtitleBand) subtitleBand.style.display = "none";

            const footerBand = document.getElementById("slide-footer-band");
            if (footerBand) footerBand.style.display = "none";

            // Reset notebook margin
            const notebook = document.querySelector("pluto-notebook");
            if (notebook) notebook.style.marginTop = "0";

            // Stop watching for DOM changes
            if (mutationObserver) {
                mutationObserver.disconnect();
                mutationObserver = null;
            }
        }
    }

    function changeSlide(delta) {
        const slideCells = slides[currentSlideIndex]
        const pauseMarkers = []
        slideCells.forEach(cell => {
            const markers = cell.querySelectorAll('.pause-marker')
            pauseMarkers.push(...markers)
        })
        
        if (delta > 0) {
            // Moving forward
            if (currentFragmentIndex < pauseMarkers.length) {
                // Next fragment in current slide
                showSlide(currentSlideIndex, currentFragmentIndex + 1)
            } else {
                // Next slide
                showSlide(currentSlideIndex + 1, 0)
            }
        } else {
            // Moving backward  
            if (currentFragmentIndex > 0) {
                // Previous fragment in current slide
                showSlide(currentSlideIndex, currentFragmentIndex - 1)
            } else {
                // Previous slide (go to its last fragment)
                const prevIndex = currentSlideIndex - 1
                if (prevIndex >= 0) {
                    const prevSlideCells = slides[prevIndex]
                    const prevPauseMarkers = []
                    prevSlideCells.forEach(cell => {
                        const markers = cell.querySelectorAll('.pause-marker')
                        prevPauseMarkers.push(...markers)
                    })
                    showSlide(prevIndex, prevPauseMarkers.length)
                }
            }
        }
    }

    document.addEventListener("keydown", e => {
        if (!inSlideMode) return;

        // Ignore key events if focus is inside an input, textarea, or contentEditable element
        const active = document.activeElement;
        const isTyping = active && (
            active.tagName === "TEXTAREA" ||
            active.tagName === "INPUT" ||
            active.isContentEditable
        );
        if (isTyping) return;

        if (e.key === "ArrowRight" || e.key === "PageDown") {
            e.preventDefault();
            changeSlide(1);
        } else if (e.key === "ArrowLeft" || e.key === "PageUp") {
            e.preventDefault();
            changeSlide(-1);
        } else if (e.key === "Escape") {
            toggleSlides();
        }
    })

    function updateNotebookOffset() {
        const notebook = document.querySelector("pluto-notebook");
        const subtitleBand = document.getElementById("slide-subtitle-band");

        // Get the heights of the title and subtitle bands
        const subtitleHeight = 15//subtitleBand?.offsetHeight || 0;

        // Check if the current slide's subtitle contains only a subtitle or additional text
        const currentSlide = slides[currentSlideIndex];
        const h2Cell = currentSlide.find(cell => cell.querySelector("pluto-output h2"));
        let additionalOffset = 0;

        if (h2Cell) {
            const h2Content = h2Cell.querySelector("h2").textContent.trim();
            const otherContent = h2Cell.textContent.replace(h2Content, "").trim();

            // If there's additional text beyond the subtitle, add extra offset
            if (otherContent) {
                additionalOffset = 2.5 * 16; // Example: 2.5em in pixels (assuming 16px base font size)
            }
        }

        // Calculate the total offset
        const totalOffset = additionalOffset + subtitleHeight;

        // Apply the offset as a margin to the notebook
        if (notebook) {
            notebook.style.marginTop = `${totalOffset}px`;
        }
    }


    // Observe the Pluto-generated button's toggle
    function watchPlutoToggleInput() {
        const checkbox = document.querySelector("#toggle_slide_input")
        if (!checkbox) return

        checkbox.addEventListener("change", () => {
            toggleSlides()
        })
    }

    // setTimeout(() => {
    //     injectSlideControls()
    //     watchPlutoToggleInput()
    // }, 500)

    // Watch for DOM changes and preserve slide state
    function setupMutationObserver() {
        if (!inSlideMode) return

        const observer = new MutationObserver((mutations) => {
            let shouldReapplySlideState = false
            
            mutations.forEach((mutation) => {
                // Check if any pluto-cell was added, removed, or its content changed
                if (mutation.type === 'childList') {
                    const target = mutation.target
                    if (target.matches('pluto-cell') || target.closest('pluto-cell') || 
                        mutation.addedNodes.length > 0 || mutation.removedNodes.length > 0) {
                        shouldReapplySlideState = true
                    }
                }
            })

            if (shouldReapplySlideState && inSlideMode) {
                // Reapply current slide state without scrolling
                requestAnimationFrame(() => {
                    if (inSlideMode) {
                        showSlide(currentSlideIndex, currentFragmentIndex, false)
                    }
                })
            }
        })

        // Observe the entire document for changes
        observer.observe(document.body, {
            childList: true,
            subtree: true
        })

        return observer
    }

    let mutationObserver = null

    function waitForPluto() {
        if (document.querySelector("pluto-cell")) {
            injectSlideControls()
            watchPlutoToggleInput()
        } else {
            requestAnimationFrame(waitForPluto)
        }
    }
    waitForPluto()
})()
