#!/bin/bash

# repo root at ../.. from this file's directory
root=$(realpath $(dirname $(realpath $0))/../..)

docs_dir="$root/docs/uml"
# find latest commit that updated uml diagrams (or use initial commit)
prev_update="$(git log -n 1 --pretty=format:%H -- $docs_dir)"
[[ -z  "$prev_update" ]] && prev_update="$(git rev-list --max-parents=0 HEAD)"

# associative array, keys will be all directories whose uml has to be
# regenerated
declare -A dirty
# get all directories that have changed since prev_update
for changed in $(git diff --name-only $prev_update \
    | grep --extended-regexp '(flutter_common|core|designer_v2|app)/lib/.*\.dart' \
    | xargs dirname \
    | sort --unique \
); do
    # set parent as dirty list until we reach lib
    while [[ -n $(grep --extended-regexp '[^/]*/lib/.+' <<< "$changed") ]]; do
        dirty[$changed]=1
        changed="$(dirname "$changed")"
    done
    # set lib dirty
    dirty[$changed]=1
done

for d in "${!dirty[@]}"; do
    echo "dirty: $d"
done

# check if dir still exists before regenerating uml

exit 0

rm -rf "$docs_dir"

# temporary file for uml data
tmpf=$(mktemp)

for pkg in flutter_common core designer_v2 app; do
    cd "$root/$pkg"
    # uml generator gets confused with generated files so we have to remove
    # them
    find . -type f -name '*.g.dart' -exec rm {} \;

    for dir in $(find lib -type d); do
        # skip if no dart files
        [[ -z $(find "$dir" -type f -name '*.dart') ]] && continue
        echo "Generating diagram for $pkg/$dir"

        out="$docs_dir/$pkg/$dir/uml.svg"
        mkdir -p $(dirname "$out")

        dart pub global run dcdg \
            --exclude=State --exclude=StatefulWidget --exclude=StatelessWidget \
            -b nomnoml \
            -s "$dir" \
            > $tmpf
        npx --yes nomnoml "$tmpf" "$out"
    done

    # get deleted generated files back from git
    git checkout HEAD -- .
    break
done

rm "$tmpf"
