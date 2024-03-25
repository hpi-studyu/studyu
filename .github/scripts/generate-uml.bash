#!/bin/bash

# repo root at ../.. from this file's directory
root="$(realpath "$(dirname "$(realpath "$0")")/../..")"

docs_dir="$root/docs/uml"

# find directories whose umls need updates -------------------------------------
# regenerating all umls every time is too slow

# find latest commit that updated uml diagrams (or use initial commit)
prev_update="$(git log -n 1 --pretty=format:%H -- "$docs_dir")"
[[ -z  "$prev_update" ]] && prev_update="$(git rev-list --max-parents=0 HEAD)"

# associative array, keys will be all directories whose uml has to be
# regenerated
declare -A dirty
# get all directories that have changed since prev_update
for changed in $(git diff --name-only "$prev_update" \
    | grep --extended-regexp '(flutter_common|core|designer_v2|app)/lib/.*\.dart' \
    | xargs dirname \
    | sort --unique \
); do
    # set changed dir as dirty for all parents until we reach lib
    while grep --extended-regexp -q '[^/]*/lib' <<< "$changed"; do
        dirty[$changed]=1
        changed="$(dirname "$changed")"
    done
done

# generate needed umls ---------------------------------------------------------

# temporary file for uml data
tmpf=$(mktemp)

# iterate keys of dirty
for d in "${!dirty[@]}"; do
    out="$docs_dir/$d/uml.svg"
    # remove old uml if it exists
    rm -rf "$out"
    # skip to next if directory doesn't exist (i.e. git diff showed it because
    # it was deleted
    test -d "$root/$d" || continue

    echo "Generating diagram for $d"

    # ensure destination dir extists
    mkdir -p "$(dirname "$out")"

    # go to package dir, i.e. first path component
    cd "$root/$(cut -d/ -f1 <<< "$d")" || exit
    # uml generator gets confused with generated files so we have to remove
    # them
    find . -type f -name '*.g.dart' -exec rm {} \;

    # generate uml & svg
    dart pub global run dcdg \
        --exclude=State --exclude=StatefulWidget --exclude=StatelessWidget \
        -b nomnoml \
        -s "$(cut -d/ -f2- <<< "$d")" \
        > "$tmpf"
    npx --yes nomnoml "$tmpf" "$out"

    # get deleted generated files back from git
    git checkout HEAD -- .
done

# remove temporary file
rm "$tmpf"
