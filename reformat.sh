#!/bin/bash
set -x -e

# `///` used as `//` not works in Windows in this case
for file in *.gir; do
	xmlstarlet edit --inplace \
		--delete '//_:doc/@line' \
		--delete '//_:doc/@filename' \
		--delete '///_:source-position' \
		"$file"
done
