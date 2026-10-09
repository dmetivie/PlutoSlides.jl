(() => {
    // Initialize only once per page, even if slide_mode_settings (and therefore
    // this script) is re-run. Prevents duplicate observers / desynced state.
    // Reload the page (F5) to load an updated version of this file.
    if (window.__plutoSlidesInit) return
    window.__plutoSlidesInit = true

    let slides = []
    let current = []
    let currentSlideIndex = 0
    let currentFragmentIndex = 0
    let inSlideMode = false
    let h3TitleMode = false

    // Debounce timer for observer-driven reapply.
    let reapplyTimer = null

    // Cells belonging to the slide currently on screen. Used so the observer can
    // tell a "current" cell (legitimately visible) apart from a stray cell that
    // lost its slide-hidden class after Pluto rewrote its `class` attribute.
    let currentSlideCells = new Set()

    // IDs of UI we inject ourselves. Mutations inside these must NOT trigger a
    // reapply, otherwise updating the slide number / band text would feed the
    // MutationObserver and create an endless loop.
    const OWN_UI_IDS = [
        "slide-footer-band", "slide-title-band", "slide-title-band-right",
        "slide-subtitle-band", "slide-controls", "slide-config", "slide-logo-layer"
    ]

    // Only write textContent when it actually changes. Assigning textContent
    // always replaces the text node (a childList mutation), which would
    // otherwise re-trigger the MutationObserver endlessly.
    function setText(el, value) {
        if (el && el.textContent !== value) el.textContent = value
    }

    // Same contract as setText, for the footer cells: their value is markup
    // (footer_center=md"..." arrives as rendered HTML), so it cannot go through
    // textContent.
    function setHTML(el, value) {
        if (el && el.innerHTML !== value) el.innerHTML = value
    }

    // Read the settings cell's configuration and apply it. Called on every slide
    // change, like injectLogos, so that re-running slide_mode_settings takes
    // effect immediately: the control bar is built once and these three values
    // used to be read only while building it, which froze the footer and
    // h3_title until the next F5 while colors, fonts and logos updated live.
    // Both writes are change-guarded, and the footer band is in OWN_UI_IDS, so
    // this cannot feed the MutationObserver.
    function applyConfig() {
        const config = document.getElementById("slide-config")
        if (!config) return
        h3TitleMode = config.getAttribute("data-h3-title") === "true"
        if (inSlideMode) document.body.classList.toggle("h3-title-mode", h3TitleMode)
        setHTML(document.getElementById("slide-footer-left"), config.getAttribute("data-footer-left") || "")
        setHTML(document.getElementById("slide-footer-center"), config.getAttribute("data-footer-center") || "")
    }

    // Create and insert control bar into the DOM
    function injectSlideControls() {
        if (document.getElementById("slide-controls")) return

        // Create footer band and slide indicator. The footer cells are filled by
        // applyConfig below, not here, so that a later re-run can refill them.
        const footerBand = document.createElement("div")
        footerBand.id = "slide-footer-band"
        footerBand.innerHTML = `
        <div id="slide-footer-left"></div>
        <div id="slide-footer-center"></div>
        <div id="slide-indicator">
            <span id="slide-controls">
                <button id="prev-btn">←</button>
                <button id="toggle-btn">⧉</button>
                <button id="next-btn">→</button>
                <button id="export-pdf-btn" title="Export slides to PDF">🖨</button>
            </span>
            <span id="slide-number"></span>
        </div>
    `
        document.body.appendChild(footerBand)
        applyConfig()

        const titleBand = document.createElement("div")
        titleBand.id = "slide-title-band"
        titleBand.textContent = ""
        document.body.appendChild(titleBand)

        const titleBandRight = document.createElement("div")
        titleBandRight.id = "slide-title-band-right"
        titleBandRight.textContent = ""
        document.body.appendChild(titleBandRight)

        const subtitleBand = document.createElement("div")
        subtitleBand.id = "slide-subtitle-band"
        subtitleBand.textContent = ""
        document.body.appendChild(subtitleBand)

        // Button handlers
        document.getElementById("prev-btn")?.addEventListener("click", () => changeSlide(-1))
        document.getElementById("next-btn")?.addEventListener("click", () => changeSlide(1))
        document.getElementById("toggle-btn")?.addEventListener("click", toggleSlides)
        // Defined in js/print.js (loaded right after this file); indirected
        // through the shared namespace so the two files stay decoupled.
        document.getElementById("export-pdf-btn")?.addEventListener("click", () => window.PlutoSlides.exportPDF?.())
    }

    // Relocate logo nodes rendered by slide_mode_settings (inside #slide-logo-source,
    // which lives in a pluto-cell and would be hidden in slide mode) into a fixed,
    // body-level layer. The layer is only visible in slide mode (CSS). Idempotent:
    // safe to call multiple times and after the settings cell renders late.
    function injectLogos() {
        // Cheap early-out. This is called on every slide change so that
        // re-running slide_mode_settings (very common: the settings cell is
        // usually bound to sliders / color pickers) refreshes the logos live
        // instead of leaving the previously relocated copies on screen.
        const sources = document.querySelectorAll("#slide-logo-source")
        if (sources.length === 0) return
        let layer = document.getElementById("slide-logo-layer")
        if (!layer) {
            layer = document.createElement("div")
            layer.id = "slide-logo-layer"
            document.body.appendChild(layer)
        }
        // Drop previously relocated logos so a re-run replaces them.
        layer.innerHTML = ""
        sources.forEach(source => {
            while (source.firstChild) layer.appendChild(source.firstChild)
            source.remove()
        })
    }

    let allCells = []  // declare at top scope

    // What a cell actually shows. Never cell.textContent: that also contains the
    // cell's source, because Pluto keeps the CodeMirror editor in the DOM when
    // the code is folded. A markdown cell holding nothing but a heading still
    // has its md""" ... """ in there, so once the heading text was subtracted
    // every heading cell looked like it carried content of its own.
    function outputText(cell) {
        return cell.querySelector("pluto-output")?.textContent ?? ""
    }

    // True for a cell whose output is an h2 and nothing else. Alone on a slide,
    // such a cell shows an empty page: slide mode renders every h2 in the band
    // rather than in the flow.
    function isBareH2Cell(cell) {
        const h2 = cell.querySelector("pluto-output h2")
        if (!h2) return false
        return outputText(cell).replace(h2.textContent, "").trim() === ""
    }

    // Close a slide, folding a bare h2 into the h3 slide that follows it: on its
    // own that h2 is a blank page whose only content is a band title, and the
    // h3 slide right after repeats that same title in its band anyway. The h2
    // cell is kept at the head of the merged slide (its heading is display:none
    // in slide mode, so it adds nothing visible) because computeSlideBands
    // reads the section name back out of the cells of the slide.
    function pushSlide(slide) {
        const previous = slides[slides.length - 1]
        const foldable = previous && previous.length === 1 && isBareH2Cell(previous[0]) &&
            slide[0].querySelector("pluto-output h3") !== null
        if (foldable) {
            slides[slides.length - 1] = previous.concat(slide)
        } else {
            slides.push(slide)
        }
    }

    function gatherSlides() {
        slides = []
        current = []
        allCells = Array.from(document.querySelectorAll("pluto-cell"))  // cache once

        for (const cell of allCells) {
            const hasHeading = cell.querySelector("pluto-output h1, pluto-output h2, pluto-output h3") !== null
            if (hasHeading) {
                if (current.length > 0) pushSlide(current)
                current = [cell]
            } else {
                current.push(cell)
            }
        }
        if (current.length > 0) pushSlide(current)
    }

    // Compute the title/subtitle band content for a given slide index. Shared
    // by showSlide (live display) and buildPrintPages (PDF export) so the two
    // never drift apart.
    function computeSlideBands(slideIndex) {
        const slideCells = slides[slideIndex]
        const h1Cell = slideCells.find(cell => cell.querySelector("pluto-output h1"))
        if (h1Cell) {
            return { isTitleSlide: true, title: "", titleRight: "", subtitle: "", showTitle: false, showSubtitle: false }
        }

        const h3Cell = slideCells.find(cell => cell.querySelector("pluto-output h3"))
        const isH3Slide = h3Cell !== undefined

        // Normal slides: show left band with h1, right band empty, subtitle with h2
        let title = "", subtitle = "", h2Text = "", h3Text = ""
        for (let i = slideIndex; i >= 0; i--) {
            if (!title) {
                const h1 = slides[i].find(cell => cell.querySelector("pluto-output h1"));
                if (h1) title = h1.querySelector("h1")?.textContent ?? "";
            }
            if (!subtitle) {
                const h2 = slides[i].find(cell => cell.querySelector("pluto-output h2"));
                if (h2) subtitle = h2.querySelector("h2")?.textContent ?? "";
            }
            if (!h2Text) {
                const h2 = slides[i].find(cell => cell.querySelector("pluto-output h2"));
                if (h2) h2Text = h2.querySelector("h2")?.textContent ?? "";
            }
            if (!h3Text && i === slideIndex) {
                const h3 = slides[i].find(cell => cell.querySelector("pluto-output h3"));
                if (h3) h3Text = h3.querySelector("h3")?.textContent ?? "";
            }
            if (title && subtitle && h2Text) break;
        }

        // Right band: show h2 if h3_title mode AND h3 slide
        const titleRight = (h3TitleMode && isH3Slide) ? h2Text : ""
        // Subtitle band: show h3 if h3_title mode AND h3 slide, otherwise h2
        const subtitleText = (h3TitleMode && isH3Slide) ? h3Text : subtitle

        return {
            isTitleSlide: false,
            title, titleRight, subtitle: subtitleText,
            showTitle: !!title,
            showSubtitle: !!(subtitle || h3Text),
        }
    }

    // The pause() markers of a slide, in document order.
    function pauseMarkersOf(slideCells) {
        const markers = []
        slideCells.forEach(cell => markers.push(...cell.querySelectorAll('.pause-marker')))
        return markers
    }

    // Highest fragment a slide can be shown at: a numbered pause(n) contributes
    // its own n, unnumbered pause() markers are revealed one by one and so
    // contribute their count. showSlide and changeSlide used to compute this
    // differently (count of all markers vs count of unnumbered ones, assigned vs
    // Math.max), so on a slide mixing the two forms changeSlide stepped to a
    // fragment showSlide immediately clamped back and the arrow key looked dead.
    function maxFragmentIndex(pauseMarkers) {
        const sequential = pauseMarkers.filter(m => !m.getAttribute('data-fragment')).length
        return pauseMarkers.reduce((max, marker) => {
            const fragmentNum = marker.getAttribute('data-fragment')
            return fragmentNum ? Math.max(max, parseInt(fragmentNum, 10) || 0) : max
        }, sequential)
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

        // A notebook with no h1/h2/h3 at all has no slides: leave every cell
        // visible rather than dereferencing slides[0] (which used to throw).
        // They all count as "current", or the observer would take them for
        // stray cells and hide them one by one as Pluto rewrites their class.
        if (slides.length === 0) {
            currentCells.forEach(cell => cell.classList.remove("slide-hidden"));
            currentSlideCells = new Set(currentCells);
            return;
        }
        // Cells may have been deleted since the index was picked.
        currentSlideIndex = Math.min(currentSlideIndex, slides.length - 1);

        // Pick up logos and footer/h3_title changes from a freshly re-rendered
        // settings cell. No-op (a couple of id lookups) unless that happened.
        injectLogos();
        applyConfig();

        slides[currentSlideIndex].forEach(cell => cell.classList.remove("slide-hidden"));

        // Remember which cells legitimately belong to the visible slide, so the
        // observer doesn't mistake them for stray (polluting) cells.
        currentSlideCells = new Set(slides[currentSlideIndex]);

        // Handle fragments (pause functionality)
        const slideCells = slides[currentSlideIndex]
        const pauseMarkers = pauseMarkersOf(slideCells)

        currentFragmentIndex = Math.max(0, Math.min(maxFragmentIndex(pauseMarkers), fragmentIndex))
        
        // Hide content after pause markers based on current fragment
        pauseMarkers.forEach((marker, idx) => {
            const fragmentNum = marker.getAttribute('data-fragment')
            
            if (fragmentNum) {
                // Numbered pause marker - show content if currentFragmentIndex >= fragmentNum
                const targetFragment = parseInt(fragmentNum)
                let next = marker.nextElementSibling
                while (next && !next.matches('.pause-marker')) {
                    if (currentFragmentIndex >= targetFragment) {
                        next.style.display = ''
                    } else {
                        next.style.display = 'none'
                    }
                    next = next.nextElementSibling
                }
            } else {
                // Sequential pause marker - show content if idx < currentFragmentIndex
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
            }
        })

        // Update slide number (keep same number for all fragments)
        const number = document.getElementById("slide-number");
        if (number) {
            setText(number, `${currentSlideIndex}`);
        }

        const titleBand = document.getElementById("slide-title-band");
        const titleBandRight = document.getElementById("slide-title-band-right");
        const subtitleBand = document.getElementById("slide-subtitle-band");

        const bands = computeSlideBands(currentSlideIndex);

        if (bands.isTitleSlide) {
            // Title slide: hide all bands
            titleBand.style.display = "none";
            titleBandRight.style.display = "none";
            subtitleBand.style.display = "none";
        } else {
            setText(titleBand, bands.title);
            titleBand.style.display = bands.showTitle ? "block" : "none";

            setText(titleBandRight, bands.titleRight);
            titleBandRight.style.display = bands.showTitle ? "block" : "none";

            setText(subtitleBand, bands.subtitle);
            subtitleBand.style.display = bands.showSubtitle ? "block" : "none";
        }

        // Update notebook offset
        updateNotebookOffset();
    }

    function toggleSlides() {
        inSlideMode = !inSlideMode;
        if (inSlideMode) {
            document.body.classList.add("slide-mode");
            // Pick up the current footer / h3_title before the first paint, in
            // case the settings cell re-ran since the controls were built.
            applyConfig();
            if (h3TitleMode) {
                document.body.classList.add("h3-title-mode");
            }
            // In case the settings cell rendered after initial injection.
            injectLogos();
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
            document.body.classList.remove("h3-title-mode");
            document.querySelectorAll("pluto-cell").forEach(cell =>
                cell.classList.remove("slide-hidden")
            );

            const titleBand = document.getElementById("slide-title-band");
            if (titleBand) titleBand.style.display = "none";

            const titleBandRight = document.getElementById("slide-title-band-right");
            if (titleBandRight) titleBandRight.style.display = "none";

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
            if (reapplyTimer) {
                clearTimeout(reapplyTimer);
                reapplyTimer = null;
            }
        }
    }

    function changeSlide(delta) {
        const slideCells = slides[currentSlideIndex]
        if (!slideCells) return  // notebook with no headings: nothing to move between

        const maxFragment = maxFragmentIndex(pauseMarkersOf(slideCells))

        if (delta > 0) {
            // Moving forward
            if (currentFragmentIndex < maxFragment) {
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
                    // Open the previous slide on its last fragment.
                    showSlide(prevIndex, maxFragmentIndex(pauseMarkersOf(slides[prevIndex])))
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

    // What 1rem currently is: `font_size` writes it onto <html>, and everything
    // the bands are sized with resolves against it. The fallback is the
    // `font_size` default of slide_mode_settings.
    function rootFontPx() {
        return parseFloat(getComputedStyle(document.documentElement).fontSize) || 19
    }

    // Height of the subtitle band in CSS pixels. Measured when the band is on
    // screen, so a long `##` that wraps onto a second line is accounted for;
    // derived from its style otherwise, because a display:none element measures
    // 0 -- which is the case on a title slide, and on every slide but the
    // current one while the PDF export walks the deck. Every length involved is
    // in rem/em, so either way the result tracks the page font size.
    function subtitleBandHeight() {
        const band = document.getElementById("slide-subtitle-band")
        if (!band) return 0
        if (band.offsetHeight > 0) return band.offsetHeight
        const style = getComputedStyle(band)
        const fontSize = parseFloat(style.fontSize) || 0
        // `line-height: normal` computes to the keyword, not a length.
        const lineHeight = parseFloat(style.lineHeight) || 1.2 * fontSize
        return (parseFloat(style.paddingTop) || 0) + lineHeight + (parseFloat(style.paddingBottom) || 0)
    }

    // The white space between the bottom of the band and the first line of a
    // slide. In rem, not px: what the eye compares that gap to is the text
    // beside it, so a fixed pixel gap reads roomy at 16px and cramped at 24px.
    // 1.2rem is about one line of body text, and is what `font_size=21` was
    // tuned to by hand.
    //
    // This is the ONLY number to turn if the top of a slide sits wrong: since
    // updateNotebookOffset measures the result and corrects it, the gap really
    // is this, at every font size, in the live view and in the PDF alike.
    const BAND_GAP_REM = 1.2

    // What Pluto itself puts above the first visible line: a 25px sticky
    // <preamble> + --pluto-cell-spacing (17px) before the first cell, then, when
    // that heading cell holds nothing but its heading (which slide mode renders
    // in a band, not in the flow), its 25px min-height of blank space and
    // another 17px before the cell that follows.
    const PLUTO_HEAD_PX = 25 + 17 + 25 + 17
    const PLUTO_HEAD_TEXT_PX = 25 + 17

    // Does this slide's heading cell carry content of its own below the heading?
    // Then that content, not an empty cell, is what sits at the top of the slide.
    function headingCellCarriesText(slideCells) {
        const h3Cell = slideCells.find(cell => cell.querySelector("pluto-output h3"));
        const isH3Slide = h3Cell !== undefined;

        // In h3_title mode the h3 goes into the band, so its cell is the one to
        // look at; otherwise it is the h2's. An h2 folded in from the blank
        // slide before an h3 (see pushSlide) is not content of this slide and
        // must not shift it, hence the isBareH2Cell exclusion.
        const headingCell = (h3TitleMode && isH3Slide)
            ? h3Cell
            : slideCells.find(cell =>
                cell.querySelector("pluto-output h2") && !(isH3Slide && isBareH2Cell(cell)));
        if (!headingCell) return false;

        const heading = headingCell.querySelector("pluto-output h3, pluto-output h2");
        if (!heading) return false;
        return outputText(headingCell).replace(heading.textContent.trim(), "").trim() !== "";
    }

    // An estimate of the margin that leaves BAND_GAP_REM below the band,
    // applied before the measured correction so the column does not visibly
    // jump. Only an estimate, because the PLUTO_HEAD_* pixels above do not
    // scale with the font, differ between Pluto versions, and partly collapse
    // into our own margin.
    //
    // `bandHeight` is a parameter so the PDF export (js/print.js) can pass the
    // height of the band it built for THAT page: live there is only ever one
    // band on screen, the current slide's.
    function computeNotebookOffset(slideIndex, bandHeight = subtitleBandHeight()) {
        const clearance = bandHeight + BAND_GAP_REM * rootFontPx();
        const currentSlide = slides[slideIndex];
        const headRoom = currentSlide && headingCellCarriesText(currentSlide)
            ? PLUTO_HEAD_TEXT_PX
            : PLUTO_HEAD_PX;
        return Math.max(0, clearance - headRoom);
    }

    // The first cell of a slide that actually shows something. Slide mode
    // renders h2 (and h3, in h3_title mode) headings in a band instead of in the
    // flow, so a cell holding nothing but its heading is a blank box at the top
    // of the slide: the content starts at the cell after it.
    function firstVisibleCell(slideCells) {
        return slideCells.find(cell => {
            const heading = cell.querySelector("pluto-output h1, pluto-output h2, pluto-output h3")
            if (!heading) return true
            if (heading.offsetHeight > 0) return true   // rendered in the flow, e.g. an h1
            return outputText(cell).replace(heading.textContent.trim(), "").trim() !== ""
        }) ?? slideCells[0]
    }

    // The margin that puts the first visible cell exactly BAND_GAP_REM below the
    // band, given where it landed with `currentMargin` applied. Moving a column
    // by N moves its content by N, so one correction is exact -- no iteration.
    //
    // This is what actually fixes the top of a slide, and it is deliberately
    // measurement, not arithmetic: the estimate above has to model Pluto's own
    // spacing (which is in px, changes between versions, and partly collapses
    // into our own margin), and any error there showed up as content drifting
    // into the band at one font size and floating away from it at another.
    // The estimate is still applied first so the correction is small.
    //
    // `contentTop` and `bandBottom` are measured by the caller, relative to the
    // box the slide is laid out in: the viewport live, the .pdf-page in the
    // export. The caller measures so it can batch its reads.
    function alignedColumnMargin(currentMargin, bandBottom, contentTop) {
        return Math.max(0, currentMargin + bandBottom + BAND_GAP_REM * rootFontPx() - contentTop)
    }

    // Bottom edge of the band stack on screen, or 0 when the slide carries no
    // bands at all (a title slide), in which case there is nothing to clear.
    function liveBandBottom() {
        const shown = el => el && el.offsetHeight > 0
        const subtitle = document.getElementById("slide-subtitle-band")
        const title = document.getElementById("slide-title-band")
        if (shown(subtitle)) return subtitle.getBoundingClientRect().bottom
        if (shown(title)) return title.getBoundingClientRect().bottom
        return 0
    }

    function updateNotebookOffset() {
        const notebook = document.querySelector("pluto-notebook");
        if (!notebook) return;
        // Estimate first, so the correction below is a nudge rather than a jump.
        notebook.style.marginTop = `${computeNotebookOffset(currentSlideIndex)}px`;

        const slideCells = slides[currentSlideIndex];
        const bandBottom = liveBandBottom();
        if (!slideCells || bandBottom <= 0) return;
        const cell = firstVisibleCell(slideCells);
        if (!cell) return;
        notebook.style.marginTop = `${alignedColumnMargin(
            parseFloat(notebook.style.marginTop) || 0,
            bandBottom,
            // + scrollY: the bands are position:fixed, so bandBottom is a viewport
            // constant while the cell's rect slides with the page. Measured in a
            // scrolled frame the two disagree by exactly scrollY, and the correction
            // then grew the margin by that much - which read as the slide jumping
            // back to its top on its own, a reapply or two after you scrolled down.
            // Document space (= the viewport at scroll 0) is the frame the alignment
            // is really about, and at scroll 0 this is the same number as before.
            cell.getBoundingClientRect().top + window.scrollY,
        )}px`;
    }

    // Watch for DOM changes and preserve slide state
    function setupMutationObserver() {
        if (!inSlideMode) return

        const observer = new MutationObserver((mutations) => {
            let shouldReapplySlideState = false

            for (const mutation of mutations) {
                const target = mutation.target

                // Ignore mutations inside the UI we inject ourselves (footer,
                // title/subtitle bands, controls). Updating their text must not
                // feed this observer, or we get an endless reapply loop.
                if (target.nodeType === 1 &&
                    OWN_UI_IDS.some(id => target.id === id || target.closest?.(`#${id}`))) {
                    continue
                }

                if (mutation.type === 'attributes') {
                    // Pluto rewrites a cell's `class` attribute when its run state
                    // changes (running -> done). That wipes our `slide-hidden`
                    // class, briefly revealing a cell that belongs to another
                    // slide. Re-hide it synchronously right here: the observer
                    // callback runs as a microtask (before the browser paints),
                    // so there is no visible flash. Adding the class back is a
                    // no-op once present, so this cannot loop.
                    if (target.nodeType === 1 && target.matches?.('pluto-cell') &&
                        !target.classList.contains('slide-hidden') &&
                        !currentSlideCells.has(target)) {
                        target.classList.add('slide-hidden')
                    }
                    continue
                }

                if (mutation.type !== 'childList') continue

                // Only react to structural changes around real notebook cells.
                if (target.matches?.('pluto-cell') || target.closest?.('pluto-cell') ||
                    mutation.addedNodes.length > 0 || mutation.removedNodes.length > 0) {
                    shouldReapplySlideState = true
                }
            }

            if (shouldReapplySlideState && inSlideMode) {
                // Debounce: coalesce bursts of reactive updates into one reapply.
                if (reapplyTimer) clearTimeout(reapplyTimer)
                reapplyTimer = setTimeout(() => {
                    reapplyTimer = null
                    if (inSlideMode) {
                        showSlide(currentSlideIndex, currentFragmentIndex, false)
                    }
                }, 150)
            }
        })

        // Observe the entire document for changes
        observer.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['class']
        })

        return observer
    }

    let mutationObserver = null

    // Expose a stable, global entry point so the Slide Mode button can drive the
    // toggle directly instead of relying on id lookup + listener attachment
    // (which broke whenever the button cell re-rendered).
    window.PlutoSlides = window.PlutoSlides || {}
    window.PlutoSlides.toggle = toggleSlides
    window.PlutoSlides.startInSlideMode = (slide) => startInSlideMode(slide)
    document.addEventListener("pluto-slides-toggle", () => toggleSlides())

    // Internal API consumed by js/print.js (kept separate since PDF export is
    // an optional, independently-loaded feature). Exposes live state via
    // getters/setters since the underlying variables are reassigned over time.
    window.PlutoSlides._internal = {
        gatherSlides, computeSlideBands, computeNotebookOffset, showSlide, setupMutationObserver,
        firstVisibleCell, alignedColumnMargin,
        get slides() { return slides },
        get currentSlideIndex() { return currentSlideIndex },
        get currentFragmentIndex() { return currentFragmentIndex },
        get inSlideMode() { return inSlideMode },
        get h3TitleMode() { return h3TitleMode },
        get mutationObserver() { return mutationObserver },
        setMutationObserver(o) { mutationObserver = o },
        // Lets the PDF export drop a debounced reapply before it moves cells
        // out of the notebook: a showSlide() firing once they sit in the print
        // container would mark every one of them slide-hidden, i.e. print a
        // deck of blank pages.
        cancelReapply() {
            if (reapplyTimer) {
                clearTimeout(reapplyTimer)
                reapplyTimer = null
            }
        },
    }

    // Enter slide mode once the notebook has finished rendering. Called by the
    // Slide Mode button when `start_in_slide_mode_*` is set. Waits until the
    // number of cells has stopped changing (a static export renders them
    // progressively), so every slide exists before they are gathered.
    // `slide` is the slide to open on, as shown by the slide counter (0 = first).
    function startInSlideMode(slide = 0) {
        let lastCount = -1
        let stableFor = 0
        const check = () => {
            const count = document.querySelectorAll("pluto-cell").length
            stableFor = count === lastCount ? stableFor + 1 : 0
            lastCount = count
            if (stableFor >= 3) {
                if (!inSlideMode) {
                    toggleSlides()
                    if (slide > 0) showSlide(slide, 0)
                }
            } else {
                setTimeout(check, 200)
            }
        }
        check()
    }

    function waitForPluto() {
        if (document.querySelector("pluto-cell")) {
            injectSlideControls()
            injectLogos()
        } else {
            requestAnimationFrame(waitForPluto)
        }
    }
    waitForPluto()
})()
