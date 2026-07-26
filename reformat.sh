#!/bin/bash
set -x -e

# `///` used as `//` not works in Windows in this case
for file in *.gir; do
    # TODO Revert once all files have been regenerated with
    # https://gitlab.gnome.org/GNOME/gobject-introspection/-/merge_requests/558.
	xmlstarlet format --encode utf-8 "$file" \
	| xmlstarlet edit \
		--delete '//_:doc/@line' \
		--delete '//_:doc/@filename' \
		--delete '///_:source-position' \
		> "$file".tmp
	/usr/bin/mv "$file".tmp "$file"
done
