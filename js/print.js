(() => {
    // Initialize only once per page (mirrors slidework.js's guard). Reload
    // the page (F5) to load an updated version of this file.
    if (window.__plutoSlidesPrintInit) return

    // Loaded right after slidework.js. Both are <script src="data:..."> tags,
    // which Pluto's script runner awaits in order, so slidework.js's IIFE has
    // run by the time this one does and the internal API is there. The guard
    // above is only claimed once that has been confirmed: setting it first
    // would make a failed lookup permanent, with no way to retry short of F5.
    const internal = window.PlutoSlides?._internal
    if (!internal) {
        console.warn("PlutoSlides print.js: slidework.js internal API not found, PDF export disabled.")
        return
    }
    window.__plutoSlidesPrintInit = true

    // The CSS definition of an inch, and the only px-per-inch under which a
    // printed page can reproduce the screen faithfully.
    const PX_PER_INCH = 96

    // --- PDF export (client-side print) ----------------------------------
    // Builds one sheet per slide (matching the live slide-mode bands, logo and
    // theme) and hands off to the browser's native print dialog ("Save as
    // PDF"), then restores the live notebook DOM. Cell content is MOVED (not
    // cloned) into the print pages: cloneNode does not copy a <canvas>'s drawn
    // bitmap, which would blank out canvas/WebGL plot outputs.
    //
    // HOW THE SIZING WORKS, because it is not obvious and the obvious version
    // is wrong.
    //
    // Everything on a slide - bands, fonts, images, plots - is sized in
    // absolute rem/px. Those sizes only keep their on-screen proportions if
    // the box they are laid out in has the on-screen pixel WIDTH. A sheet of
    // A4 is about 794 CSS px wide, so laying a slide out at sheet size makes
    // every one of those absolute sizes take roughly twice its proper share of
    // the slide: that, and nothing else, is what "the print looks zoomed"
    // means here.
    //
    // So .pdf-page is built at the live viewport's pixel size and the browser's
    // own print scaling is left to fit it to the paper. That scaling ("Fit to
    // page width" in Firefox, "Default" in Chromium) only engages when the
    // content is WIDER than the nominal page - which is exactly why nothing
    // here may be sized with 100vw. A 100vw-wide box never overflows, no
    // shrink is computed, and the whole slide is laid out at the paper's ~800px
    // width: zoomed again. Vertical viewport units are safe, since the shrink
    // factor is computed from horizontal overflow only, so .pdf-sheet uses
    // 100vh to take exactly the height of one page - which is what guarantees
    // one slide per sheet and lets the slide be centred on it.
    //
    //   .pdf-sheet   slide width x the slide height in px - exactly one page
//                (NOT 100vh: see the note where the page style is built).
//                Top-aligns the
    //                slide: a CENTRED flex item that overflows spills equally
    //                at both ends, and the top half is unreachable, which
    //                silently cuts the title band off every slide.
    //   .pdf-page    the slide: the live window's pixel WIDTH, which is what
    //                holds its content at screen proportions, by whatever
    //                height `pdf_aspect` asks for. By default that is the
    //                window's own height, so the slide has the screen's shape;
    //                the browser then fits it to the page WIDTH, and on paper
    //                that is relatively taller - A4 landscape against 16:9 -
    //                the bottom fifth of the sheet stays blank. That is the
    //                deliberate price of keeping the screen's shape, and
    //                pdf_aspect="a4" is how you trade it away.
    let printExportInProgress = false

    function buildPrintPages(options) {
        if (printExportInProgress) return
        printExportInProgress = true

        // Everything the export has to undo is declared here, before any of it
        // happens, so that one restore routine can roll back from ANY point.
        // The build below moves live cells into a container that stays detached
        // until the very end: a throw halfway through used to leave the
        // notebook with cells missing, unrecoverable short of F5 and a re-run,
        // and the printer button dead for the rest of the session.
        //
        // moves: {cell, parent, nextSibling} for every relocated cell, in
        // original order, so cleanup can put the live notebook back as it was.
        const moves = []
        let container = null
        let pageStyle = null
        let notice = null

        // rem-based sizing (the bands, .pdf-content, and Pluto's own typography)
        // resolves against the root <html> font-size, which may itself be
        // viewport-relative (vw-based / responsive). Pin it to whatever it
        // actually was at export time and restore the original (possibly empty)
        // value during cleanup, so a responsive root size cannot shift under
        // the print layout.
        const html = document.documentElement
        const savedInlineFontSize = html.style.fontSize
        html.style.fontSize = getComputedStyle(html).fontSize

        const observer = internal.mutationObserver
        const wasObserving = !!observer
        if (observer) {
            observer.disconnect()
            internal.setMutationObserver(null)
        }
        // A reapply already scheduled by the observer would still fire from its
        // timer and mark every relocated cell slide-hidden - a deck of blank
        // pages, printed without a word of warning.
        internal.cancelReapply?.()

        // Which slide to put back on screen afterwards. Taken now rather than
        // read back at cleanup time, which happens after a print dialog that may
        // have been open for minutes.
        const slideAtStart = internal.currentSlideIndex
        const fragmentAtStart = internal.currentFragmentIndex

        // Moving an <iframe> is defined to discard its browsing context and
        // navigate afresh, but a reparented frame can be left sitting at
        // about:blank instead - the src attribute never changed, so nothing
        // queues the new navigation. Assigning src is the one thing that always
        // does. Without this a webpage() embed came back from an export empty,
        // in slide mode and out of it, until its cell was re-run.
        const reloadFrames = root => root.querySelectorAll("iframe").forEach(frame => {
            const src = frame.getAttribute("src")
            if (src) frame.setAttribute("src", src)
        })

        let cleaned = false
        function cleanup() {
            if (cleaned) return
            cleaned = true
            printExportInProgress = false
            window.removeEventListener("afterprint", cleanup)
            window.removeEventListener("focus", cleanup)

            // Restore cells to their original position BEFORE removing the
            // container, otherwise they'd be deleted along with it. Must undo
            // in REVERSE order: a cell's recorded nextSibling may itself be a
            // still-relocated cell, so it only becomes a valid insertion
            // anchor once cells after it have already been put back.
            //
            // Per cell, and never throwing. The anchors were recorded before a
            // print dialog that may have been open for minutes, and Pluto keeps
            // reconciling the DOM throughout: an anchor that is no longer a
            // child of its parent makes insertBefore raise NotFoundError. That
            // used to abort the whole loop, leaving the cells not yet restored
            // - the BEGINNING of the notebook, since this runs backwards -
            // inside the container, which the next line then removed.
            const notebook = document.querySelector("pluto-notebook")
            for (let i = moves.length - 1; i >= 0; i--) {
                const { cell, parent, nextSibling } = moves[i]
                const target = parent.isConnected ? parent : notebook
                if (!target) continue
                const anchor = nextSibling?.parentNode === target ? nextSibling : null
                try {
                    target.insertBefore(cell, anchor)
                } catch (error) {
                    console.warn("PlutoSlides: could not put a cell back where it was", error)
                    try { notebook?.appendChild(cell) } catch (_) { /* give up on this one */ }
                }
            }

            // Back in the notebook, and reloaded: see reloadFrames above. This
            // runs on the cells, not on the container, which is about to go.
            moves.forEach(({ cell }) => reloadFrames(cell))

            notice?.remove()
            container?.remove()
            pageStyle?.remove()
            document.body.classList.remove("pdf-export-mode")
            if (!internal.inSlideMode) {
                document.body.classList.remove("slide-mode")
                document.body.classList.remove("h3-title-mode")
            }
            html.style.fontSize = savedInlineFontSize

            internal.gatherSlides()
            if (internal.inSlideMode) {
                internal.showSlide(slideAtStart, fragmentAtStart, false)
                if (wasObserving) internal.setMutationObserver(internal.setupMutationObserver())
            }
        }

        try {
            internal.gatherSlides()

            // Reveal all pause/fragment content everywhere. Non-current slides
            // stay hidden as whole cells anyway; showSlide() recomputes the
            // current slide's fragment display correctly during cleanup.
            document.querySelectorAll(".pause-marker").forEach(marker => {
                let next = marker.nextElementSibling
                while (next && !next.matches(".pause-marker")) {
                    next.style.display = ""
                    next = next.nextElementSibling
                }
            })

            document.querySelectorAll("pluto-cell.slide-hidden").forEach(cell =>
                cell.classList.remove("slide-hidden")
            )

            // Force the same body classes the live slide-mode uses, so all the
            // heading/chrome CSS (h1/h3 styling, hiding #pluto-nav, duplicate h2,
            // etc.) applies to the print pages unchanged, whether or not the user
            // actually toggled slide mode on screen.
            document.body.classList.add("slide-mode")
            if (internal.h3TitleMode) document.body.classList.add("h3-title-mode")
            document.body.classList.add("pdf-export-mode")

            // --- geometry, measured with slide mode already applied -----------
            // clientWidth/clientHeight rather than innerWidth/innerHeight: a
            // scrollbar belongs to the window but not to the box the content was
            // laid out in, and there is no scrollbar on paper.
            const viewportWidth = html.clientWidth
            const viewportHeight = html.clientHeight
            // Shape of a printed slide, as width / height. The default follows the
            // browser window, which is what keeps a printed slide looking like the
            // live one; `pdf_aspect` in slide_mode_settings (or a pageAspect passed
            // straight to exportPDF) overrides it with the paper's own shape, which
            // fills the sheet instead of leaving the bottom blank. The slide always
            // keeps the window's pixel WIDTH - that is what holds the content at
            // screen proportions - so only its height moves.
            const config = document.getElementById("slide-config")
            const configAspect = parseFloat(config?.getAttribute("data-pdf-aspect"))
            const pageAspect = options?.pageAspect
                ?? (configAspect > 0 ? configAspect : viewportWidth / viewportHeight)
            // `pdf_stretch` then buys extra vertical room on top of that shape,
            // without touching the width: the browser fits the slide to the page
            // WIDTH, so a taller slide at the same width prints at the same
            // horizontal scale and simply reaches further down the sheet.
            const configStretch = parseFloat(config?.getAttribute("data-pdf-stretch"))
            // The fallback matches slide_mode_settings' own `pdf_stretch`
            // default, so a deck whose settings cell is missing or still
            // rendering prints at the same shape as one that has it.
            const pageStretch = options?.pageStretch ?? (configStretch > 0 ? configStretch : 0.8)
            const slideWidth = viewportWidth
            // Never shorter than the live slide, whatever the two knobs ask for.
            // A slide is laid out at the window's WIDTH, so it is exactly as
            // tall as it is on screen, and .pdf-page clips: a shorter page does
            // not scale the slide down, it cuts the bottom off it. The default
            // "a4" over 0.8 works out at about 16:9, so on any window taller
            // than that - 16:10, 3:2, and F11 fullscreen on most laptops - the
            // last line or two of a full slide simply disappeared.
            //
            // Raising the floor cannot cost a sheet: fitted to the page WIDTH, a
            // slide fits A4 landscape as long as it is no taller in proportion
            // than the sheet (297/210 = 1.41), and a window wider than 4:3
            // already satisfies that. `pdf_stretch > 1` still works - it is only
            // shrinking below the screen that is refused, since that only ever
            // meant losing content.
            const slideHeight = Math.max(Math.round(slideWidth / pageAspect * pageStretch), viewportHeight)
            const orientation = slideWidth >= slideHeight ? "landscape" : "portrait"

            // Reproduce the live content column instead of inventing one. Its width
            // comes from the `main { max-width; margin }` rule slide_mode_settings
            // writes from its `max_width` keyword, so measure it rather than
            // hardcoding a padding here - .pdf-page is viewport sized, so these
            // pixel values carry over to it untouched.
            const liveMain = document.querySelector("main")
            const mainRect = liveMain?.getBoundingClientRect()
            const mainStyle = liveMain ? getComputedStyle(liveMain) : null
            const liveNotebook = document.querySelector("pluto-notebook")

            // Whatever Pluto puts between <main>'s content box and the top of
            // <pluto-notebook> - today its sticky 20px <preamble> plus that
            // element's 5px margin - takes up flow space on screen but is not
            // copied onto a page, so without adding it back every printed column
            // starts that much higher than the live one.
            //
            // Measured twice and the smaller taken, because neither measurement
            // is reliable alone: the live notebook's position also carries any
            // margin that collapsed up out of its first cell (a title slide's
            // `margin-top: 20vh` h1 does exactly that, and would blow the
            // measurement up), while reading the preamble assumes that element
            // is the only thing there. Collapsing can only ever push the first
            // number UP, so the minimum of the two is the real flow space.
            const preamble = liveMain?.querySelector(":scope > preamble")
            const preambleSpace = preamble
                ? preamble.offsetHeight + (parseFloat(getComputedStyle(preamble).marginTop) || 0)
                : 0
            const measuredHeadSpace = (liveNotebook && mainRect)
                ? liveNotebook.getBoundingClientRect().top - mainRect.top
                - (parseFloat(mainStyle?.paddingTop) || 0)
                - (parseFloat(getComputedStyle(liveNotebook).marginTop) || 0)
                : preambleSpace
            const headSpace = Math.max(0, Math.min(measuredHeadSpace, preambleSpace))

            // slidecss.css centres a title slide's h1 with margin-top: 20vh /
            // margin-bottom: 30vh. Vertical viewport units resolve against the
            // PRINT page, which after the browser's shrink-to-fit is a different
            // number of CSS pixels than the screen - so pin them to the values they
            // have live. Read off a real h1 rather than restating the percentages
            // here, so the two cannot drift apart.
            //
            // Copied as they are, NOT rescaled to the printed slide's height.
            // Rescaling made the title sit lower on paper than on screen
            // whenever the page was taller than the window (an A4-shaped slide
            // on a wide browser window is), and it was the one place in this
            // file where a live measurement was not simply carried over.
            const liveH1 = document.querySelector("pluto-output h1")
            const liveH1Style = liveH1 ? getComputedStyle(liveH1) : null
            const h1Margin = side => `${parseFloat(liveH1Style[side]) || 0}px`

            // slide_mode_title's block is `height: 90vh` with
            // `justify-content: space-between`, so on paper it stretched to 90%
            // of the PAGE and pushed its bottom row (the figures/logos) down into
            // the footer band. Same fix as the h1 margins: pin it to the height
            // it has on screen. Measured, so it keeps working if that 90vh
            // changes.
            const liveTitleSlide = document.querySelector(".my-title-slide")
            const titleSlideRule = liveTitleSlide
                ? `.pdf-page .my-title-slide {
                        height: ${liveTitleSlide.getBoundingClientRect().height}px !important;
                    }`
                : ""
            const h1Rule = liveH1Style
                ? `.pdf-page pluto-output h1 {
                        margin-top: ${h1Margin("marginTop")} !important;
                        margin-bottom: ${h1Margin("marginBottom")} !important;
                    }`
                : ""

            pageStyle = document.createElement("style")
            pageStyle.id = "pdf-export-page-size"
            pageStyle.textContent = `
                /* Three 'size' declarations, weakest first, because engines differ
                   in what they accept and the last one each understands wins.
                   Firefox ignores explicit @page dimensions but does honour the
                   keyword, and orientation is most of the battle there: on A4 it
                   takes the letterbox around a 16:9 slide from about half the sheet
                   down to a fifth. Chromium accepts the dimensions, and then prints
                   a sheet with exactly the screen's aspect ratio - no letterbox at
                   all. px says exactly what we mean; the inch form is there for an
                   engine that takes lengths but only physical units. */
                @page {
                    size: ${orientation};
                    size: ${slideWidth / PX_PER_INCH}in ${slideHeight / PX_PER_INCH}in;
                    size: ${slideWidth}px ${slideHeight}px;
                    margin: 0;
                }
                @media print {
                    /* Nothing at all between the sheet edge and the slide. */
                    html,
                    body,
                    #pdf-export-container {
                        margin: 0 !important;
                        padding: 0 !important;
                    }
                }

                /* The rest is outside @media print on purpose - see the note in
                   css/print.css: these pages are measured while they are still
                   only on screen, so they have to be laid out there exactly as
                   they will print. */

                /* Width in PIXELS, never 100vw - see the note at the top of
                   this file: a box sized to the viewport never overflows the
                   nominal page, the browser then computes no shrink-to-fit, and
                   the slide is laid out at paper width and looks zoomed.
                   Height in pixels too, and deliberately NOT calc(100vh) as it
                   was: the sheet clips what it cannot hold, so any disagreement
                   between what 100vh resolved to and the real printed page box
                   did not letterbox the slide, it amputated the bottom of it -
                   and the print preview did not show the damage. A sheet that
                   is exactly as tall as its slide cannot clip it. One slide
                   still takes one page, because every sheet carries
                   break-after: page; whether a slide also FITS its page is now
                   purely a question of its aspect ratio, which is what
                   pdf_aspect / pdf_stretch are for. */
                .pdf-sheet {
                    width: ${slideWidth}px;
                    height: ${slideHeight}px;
                }

                /* Both in plain pixels. Do NOT make either one depend on a
                   viewport unit: .pdf-sheet can afford 100vh for its height,
                   but the moment the SLIDE box does too, the browser stops
                   shrinking the page to fit and prints it at full width,
                   cropped and zoomed. */
                .pdf-page {
                    width: ${slideWidth}px !important;
                    height: ${slideHeight}px !important;
                }

                ${h1Rule}
                ${titleSlideRule}
            `
            // print.css's own @page/.pdf-page rules are equal specificity, so this
            // must come LATER in document order to win the cascade tie (the
            // !important above also forces the .pdf-page size, since @page itself
            // can't reliably use !important across browsers).
            // print.css is emitted inside slide_mode_settings()'s cell output,
            // i.e. somewhere inside <body> - and <head> always precedes <body>
            // in document order, so appending to document.head would actually
            // LOSE that tie. Append to the very end of <body> instead.
            document.body.appendChild(pageStyle)

            // The live footer cells, to be copied onto every page. Their child
            // nodes are cloned rather than their text re-injected as HTML:
            // footer_center=md"..." arrives as markup, and reading it back with
            // textContent and writing it with innerHTML both lost that markup
            // and swallowed anything that looked like a tag ("R&D <group>").
            const footerLeftSource = document.getElementById("slide-footer-left")
            const footerCenterSource = document.getElementById("slide-footer-center")
            const logoSource = document.getElementById("slide-logo-layer")

            // One footer cell, carrying a deep copy of whatever the live one
            // holds (text, markdown markup, a link, an image).
            const footerCell = (className, source) => {
                const cell = document.createElement("div")
                cell.className = className
                if (source) {
                    Array.from(source.childNodes).forEach(node => cell.appendChild(node.cloneNode(true)))
                }
                return cell
            }

            container = document.createElement("div")
            container.id = "pdf-export-container"

            // {index, notebook, page} per built page, for the offset pass that
            // runs once the container is in the document and can be measured.
            const pageColumns = []

            internal.slides.forEach((slideCells, i) => {
                const bands = internal.computeSlideBands(i)

                const sheet = document.createElement("div")
                sheet.className = "pdf-sheet"
                const page = document.createElement("div")
                page.className = "pdf-page"
                // Also inline, not just in the @media print rules: the offset
                // pass below measures these pages while they are merely on
                // screen, and a band only wraps the way it will on paper if the
                // box it wraps inside already has the paper's pixel width. The
                // print rules set the same numbers with !important, so this
                // changes nothing once printing starts.
                sheet.style.width = `${slideWidth}px`
                sheet.style.height = `${slideHeight}px`
                page.style.width = `${slideWidth}px`
                page.style.height = `${slideHeight}px`
                if (bands.isTitleSlide) page.classList.add("pdf-title-slide")
                sheet.appendChild(page)

                if (!bands.isTitleSlide) {
                    if (bands.showTitle) {
                        const titleBand = document.createElement("div")
                        titleBand.className = "pdf-title-band"
                        titleBand.textContent = bands.title
                        page.appendChild(titleBand)

                        const titleBandRight = document.createElement("div")
                        titleBandRight.className = "pdf-title-band-right"
                        titleBandRight.textContent = bands.titleRight
                        page.appendChild(titleBandRight)
                    }
                    if (bands.showSubtitle) {
                        const subtitleBand = document.createElement("div")
                        subtitleBand.className = "pdf-subtitle-band"
                        subtitleBand.textContent = bands.subtitle
                        page.appendChild(subtitleBand)
                    }
                }

                if (logoSource) {
                    const logoLayer = document.createElement("div")
                    logoLayer.className = "pdf-logo-layer"
                    Array.from(logoSource.children).forEach(logo => {
                        logoLayer.appendChild(logo.cloneNode(true))
                    })
                    page.appendChild(logoLayer)
                }

                const content = document.createElement("div")
                content.className = "pdf-content"
                if (mainRect) {
                    content.style.top = `${Math.max(0, mainRect.top + window.scrollY)}px`
                    // Same gutter left and right. The live column sits at
                    // `main { margin-left: 1%; margin-right: 2% }`, and on screen
                    // nobody notices the wider right gap because the scrollbar sits
                    // in it; on paper there is no scrollbar and it reads as a stray
                    // band down the right edge. So mirror the left gutter rather
                    // than copy the right margin - the column ends up ~1% wider
                    // than on screen, which is the whole of the difference.
                    const gutter = Math.max(0, mainRect.left + window.scrollX)
                    content.style.left = `${gutter}px`
                    content.style.right = `${gutter}px`
                    content.style.width = "auto"
                    content.style.paddingTop = `${(parseFloat(mainStyle.paddingTop) || 0) + headSpace}px`
                    content.style.paddingRight = mainStyle.paddingRight
                    content.style.paddingBottom = mainStyle.paddingBottom
                    content.style.paddingLeft = mainStyle.paddingLeft
                }
                // Keep the live nesting, main > pluto-notebook > pluto-cell, so
                // Pluto's own notebook/cell rules apply to the page unchanged. A
                // shallow clone rather than createElement, to inherit whatever
                // classes and attributes the live notebook carries. Its top
                // margin is per slide and depends on how tall THIS page's band
                // turns out to be, which nothing can measure until the container
                // is in the document - so it is set in a second pass below.
                const notebook = liveNotebook ? liveNotebook.cloneNode(false) : document.createElement("div")
                notebook.removeAttribute("id")
                pageColumns.push({ index: i, notebook, page })
                content.appendChild(notebook)
                slideCells.forEach(cell => {
                    moves.push({ cell, parent: cell.parentNode, nextSibling: cell.nextSibling })
                    notebook.appendChild(cell)
                })
                page.appendChild(content)

                const footerBand = document.createElement("div")
                footerBand.className = "pdf-footer-band"
                footerBand.appendChild(footerCell("pdf-footer-left", footerLeftSource))
                footerBand.appendChild(footerCell("pdf-footer-center", footerCenterSource))
                const footerRight = footerCell("pdf-footer-right", null)
                footerRight.textContent = `${i}`
                footerBand.appendChild(footerRight)
                page.appendChild(footerBand)

                container.appendChild(sheet)
            })

            document.body.appendChild(container)

            // Now that the pages are laid out, place each column the way the
            // live view does: estimate, then measure where the first visible
            // cell actually landed on ITS page and correct. Same two functions
            // slidework.js uses on screen, so the two cannot drift apart - and
            // per page, which matters because a section title that wraps onto
            // two lines makes that band half as tall again on some slides and
            // not others. A page with no band (a title slide) has nothing to
            // clear and keeps its estimate.
            //
            // Three passes rather than measuring inside one loop: all the writes
            // first, then all the reads, then the corrections. Interleaving them
            // would force a reflow per slide.
            pageColumns.forEach(({ index, notebook, page }) => {
                const band = page.querySelector(".pdf-subtitle-band")
                notebook.style.marginTop =
                    `${internal.computeNotebookOffset(index, band ? band.offsetHeight : undefined)}px`
            })
            const alignments = pageColumns.map(({ index, notebook, page }) => {
                const band = page.querySelector(".pdf-subtitle-band") || page.querySelector(".pdf-title-band")
                const cell = internal.firstVisibleCell(internal.slides[index])
                if (!band || !cell) return null
                const pageTop = page.getBoundingClientRect().top
                return {
                    notebook,
                    margin: parseFloat(notebook.style.marginTop) || 0,
                    bandBottom: band.getBoundingClientRect().bottom - pageTop,
                    contentTop: cell.getBoundingClientRect().top - pageTop,
                }
            })
            alignments.forEach(a => {
                if (!a) return
                a.notebook.style.marginTop =
                    `${internal.alignedColumnMargin(a.margin, a.bandBottom, a.contentTop)}px`
            })

            // Reparenting an <iframe> (unlike an <img>, which keeps its already
            // decoded bitmap) discards its browsing context and starts a fresh
            // navigation, so every webpage() embed on the slide is blank again
            // right after the move above - only images survived it because
            // nothing about an image's rendering is tied to DOM position. Give
            // each moved iframe a chance to reload before printing, capped so one
            // slow/unreachable embed cannot hang the export forever. Content the
            // page itself loads asynchronously after `load` fires (e.g. a widget
            // script rendering a Twitter/X embed) can still miss the print, and a
            // site that refuses to be framed at all (`X-Frame-Options` / CSP
            // `frame-ancestors`) stays blank no matter how long this waits.
            const IFRAME_RELOAD_TIMEOUT_MS = 4000
            const iframes = Array.from(container.querySelectorAll("iframe"))
            // Ask for the reload rather than trust the move to have started one
            // (see reloadFrames). Listeners go on right after: the load event
            // cannot arrive before this turn ends.
            reloadFrames(container)

            // That wait is seconds of real time, during which print.css brings
            // the container to the front of the window (see the note there: it
            // has to be genuinely visible, or the embeds never paint and print
            // blank). Say what is going on rather than let it look like the deck
            // opened by itself. Only when there is something to wait for:
            // without iframes the print starts in the same microtask and the
            // container is never painted at all.
            if (iframes.length > 0) {
                notice = document.createElement("div")
                notice.id = "pdf-export-notice"
                notice.textContent = "Preparing PDF…"
                document.body.appendChild(notice)
            }
            // `load` says the document arrived, not that it has been drawn. Two
            // frames later it has: printing in the same turn catches a frame
            // that is loaded but still blank.
            const nextFrames = () => new Promise(resolve =>
                requestAnimationFrame(() => requestAnimationFrame(resolve)))

            const framesReady = iframes.length === 0
                ? Promise.resolve()
                : Promise.race([
                    Promise.all(iframes.map(frame => new Promise(resolve => {
                        frame.addEventListener("load", resolve, { once: true })
                        frame.addEventListener("error", resolve, { once: true })
                    }))),
                    new Promise(resolve => setTimeout(resolve, IFRAME_RELOAD_TIMEOUT_MS)),
                ]).then(nextFrames)

            // "afterprint" covers the normal case; "focus" is a fallback for the
            // rare browser/OS combo where it doesn't fire after the dialog closes.
            // Both are registered only once printing actually starts: with iframes
            // on a slide the wait above lasts up to IFRAME_RELOAD_TIMEOUT_MS, and a
            // `focus` arriving in that window (alt-tab out and back) would tear the
            // export down and then print the restored notebook instead of the deck.
            framesReady.then(() => {
                notice?.remove()
                window.addEventListener("afterprint", cleanup, { once: true })
                window.addEventListener("focus", cleanup, { once: true })
                window.print()
            }).catch(error => {
                console.warn("PlutoSlides: PDF export failed while preparing the pages", error)
                cleanup()
            })
        } catch (error) {
            // Put the notebook back before letting the error out: at this point
            // part of the deck may already be sitting in a container that is
            // not even in the document.
            cleanup()
            throw error
        }
    }

    window.PlutoSlides.exportPDF = buildPrintPages
})()
