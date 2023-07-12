#!/bin/bash

# repo root at ../.. from this file's directory
root=$(realpath $(dirname $(realpath $0))/../..)

# clear existing umls
docs_dir="$root/docs/uml"
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
