#!/bin/bash
set -x -e

for file in *.gir; do
	xmlstarlet ed -P -L "$file"
done
