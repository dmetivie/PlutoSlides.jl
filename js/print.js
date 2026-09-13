(() => {
    // Initialize only once per page (mirrors slidework.js's guard). Reload
    // the page (F5) to load an updated version of this file.
    if (window.__plutoSlidesPrintInit) return
    window.__plutoSlidesPrintInit = true

    // Loaded right after slidework.js, whose IIFE has already run by the time
    // this script executes (inline scripts run in document order), so the
    // internal API is available synchronously.
    const internal = window.PlutoSlides?._internal
    if (!internal) {
        console.warn("PlutoSlides print.js: slidework.js internal API not found, PDF export disabled.")
        return
    }

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
    //   .pdf-sheet   slide width x 100vh - exactly one page. Top-aligns the
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
        const pageStretch = options?.pageStretch ?? (configStretch > 0 ? configStretch : 1)
        const slideWidth = viewportWidth
        const slideHeight = Math.round(slideWidth / pageAspect * pageStretch)
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

        // slidecss.css centres a title slide's h1 with margin-top: 20vh /
        // margin-bottom: 30vh. Vertical viewport units resolve against the
        // PRINT page, which after the browser's shrink-to-fit is a different
        // number of CSS pixels than the screen - so pin them to the values they
        // have live. Read off a real h1 rather than restating the percentages
        // here, so the two cannot drift apart.
        // Stretched by however much the slide is taller or shorter than the
        // window, so a title stays put relative to the slide instead of riding
        // up. Exactly 1 at the default aspect, where the two are the same box.
        const liveH1 = document.querySelector("pluto-output h1")
        const liveH1Style = liveH1 ? getComputedStyle(liveH1) : null
        const h1Margin = side => `${(parseFloat(liveH1Style[side]) || 0) * slideHeight / viewportHeight}px`
        const h1Rule = liveH1Style
            ? `.pdf-page pluto-output h1 {
                    margin-top: ${h1Margin("marginTop")} !important;
                    margin-bottom: ${h1Margin("marginBottom")} !important;
                }`
            : ""

        const pageStyle = document.createElement("style")
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
            }
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

        const footerLeftText = document.getElementById("slide-footer-left")?.textContent ?? ""
        const footerCenterText = document.getElementById("slide-footer-center")?.textContent ?? ""
        const logoSource = document.getElementById("slide-logo-layer")

        const container = document.createElement("div")
        container.id = "pdf-export-container"

        // {cell, parent, nextSibling} for every relocated cell, in original
        // order, so cleanup can put the live notebook back exactly as it was.
        const moves = []

        internal.slides.forEach((slideCells, i) => {
            const bands = internal.computeSlideBands(i)

            const sheet = document.createElement("div")
            sheet.className = "pdf-sheet"
            const page = document.createElement("div")
            page.className = "pdf-page"
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
                content.style.paddingTop = mainStyle.paddingTop
                content.style.paddingRight = mainStyle.paddingRight
                content.style.paddingBottom = mainStyle.paddingBottom
                content.style.paddingLeft = mainStyle.paddingLeft
            }
            // Keep the live nesting, main > pluto-notebook > pluto-cell, so
            // Pluto's own notebook/cell rules apply to the page unchanged. A
            // shallow clone rather than createElement, to inherit whatever
            // classes and attributes the live notebook carries. Its top margin
            // is per slide (it depends on what the h2/h3 cell holds), so ask
            // slidework.js for this slide's value instead of reusing one.
            const notebook = liveNotebook ? liveNotebook.cloneNode(false) : document.createElement("div")
            notebook.removeAttribute("id")
            notebook.style.marginTop = `${internal.computeNotebookOffset(i)}px`
            content.appendChild(notebook)
            slideCells.forEach(cell => {
                moves.push({ cell, parent: cell.parentNode, nextSibling: cell.nextSibling })
                notebook.appendChild(cell)
            })
            page.appendChild(content)

            const footerBand = document.createElement("div")
            footerBand.className = "pdf-footer-band"
            footerBand.innerHTML = `
                <div class="pdf-footer-left">${footerLeftText}</div>
                <div class="pdf-footer-center">${footerCenterText}</div>
                <div class="pdf-footer-right">${i}</div>
            `
            page.appendChild(footerBand)

            container.appendChild(sheet)
        })

        document.body.appendChild(container)

        // Reparenting an <iframe> (unlike an <img>, which keeps its already
        // decoded bitmap) discards its browsing context and starts a fresh
        // navigation, so every myWebPage() embed on the slide is blank again
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
        const framesReady = iframes.length === 0
            ? Promise.resolve()
            : Promise.race([
                Promise.all(iframes.map(frame => new Promise(resolve => {
                    frame.addEventListener("load", resolve, { once: true })
                    frame.addEventListener("error", resolve, { once: true })
                }))),
                new Promise(resolve => setTimeout(resolve, IFRAME_RELOAD_TIMEOUT_MS)),
            ])

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
            // anchor once cells after it have already been put back. try/
            // finally guarantees the container/classes are cleared even if a
            // move unexpectedly throws, so the notebook is never left with
            // cells stuck inside an orphaned print container.
            try {
                for (let i = moves.length - 1; i >= 0; i--) {
                    const { cell, parent, nextSibling } = moves[i]
                    parent.insertBefore(cell, nextSibling)
                }
            } finally {
                container.remove()
                pageStyle.remove()
                document.body.classList.remove("pdf-export-mode")
                if (!internal.inSlideMode) {
                    document.body.classList.remove("slide-mode")
                    document.body.classList.remove("h3-title-mode")
                }
                html.style.fontSize = savedInlineFontSize

                internal.gatherSlides()
                if (internal.inSlideMode) {
                    internal.showSlide(internal.currentSlideIndex, internal.currentFragmentIndex, false)
                    if (wasObserving) internal.setMutationObserver(internal.setupMutationObserver())
                }
            }
        }

        // "afterprint" covers the normal case; "focus" is a fallback for the
        // rare browser/OS combo where it doesn't fire after the dialog closes.
        window.addEventListener("afterprint", cleanup, { once: true })
        window.addEventListener("focus", cleanup, { once: true })

        framesReady.then(() => window.print())
    }

    window.PlutoSlides.exportPDF = buildPrintPages
})()
