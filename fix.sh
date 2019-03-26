#!/bin/bash
set -x -e

# Remove Int32 alias because it misses c:type, it not like anyone actually cares about it.
xmlstarlet ed -P -L \
	-d '//_:alias[@name="Int32"]' \
	freetype2-2.0.gir

# gir uses error domain to find quark function corresponding to given error enum,
# but in this case it happens to be named differently, i.e., as g_option_error_quark.
xmlstarlet ed -P -L \
	-u '//*[@glib:error-domain="g-option-context-error-quark"]/@glib:error-domain' -v g-option-error-quark \
	GLib-2.0.gir

# GtkIconSize usage
xmlstarlet ed -P -L \
	-u '//_:type[@c:type="GtkIconSize"]/@name' -v "IconSize" \
	-u '//_:type[@c:type="GtkIconSize*"]/@name' -v "IconSize" \
	Gtk-3.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:class[@name="IconTheme"]/_:method//_:parameter[@name="icon_names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="IconTheme"]/_:method[@name="get_search_path"]//_:parameter[@name="path"]/_:array/@c:type' -v "gchar***" \
	-u '//_:class[@name="IconTheme"]/_:method[@name="set_search_path"]//_:parameter[@name="path"]/_:array/@c:type' -v "const gchar**" \
	Gtk-3.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_boolean_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gboolean*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_double_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gdouble*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_integer_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gint*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_locale_string_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "const gchar* const*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_string_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "const gchar* const*" \
	GLib-2.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:class[@name="Object"]/_:method[@name="getv"]//_:parameter[@name="names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="Object"]/_:method[@name="getv"]//_:parameter[@name="values"]/_:array/@c:type' -v "GValue*" \
	-u '//_:class[@name="Object"]/_:method[@name="setv"]//_:parameter[@name="names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="Object"]/_:method[@name="setv"]//_:parameter[@name="values"]/_:array/@c:type' -v "const GValue*" \
	-u '//_:class[@name="Object"]/_:constructor[@name="new_with_properties"]//_:parameter[@name="names"]/_:array/@c:type' -v "const char**" \
	-u '//_:class[@name="Object"]/_:constructor[@name="new_with_properties"]//_:parameter[@name="values"]/_:array/@c:type' -v "const GValue*" \
	GObject-2.0.gir

# incorrectly marked as transfer-none GitLab issue #197
xmlstarlet ed -P -L \
	-u '//_:class[@name="Binding"]/_:method[@name="unbind"]//_:instance-parameter[@name="binding"]/@transfer-ownership' -v "full" \
	GObject-2.0.gir

# fix wrong "full" transfer ownership
xmlstarlet ed -P -L \
	-u '//_:method[@c:identifier="gdk_frame_clock_get_current_timings"]/_:return-value/@transfer-ownership' -v "none" \
	-u '//_:method[@c:identifier="gdk_frame_clock_get_timings"]/_:return-value/@transfer-ownership' -v "none" \
	Gdk-3.0.gir

# replace "gint" response_id parameters with "ResponseType"
xmlstarlet ed -P -L \
	-u '//_:parameter[@name="response_id"]/_:type[@name="gint"]/@c:type' -v "GtkResponseType" \
	-u '//_:parameter[@name="response_id"]/_:type[@name="gint"]/@name' -v "ResponseType" \
	Gtk-3.0.gir

# fill in types from JavaScriptCore
xmlstarlet ed -P -L \
	-i '//_:type[not(@name) and @c:type="JSGlobalContextRef"]' -t 'attr' -n 'name' -v "JavaScriptCore.GlobalContextRef" \
	-i '//_:type[not(@name) and @c:type="JSValueRef"]' -t 'attr' -n 'name' -v "JavaScriptCore.ValueRef" \
    -i '//_:type[not(@name) and @c:type="JSCValue*"]' -t 'attr' -n 'name' -v "JavaScriptCore.Value" \
	WebKit2WebExtension-4.0.gir WebKit2-4.0.gir

xmlstarlet ed -P -L \
	-u '//_:constant[@name="DOM_NODE_FILTER_SHOW_ALL"]/_:type/@name' -v "guint" \
	-u '//_:constant[@name="DOM_NODE_FILTER_SHOW_ALL"]/_:type/@c:type' -v "guint" \
	WebKit2WebExtension-4.0.gir
