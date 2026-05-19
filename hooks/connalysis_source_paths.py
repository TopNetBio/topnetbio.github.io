"""MkDocs hook: tidy connalysis source paths in rendered API pages.

mkdocstrings renders "Source code in `<path>`" using the on-disk file
location. Because the source is fetched into the git-ignored
`_vendor/connectome-analysis/` directory at build time, that build-local
prefix would otherwise leak into the published docs. This hook strips it so
the displayed path reads `src/connalysis/...` instead.

Presentation-only: it rewrites rendered HTML, never the source or the docs.
"""

_VENDOR_PREFIX = "_vendor/connectome-analysis/"


def on_page_content(html, *, page, config, files):
    """Remove the build-local vendor prefix from source-code path labels."""
    if _VENDOR_PREFIX not in html:
        return html
    return html.replace(_VENDOR_PREFIX, "")
