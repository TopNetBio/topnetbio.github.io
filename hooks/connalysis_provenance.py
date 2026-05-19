"""MkDocs hook: surface the fetched connalysis source provenance.

The connalysis source is fetched at build time (see scripts/fetch-connalysis.sh)
into the git-ignored _vendor/ directory, which also writes
_vendor/connalysis-provenance.txt with the resolved version and commit.

This hook injects that provenance:
  * into the site footer (appended to the copyright line), and
  * into API pages, by replacing the `{{ CONNALYSIS_PROVENANCE }}` token.

It degrades gracefully (and never raises) if the provenance file is absent,
so `mkdocs build --strict` stays green even if the fetch step was skipped.
"""

from pathlib import Path

_TOKEN = "{{ CONNALYSIS_PROVENANCE }}"
_PROVENANCE_FILE = Path("_vendor/connalysis-provenance.txt")


def _read_provenance():
    """Return a dict of provenance fields, or None if unavailable."""
    try:
        text = _PROVENANCE_FILE.read_text(encoding="utf-8")
    except OSError:
        return None
    data = {}
    for line in text.splitlines():
        key, sep, value = line.partition("=")
        if sep:
            data[key.strip()] = value.strip()
    if not data.get("commit"):
        return None
    return data


def on_config(config):
    """Append the connalysis version + commit to the footer copyright."""
    prov = _read_provenance()
    if not prov:
        return config
    version = prov.get("version", "unknown")
    short = prov.get("commit_short", prov.get("commit", "")[:7])
    ref = prov.get("ref", "")
    suffix = (
        f' &middot; <span class="connalysis-provenance">connalysis '
        f"{version} @ {short} ({ref})</span>"
    )
    existing = config.get("copyright") or ""
    if "connalysis-provenance" not in existing:
        config["copyright"] = existing + suffix
    return config


def on_page_markdown(markdown, *, page, config, files):
    """Replace the provenance token on any page that contains it."""
    if _TOKEN not in markdown:
        return markdown
    prov = _read_provenance()
    if not prov:
        return markdown.replace(
            _TOKEN,
            "_Source provenance unavailable — run "
            "`scripts/fetch-connalysis.sh` before building._",
        )
    version = prov.get("version", "unknown")
    short = prov.get("commit_short", prov.get("commit", "")[:7])
    commit_url = prov.get("commit_url", "")
    ref = prov.get("ref", "")
    repo = prov.get("repo", "")
    commit_md = f"[`{short}`]({commit_url})" if commit_url else f"`{short}`"
    line = (
        f"**Generated from** `connalysis` **{version}** at commit "
        f"{commit_md} (ref `{ref}`, repo `{repo}`)."
    )
    return markdown.replace(_TOKEN, line)
