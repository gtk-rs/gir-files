#!/bin/bash
set -x -e

# Remove Int32 alias because it misses c:type, it not like anyone actually cares about it.
xmlstarlet edit --inplace \
	--delete '///_:alias[@name="Int32"]' \
	freetype2-2.0.gir

# gir uses error domain to find quark function corresponding to given error enum,
# but in this case it happens to be named differently, i.e., as g_option_error_quark.
xmlstarlet edit --inplace \
	--update '//*[@glib:error-domain="g-option-context-error-quark"]/@glib:error-domain' -v g-option-error-quark \
	GLib-2.0.gir

# GtkEntry icon signals incorrect assume GdkEventButton when other variants may be passed
xmlstarlet edit --inplace \
	--update '//_:class[@name="Entry"]/glib:signal[@name="icon-press"]//_:parameter[@name="event"]/_:type[@name="Gdk.EventButton"]/@name' -v "Gdk.Event" \
	--update '//_:class[@name="Entry"]/glib:signal[@name="icon-release"]//_:parameter[@name="event"]/_:type[@name="Gdk.EventButton"]/@name' -v "Gdk.Event" \
	Gtk-3.0.gir

# GtkIconSize usage
xmlstarlet edit --inplace \
	--update '//_:type[@c:type="GtkIconSize"]/@name' -v "IconSize" \
	--update '//_:type[@c:type="GtkIconSize*"]/@name' -v "IconSize" \
	Gtk-3.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet edit --inplace \
	--update '//_:class[@name="IconTheme"]/_:method//_:parameter[@name="icon_names"]/_:array/@c:type' -v "const gchar**" \
	--update '//_:class[@name="IconTheme"]/_:method[@name="get_search_path"]//_:parameter[@name="path"]/_:array/@c:type' -v "gchar***" \
	--update '//_:class[@name="IconTheme"]/_:method[@name="set_search_path"]//_:parameter[@name="path"]/_:array/@c:type' -v "const gchar**" \
	Gtk-3.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet edit --inplace \
	--update '//_:record[@name="KeyFile"]/_:method[@name="set_boolean_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gboolean*" \
	--update '//_:record[@name="KeyFile"]/_:method[@name="set_double_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gdouble*" \
	--update '//_:record[@name="KeyFile"]/_:method[@name="set_integer_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gint*" \
	--update '//_:record[@name="KeyFile"]/_:method[@name="set_locale_string_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "const gchar* const*" \
	--update '//_:record[@name="KeyFile"]/_:method[@name="set_string_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "const gchar* const*" \
	GLib-2.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet edit --inplace \
	--update '//_:class[@name="Object"]/_:method[@name="getv"]//_:parameter[@name="names"]/_:array/@c:type' -v "const gchar**" \
	--update '//_:class[@name="Object"]/_:method[@name="getv"]//_:parameter[@name="values"]/_:array/@c:type' -v "GValue*" \
	--update '//_:class[@name="Object"]/_:method[@name="setv"]//_:parameter[@name="names"]/_:array/@c:type' -v "const gchar**" \
	--update '//_:class[@name="Object"]/_:method[@name="setv"]//_:parameter[@name="values"]/_:array/@c:type' -v "const GValue*" \
	--update '//_:class[@name="Object"]/_:constructor[@name="new_with_properties"]//_:parameter[@name="names"]/_:array/@c:type' -v "const char**" \
	--update '//_:class[@name="Object"]/_:constructor[@name="new_with_properties"]//_:parameter[@name="values"]/_:array/@c:type' -v "const GValue*" \
	GObject-2.0.gir

# add missing attributes to resolve type struct for TypePlugin
xmlstarlet edit --inplace \
	--insert '//_:interface[@name="TypePlugin" and not(@glib:type-struct)]' -t 'attr' -n 'glib:type-struct' -v 'TypePluginClass' \
	--insert '//_:record[@name="TypePluginClass" and not(@glib:is-gtype-struct-for)]' -t 'attr' -n 'glib:is-gtype-struct-for' -v 'TypePlugin' \
	GObject-2.0.gir

# fix wrong "full" transfer ownership
xmlstarlet edit --inplace \
	--update '//_:method[@c:identifier="gdk_frame_clock_get_current_timings"]/_:return-value/@transfer-ownership' -v "none" \
	--update '//_:method[@c:identifier="gdk_frame_clock_get_timings"]/_:return-value/@transfer-ownership' -v "none" \
	Gdk-3.0.gir

# replace gmodule with gpointer
xmlstarlet edit --inplace \
	--update '//_:record[@name="PixbufModule"]/_:field[@name="module"]/_:type/@name' -v "gpointer" \
	--update '//_:record[@name="PixbufModule"]/_:field[@name="module"]/_:type/@c:type' -v "gpointer" \
	GdkPixbuf-2.0.gir

# replace "gint" response_id parameters with "ResponseType"
xmlstarlet edit --inplace \
	--update '//_:parameter[@name="response_id"]/_:type[@name="gint"]/@c:type' -v "GtkResponseType" \
	--update '//_:parameter[@name="response_id"]/_:type[@name="gint"]/@name' -v "ResponseType" \
	Gtk-3.0.gir Gtk-4.0.gir

# fix wrong "full" transfer ownership
xmlstarlet edit --inplace \
	--update '//_:constructor[@c:identifier="gtk_shortcut_label_new"]/_:return-value/@transfer-ownership' -v "none" \
	Gtk-3.0.gir

# add out annotation for functions returning GValue
xmlstarlet edit --inplace \
	-a '//_:method[@c:identifier="gtk_style_context_get_style_property"]//_:parameter[@name="value" and not(@direction)]' -type attr -n "direction" -v "out" \
	-a '//_:method[@c:identifier="gtk_style_context_get_style_property"]//_:parameter[@name="value" and not(@caller-allocates)]' -type attr -n "caller-allocates" -v "1" \
	-a '//_:method[@c:identifier="gtk_cell_area_cell_get_property"]//_:parameter[@name="value" and not(@direction)]' -type attr -n "direction" -v "out" \
	-a '//_:method[@c:identifier="gtk_cell_area_cell_get_property"]//_:parameter[@name="value" and not(@caller-allocates)]' -type attr -n "caller-allocates" -v "1" \
	-a '//_:method[@c:identifier="gtk_container_child_get_property"]//_:parameter[@name="value" and not(@direction)]' -type attr -n "direction" -v "out" \
	-a '//_:method[@c:identifier="gtk_container_child_get_property"]//_:parameter[@name="value" and not(@caller-allocates)]' -type attr -n "caller-allocates" -v "1" \
	-a '//_:method[@c:identifier="gtk_widget_style_get_property"]//_:parameter[@name="value" and not(@direction)]' -type attr -n "direction" -v "out" \
	-a '//_:method[@c:identifier="gtk_widget_style_get_property"]//_:parameter[@name="value" and not(@caller-allocates)]' -type attr -n "caller-allocates" -v "1" \
	Gtk-3.0.gir

# remove freetype and graphite methods; GitHub issue #2557
xmlstarlet edit --inplace \
	--delete '///_:function[@c:identifier="hb_graphite2_face_get_gr_face"]' \
	--delete '///_:function[@c:identifier="hb_graphite2_font_get_gr_font"]' \
	--delete '///_:function[@c:identifier="hb_ft_face_create"]' \
	--delete '///_:function[@c:identifier="hb_ft_face_create_cached"]' \
	--delete '///_:function[@c:identifier="hb_ft_face_create_referenced"]' \
	--delete '///_:function[@c:identifier="hb_ft_font_create"]' \
	--delete '///_:function[@c:identifier="hb_ft_font_create_cached"]' \
	--delete '///_:function[@c:identifier="hb_ft_font_create_referenced"]' \
	--delete '///_:function[@c:identifier="hb_ft_font_get_face"]' \
	--delete '///_:function[@c:identifier="hb_ft_font_lock_face"]' \
	HarfBuzz-0.0.gir

# fix harfbuzz types on Pango
xmlstarlet edit --inplace \
	--insert '///_:type[not(@name) and @c:type="hb_font_t*"]' -t 'attr' -n 'name' -v "gconstpointer" \
	--update '//_:type[@c:type="hb_font_t*"]/@c:type' -v "gconstpointer" \
	--insert '///_:array[not(@name) and @c:type="hb_feature_t*"]' -t 'attr' -n 'name' -v "gconstpointer" \
	-r '///_:array[@c:type="hb_feature_t*"]' -v "type" \
	--delete '//_:type[@c:type="hb_feature_t*"]/*' \
	--delete '//_:type[@c:type="hb_feature_t*"]/@length' \
	--delete '//_:type[@c:type="hb_feature_t*"]/@zero-terminated' \
	--update '//_:type[@c:type="hb_feature_t*"]/@c:type' -v "gconstpointer" \
	Pango-1.0.gir

# Fix unsupported bitfield (https://github.com/gtk-rs/gir/issues/465) on pango
xmlstarlet edit --inplace \
	--delete '//_:record[@c:type="PangoGlyphVisAttr"]/_:field/@bits' \
	--delete '//_:record[@c:type="PangoGlyphVisAttr"]/_:field[@name="is_color"]' \
	Pango-1.0.gir

#  Remove unstable method from focal release
xmlstarlet edit --inplace \
	--delete '///_:method[@c:identifier="atk_plug_set_child"]' \
	Atk-1.0.gir

# fix non-existant c-types
xmlstarlet edit --inplace \
	--update '//_:class[@name="WaylandDevice"]/_:method[@name="get_wl_keyboard"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandDevice"]/_:method[@name="get_wl_pointer"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandDevice"]/_:method[@name="get_wl_seat"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandDisplay"]/_:method[@name="get_wl_compositor"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandDisplay"]/_:method[@name="get_wl_display"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandMonitor"]/_:method[@name="get_wl_output"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandSeat"]/_:method[@name="get_wl_seat"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandSurface"]/_:method[@name="get_wl_surface"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandDevice"]/_:method[@name="get_xkb_keymap"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="WaylandDevice"]/_:method[@name="get_xkb_keymap"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
 	--update '//_:class[@name="WaylandToplevel"]/_:method[@name="get_xdg_toplevel"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	GdkWayland-4.0.gir

# avoid always depending on x11 crate
xmlstarlet edit --inplace \
	--update '//_:class[@name="X11Display"]/_:method[@name="get_xcursor"]//_:type[@name="xlib.Cursor"]/@c:type' -v "gulong" \
	--update '//_:class[@name="X11Display"]/_:method[@name="get_xdisplay"]//_:type[@name="xlib.Display"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="X11Display"]/_:method[@name="get_xrootwindow"]//_:type[@name="xlib.Window"]/@c:type' -v "gulong" \
	--update '//_:class[@name="X11Display"]/_:method[@name="get_xscreen"]//_:type[@name="xlib.Screen"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="X11Monitor"]/_:method[@name="get_output"]//_:type[@name="xlib.XID"]/@c:type' -v "gulong" \
	--update '//_:class[@name="X11Screen"]/_:method[@name="get_monitor_output"]//_:type[@name="xlib.XID"]/@c:type' -v "gulong" \
	--update '//_:class[@name="X11Screen"]/_:method[@name="get_xscreen"]//_:type[@name="xlib.Screen"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="X11Surface"]/_:method[@name="get_xid"]//_:type[@name="xlib.Window"]/@c:type' -v "gulong" \
	--update '//_:class[@name="X11Surface"]/_:function[@name="lookup_for_display"]//_:type[@name="xlib.Window"]/@c:type' -v "gulong" \
	--update '//_:class[@name="get_xid"]/_:method[@name="lookup_for_display"]//_:type[@name="xlib.Window"]/@c:type' -v "gulong" \
	--update '//_:function[@name="x11_get_xatom_by_name_for_display"]//_:type[@name="xlib.Atom"]/@c:type' -v "gulong" \
	--update '//_:function[@name="x11_get_xatom_name_for_display"]//_:type[@name="xlib.Atom"]/@c:type' -v "gulong" \
	--update '//_:function[@name="x11_lookup_xdisplay"]//_:type[@name="xlib.Display"]/@c:type' -v "gpointer" \
	GdkX11-4.0.gir

xmlstarlet edit --inplace \
	--update '//_:callback[@name="Win32MessageFilterFunc"]//_:type[@name="win32.MSG"]/@c:type' -v "gpointer" \
	--update '//_:class[@name="Win32HCursor"]//_:type[@name="win32.HCURSOR"]/@c:type' -v "gssize" \
	--update '//_:class[@name="Win32Surface"]//_:type[@name="win32.HGDIOBJ"]/@c:type' -v "gssize" \
	--update '//_:class[@name="Win32Surface"]//_:type[@name="win32.HWND"]/@c:type' -v "gssize" \
    -u '//_:function[@name="win32_handle_table_lookup"]//_:type[@name="win32.HWND"]/@c:type' -v 'gssize' \
    -u '//_:function[@name="win32_set_modal_dialog_libgtk_only"]//_:type[@name="win32.HWND"]/@c:type' -v 'gssize' \
    -u '//_:function[@name="win32_icon_to_pixbuf_libgtk_only"]//_:type[@name="win32.HICON"]/@c:type' -v 'gssize' \
    -u '//_:function[@name="win32_pixbuf_to_hicon_libgtk_only"]//_:type[@name="win32.HICON"]/@c:type' -v 'gssize' \
	--insert '//_:type[@c:type="ID3D12Fence*" and not(@name)]' -t 'attr' -n 'name' -v "gpointer" \
	--update '//_:type[@c:type="ID3D12Fence*"]/@c:type' -v "gpointer" \
	--insert '//_:type[@c:type="ID3D12Resource*" and not(@name)]' -t 'attr' -n 'name' -v "gpointer" \
	--update '//_:type[@c:type="ID3D12Resource*"]/@c:type' -v "gpointer" \
	GdkWin32-4.0.gir

# Fix invalid type for GtkImage and GtkStackSwitcher "icon-size" property
xmlstarlet edit --inplace \
	--update '//_:class[@name="Image"]/_:property[@name="icon-size"]/_:type/@c:type' -v "GtkIconSize" \
	--update '//_:class[@name="Image"]/_:property[@name="icon-size"]/_:type/@name' -v "IconSize" \
	--update '//_:class[@name="StackSwitcher"]/_:property[@name="icon-size"]/_:type/@c:type' -v "GtkIconSize" \
	--update '//_:class[@name="StackSwitcher"]/_:property[@name="icon-size"]/_:type/@name' -v "IconSize" \
	Gtk-3.0.gir

# Fix GLibUnix type names to use GLibUnix prefix instead of GLib
xmlstarlet edit --inplace \
	--update '//_:type[@name="GLib.UnixPipe"]/@name' -v "GLibUnix.Pipe" \
	--update '//_:type[@name="GLib.UnixPipeEnd"]/@name' -v "GLibUnix.PipeEnd" \
	GLibUnix-2.0.gir

# Fix GLibWin32 type name to remove GLib prefix
xmlstarlet edit --inplace \
	--update '//_:type[@name="GLib.Win32OSType"]/@name' -v "OSType" \
	GLibWin32-2.0.gir

# Fix GioWin32 NetworkMonitor types to use gpointer
xmlstarlet edit --inplace \
	--insert '//_:record[@name="NetworkMonitor"]/_:field[@name="parent_instance"]/_:type[@c:type="GNetworkMonitorBase" and not(@name)]' -t 'attr' -n 'name' -v "gpointer" \
	--insert '//_:record[@name="NetworkMonitorClass"]/_:field[@name="parent_class"]/_:type[@c:type="GNetworkMonitorBaseClass" and not(@name)]' -t 'attr' -n 'name' -v "gpointer" \
	GioWin32-2.0.gir
