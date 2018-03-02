#!/bin/bash
set -x -e

# Remove all fields from FcFontMap. Its' parent_instance field is broken and we don't need the type anyway.
# Replace cairo_font_type_t with enums::FontType as well.
xmlstarlet ed -P -L \
	-d '//_:class[@name="FcFontMap"]/_:field' \
	-u '//*[@c:type="cairo_font_type_t"]/@c:type' -v enums::FontType \
	PangoCairo-1.0.gir

# Remove Int32 alias because it misses c:type, it not like anyone actually cares about it.
xmlstarlet ed -P -L \
	-d '//_:alias[@name="Int32"]' freetype2-2.0.gir

# Change FontType glib:type to FontType.
# Replace cairo_font_type_t with enums::FontType as well.
xmlstarlet ed -P -L \
	-u '//_:enumeration[@name="FontType"]/@glib:type-name' -v FontType \
	-u '//*[@c:type="cairo_font_type_t"]/@c:type' -v enums::FontType \
	cairo-1.0.gir

# gir uses error domain to find quark function corresponding to given error enum,
# but in this case it happens to be named differently, i.e., as g_option_error_quark.
xmlstarlet ed -P -L \
	-u '//*[@glib:error-domain="g-option-context-error-quark"]/@glib:error-domain' -v g-option-error-quark \
	GLib-2.0.gir

# GdkEventTouchpadPinch and GdkEventTouchpadSwipe contains phase field,
# it type enum TouchpadGesturePhase but if takes only one byte.
xmlstarlet ed -P -L \
	-i '//_:field[@name="phase"]/_:type[@name="TouchpadGesturePhase"]' -t attr -n 'c:type' -v 'gint8' \
	Gdk-3.0.gir

xmlstarlet ed -P -L \
	GdkPixbuf-2.0.gir

xmlstarlet ed -P -L \
	Gtk-3.0.gir
