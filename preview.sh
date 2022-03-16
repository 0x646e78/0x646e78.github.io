#!/usr/bin/env bash

echo "Will be available on http://localhost:3000"
docker run --rm --volume="$PWD:/srv/jekyll" -p 3000:4000 jekyll/jekyll:latest bundle update
docker run --rm --volume="$PWD:/srv/jekyll" -p 3000:4000 jekyll/jekyll:latest jekyll serve --drafts
