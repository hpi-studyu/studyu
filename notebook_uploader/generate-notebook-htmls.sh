#!/bin/bash
find . -type f -name \*.ipynb -exec bash -c 'FN="{}"; jupyter nbconvert --execute --to html "{}" --allow-errors --no-prompt --template /nbconvert-template; uploader -t "$session" -s $study_id "${FN%.ipynb}.html"' \;
