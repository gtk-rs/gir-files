#!/usr/bin/python

def replace_problematic_lines(filename, problematic_line, fixed_line):
    try:
        lines = []
        with open(filename, 'r+') as f:
            for line in f.readlines():
                if len(line) > 0:
                    line = line[:-1]
                if line.strip() == problematic_line:
                    lines.append('{}{}'.format(' ' * (len(line) - len(line.strip())), fixed_line))
                else:
                    lines.append(line)
            f.seek(0)
            f.truncate()
            f.write('\n'.join(lines))
            f.write('\n')
    except Exception as e:
        print("Error in replace_problematic_lines: {}".format(e))


replace_problematic_lines('freetype2-2.0.gir',
                          '<type name="int32"/>',
                          '<type name="gint32" c:type="gint32"/>')
replace_problematic_lines('PangoCairo-1.0.gir',
                          '<type c:type="PangoFcFontMap"/>',
                          '<type name="FcFontMap" c:type="PangoFcFontMap"/>')
