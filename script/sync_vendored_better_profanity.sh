#!/usr/bin/env bash
# Re-vendor better_profanity from a released tag, for when
# the govuk-feedback-processing pipeline's pin changes.
#
# Usage: script/sync_vendored_better_profanity.sh <version>
# Example: script/sync_vendored_better_profanity.sh 0.8.0
#
# After running: review the vendor/better_profanity diff, run the
# Zendesk ticket specs, and commit together with the wordlist sync.
set -euo pipefail

version="${1:?usage: $0 <version>}"
repo="snguyenthanh/better_profanity"
repo_base="https://raw.githubusercontent.com/${repo}/${version}"
pkg_base="${repo_base}/better_profanity"

files=(
  __init__.py
  alphabetic_unicode.json
  better_profanity.py
  constants.py
  profanity_wordlist.txt
  utils.py
  varying_string.py
)

for file in "${files[@]}"; do
  curl -fsS -o "vendor/better_profanity/${file}" "${pkg_base}/${file}"
done
curl -fsS -o vendor/better_profanity/LICENSE "${repo_base}/LICENSE"

upstream_files=$(gh api "repos/${repo}/contents/better_profanity?ref=${version}" \
  --jq '[.[] | select(.name | test("\\.(py|json|txt)$")) | .name] | sort | join("\n")')
vendored_files=$(printf '%s\n' "${files[@]}" | LC_ALL=C sort)
if [ "${upstream_files}" != "${vendored_files}" ]; then
  echo "ERROR: better_profanity ${version} package contents differ from the vendored file list:"
  diff <(printf '%s\n' "${upstream_files}") <(printf '%s\n' "${vendored_files}") || true
  echo "Update the 'files' list in this script."
  exit 1
fi

python3 - <<'PY'
import pathlib
import sys

sys.path.insert(0, "vendor")
from better_profanity import profanity  # noqa: E402

words = [
    line.strip()
    for line in pathlib.Path("config/profanity_filter/wordlist.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
profanity.load_censor_words(words)
assert profanity.censor("this page is shit") == "this page is ****"
print("vendored better_profanity smoke test passed")
PY

echo "Vendored better-profanity ${version} into vendor/better_profanity."
echo "Next: review the diff, update the pin in config/profanity_filter/wordlist.txt.origin.yml,"
echo "and run: bundle exec rspec spec/lib/profanity_filter_spec.rb spec/lib/zendesk/ticket_spec.rb spec/sidekiq/zendesk_ticket_job_spec.rb"
