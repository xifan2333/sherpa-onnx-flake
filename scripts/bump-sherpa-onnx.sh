#!/usr/bin/env bash
# Update the pinned upstream sherpa-onnx version in packages/sherpa-onnx.nix.
# Usage: bump-sherpa-onnx.sh <new-version>          # e.g. 1.12.35
#
# Resolves the upstream tag v<new-version> to a commit sha via the GitHub
# API, computes the Nix SRI sha256 of the source tree with nix-prefetch-url,
# then sed-rewrites packages/sherpa-onnx.nix:
#   version = "X.Y.Z";
#   rev     = "<commit sha>";
#   sha256  = "sha256-...";
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <new-version>" >&2
    exit 1
fi
new_version="$1"

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd -- "${script_dir}/.." && pwd)
nix_file="${repo_root}/packages/sherpa-onnx.nix"

if [[ ! -f "${nix_file}" ]]; then
    echo "Cannot find ${nix_file}" >&2
    exit 1
fi

current_version=$(awk -F\" '/^[[:space:]]*version[[:space:]]*=/ {print $2; exit}' "${nix_file}")
if [[ "${current_version}" == "${new_version}" ]]; then
    echo "sherpa-onnx already pinned at v${new_version}, nothing to do." >&2
    exit 0
fi

echo "Bumping sherpa-onnx: v${current_version} -> v${new_version}" >&2

# 1) Resolve tag -> annotated/lightweight commit sha.
# `git/refs/tags/<tag>` points to either the commit directly or to an
# annotated-tag object; in the latter case we follow .object.url to the
# tag object, whose .object.sha is the underlying commit.
ref_json=$(curl -fsSL "https://api.github.com/repos/k2-fsa/sherpa-onnx/git/refs/tags/v${new_version}")
ref_type=$(jq -r '.object.type' <<<"${ref_json}")
case "${ref_type}" in
    commit)
        new_rev=$(jq -r '.object.sha' <<<"${ref_json}")
        ;;
    tag)
        tag_url=$(jq -r '.object.url' <<<"${ref_json}")
        new_rev=$(curl -fsSL "${tag_url}" | jq -r '.object.sha')
        ;;
    *)
        echo "Unexpected ref object type: ${ref_type}" >&2
        exit 1
        ;;
esac
[[ -n "${new_rev}" && "${new_rev}" != "null" ]] || { echo "Failed to resolve tag v${new_version} to a commit" >&2; exit 1; }

echo "Resolved v${new_version} -> ${new_rev}" >&2

# 2) Prefetch source tree to get its Nix SRI sha256.
tarball="https://github.com/k2-fsa/sherpa-onnx/archive/${new_rev}.tar.gz"
echo "Prefetching ${tarball}..." >&2
hash_b32=$(nix-prefetch-url --unpack --type sha256 "${tarball}")
[[ -n "${hash_b32}" ]] || { echo "nix-prefetch-url returned empty hash" >&2; exit 1; }
new_sri=$(nix --extra-experimental-features nix-command hash to-sri --type sha256 "${hash_b32}")
[[ -n "${new_sri}" ]] || { echo "nix hash to-sri returned empty SRI" >&2; exit 1; }

echo "Computed SRI: ${new_sri}" >&2

# 3) Rewrite the three pinned values in packages/sherpa-onnx.nix.
# Use python instead of sed to avoid escaping headaches with `/=+` in SRI hash.
python3 - "$nix_file" "$new_version" "$new_rev" "$new_sri" <<'PY'
import re
import sys

path, version, rev, sri = sys.argv[1:]
with open(path, encoding="utf-8") as fh:
    text = fh.read()

text, n_ver = re.subn(r'(version\s*=\s*")[^"]*(")', rf'\g<1>{version}\g<2>', text, count=1)
text, n_rev = re.subn(r'(rev\s*=\s*")[^"]*(")', rf'\g<1>{rev}\g<2>', text, count=1)
text, n_sha = re.subn(r'(sha256\s*=\s*")[^"]*(")', rf'\g<1>{sri}\g<2>', text, count=1)

if not (n_ver == 1 and n_rev == 1 and n_sha == 1):
    sys.exit(f"unexpected substitution counts: version={n_ver} rev={n_rev} sha256={n_sha}")

with open(path, "w", encoding="utf-8") as fh:
    fh.write(text)
PY

echo "Bumped ${nix_file##*/}: v${current_version} -> v${new_version}" >&2
