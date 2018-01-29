#!/bin/bash
set -x -e

# Remove all fields from FcFontMap. Its' parent_instance field is broken and we don't need the type anyway.
# Replace cairo_font_type_t with enums::FontType as well.
xmlstarlet ed -P \
	-d '//_:class[@name="FcFontMap"]/_:field' \
	-u '//*[@c:type="cairo_font_type_t"]/@c:type' -v enums::FontType \
	PangoCairo-1.0.gir > tmp
mv tmp PangoCairo-1.0.gir

# Remove Int32 alias because it misses c:type, it not like anyone actually cares about it.
xmlstarlet ed -P \
	-d '//_:alias[@name="Int32"]' freetype2-2.0.gir > tmp
mv tmp freetype2-2.0.gir

# Change FontType glib:type to FontType.
# Replace cairo_font_type_t with enums::FontType as well.
xmlstarlet ed -P \
	-u '//_:enumeration[@name="FontType"]/@glib:type-name' -v FontType \
	-u '//*[@c:type="cairo_font_type_t"]/@c:type' -v enums::FontType \
	cairo-1.0.gir > tmp
mv tmp cairo-1.0.gir
