#!/bin/bash
set -x -e

for file in *.gir; do
	xmlstarlet ed -P -L \
		-d '//_:doc/@line' \
		-d '//_:doc/@filename' \
		-d '//_:source-position' \
		"$file"
done
