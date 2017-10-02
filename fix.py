#!/usr/bin/python

def replace_problematic_lines(filename, problematic_lines):
    try:
        lines = []
        with open(filename, 'r+') as f:
            for line in f.readlines():
                if len(line) > 0:
                    line = line[:-1]
                solution = problematic_lines.get(line.strip(), None)
                if solution is not None:
                    lines.append('{}{}'.format(line[:(len(line) - len(line.strip()))], solution))
                else:
                    lines.append(line)
            f.seek(0)
            f.truncate()
            f.write('\n'.join(lines))
            f.write('\n')
    except Exception as e:
        print("Error in replace_problematic_lines: {}".format(e))


replace_problematic_lines('freetype2-2.0.gir',
                          {'<type name="int32"/>': '<type name="gint32" c:type="gint32"/>'})
replace_problematic_lines('PangoCairo-1.0.gir',
                          {'<type c:type="PangoFcFontMap"/>': '<type name="FcFontMap" c:type="PangoFcFontMap"/>',
                           '<type name="cairo.FontType" c:type="cairo_font_type_t"/>': '<type name="cairo.FontType" c:type="enums::FontType"/>'})
replace_problematic_lines('PangoCairo-1.0.gir',
                          {'<type c:type="PangoFcFontMap"/>': '<type name="FcFontMap" c:type="PangoFcFontMap"/>'})
replace_problematic_lines('cairo-1.0.gir',
                          {'glib:type-name="cairo_font_type_t"': 'glib:type-name="FontType"'})
