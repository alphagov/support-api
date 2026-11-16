#!/usr/bin/env python3
"""Batch profanity masking bridge for support-api.

Reads JSON {"texts": [...]} on stdin, writes {"masked": [...]} to stdout.
Runs the vendored profanity filter (vendor/better_profanity) with the
wordlist at config/profanity_filter/wordlist.txt, the same library and
wordlist as the govuk-feedback-processing pipeline, so results are identical.

Deliberately dependency-free (stdlib only) and stateless: one process per
ticket, invoked by lib/profanity_filter.rb.
"""

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT / "vendor"))

from better_profanity import profanity  # noqa: E402

WORDLIST = ROOT / "config" / "profanity_filter" / "wordlist.txt"


def main() -> int:
    words = [
        line.strip()
        for line in WORDLIST.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    profanity.load_censor_words(words)

    payload = json.load(sys.stdin)
    masked = [profanity.censor(text) for text in payload["texts"]]

    json.dump({"masked": masked}, sys.stdout, ensure_ascii=False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
